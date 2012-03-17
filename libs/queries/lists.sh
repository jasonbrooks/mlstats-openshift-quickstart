#!/bin/bash

## prepare date list

mysql -u "$OPENSHIFT_DB_USERNAME" --password="$OPENSHIFT_DB_PASSWORD" --column-names=1 \
  -h "$OPENSHIFT_DB_HOST" mlstats < $OPENSHIFT_REPO_DIR/libs/queries/list_of_dates.sql \
  | sed 's/\t/,/g' > $OPENSHIFT_REPO_DIR/libs/queries/working/list_of_dates.txt

## prepare list name list

mysql -u "$OPENSHIFT_DB_USERNAME" --password="$OPENSHIFT_DB_PASSWORD" --column-names=0 \
  -h "$OPENSHIFT_DB_HOST" mlstats < $OPENSHIFT_REPO_DIR/libs/queries/list_of_listnames.sql \
  | sed 's/\t/,/g' > $OPENSHIFT_REPO_DIR/libs/queries/working/list_of_listnames  

## prepare by-date count for each list
  
for list in `cat list_of_listnames`;
do
  mysql -u "$OPENSHIFT_DB_USERNAME" --password="$OPENSHIFT_DB_PASSWORD" --column-names=1 \
  -h "$OPENSHIFT_DB_HOST" mlstats -e "SELECT COALESCE(list.mlu,0) '$list' FROM (select LEFT(first_date, 10) fdl from messages group by fdl order by first_date) list_all LEFT JOIN (select LEFT(first_date, 10) fdl, count(mailing_list_url) mlu from messages m where mailing_list_url LIKE '%$list%' group by fdl order by first_date) list on list_all.fdl = list.fdl" \
  | sed 's/\t/,/g' > $OPENSHIFT_REPO_DIR/libs/queries/working/${list}.list
done;

## combine dates and list counts into csv

paste -d , list_of_dates.txt `ls *.list` > $OPENSHIFT_REPO_DIR/php/lists.csv

## clean temp files

#rm *.txt *.list

## write top of lists.html
echo "<html>
<head>
<script type=\"text/javascript\"
  src=\"dygraph-combined.js\"></script>
</head>
<body>
<div id=\"graphdiv\"
  style=\"width:1000px; height:500px;\"></div>
<p><b>Show Series:</b></p>
<p>"  > $OPENSHIFT_REPO_DIR/php/lists.html


## get count of lists, create a pair of these lines below for each series

COUNTER=0

for list in `cat $OPENSHIFT_REPO_DIR/libs/queries/working/list_of_listnames`; do
  echo "    <input type=checkbox id=\"$COUNTER\" checked onClick=\"change(this)\">
    <label for=\"$COUNTER\"> $list</label><br/>" >> $OPENSHIFT_REPO_DIR/php/lists.html
  let COUNTER=COUNTER+1    
done;

## Bottom portion
## first, get my string of trues ready

trues=`while [ $COUNTER -gt 1 ]; do
  echo -n "true, "
  let COUNTER=COUNTER-1
done`
trues=$trues"true"

echo "

<script type=\"text/javascript\">
  g = new Dygraph(
    document.getElementById(\"graphdiv\"),
    \"lists.csv\", // path to CSV file
    {
      title: 'Mailing List Activity Over Time',
      rollPeriod: 7,
      legend: 'onmouseover', 
      showRoller: true,
      visibility: [$trues]
    }          // options
  );
setStatus();

      function setStatus() {
        document.getElementById(\"visibility\").innerHTML =
          g.visibility().toString();
      }

      function change(el) {
        g.setVisibility(parseInt(el.id), el.checked);
        setStatus();
      }
</script>
<p>
Data collected with <a href=\"https://gitorious.org/mining-tools/mlstats\">mlstats</a> and displayed with <a href=\"http://dygraphs.com/\">dygraphs</a>.
</body>
</html>" >> $OPENSHIFT_REPO_DIR/php/lists.html
