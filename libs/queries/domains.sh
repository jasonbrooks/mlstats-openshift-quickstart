#!/bin/bash

## prepare date list
## note these seds aren't needed

mysql -u "$OPENSHIFT_DB_USERNAME" --password="$OPENSHIFT_DB_PASSWORD" --column-names=1 \
  -h "$OPENSHIFT_DB_HOST" mlstats < $OPENSHIFT_REPO_DIR/libs/queries/list_of_dates.sql \
  | sed 's/\t/,/g' > $OPENSHIFT_REPO_DIR/libs/queries/working/list_of_dates.txt

## prepare top five domains list

mysql -u "$OPENSHIFT_DB_USERNAME" --password="$OPENSHIFT_DB_PASSWORD" --column-names=0 \
  -h "$OPENSHIFT_DB_HOST" mlstats < $OPENSHIFT_REPO_DIR/libs/queries/top_five_domains.sql \
  | sed 's/\t/,/g' > $OPENSHIFT_REPO_DIR/libs/queries/working/top_five_domains  

## prepare by-date count for each domain
  
for domain in `cut -d"," -f1 $OPENSHIFT_REPO_DIR/libs/queries/working/top_five_domains`;
do
  mysql -u "$OPENSHIFT_DB_USERNAME" --password="$OPENSHIFT_DB_PASSWORD" --column-names=1 \
  -h "$OPENSHIFT_DB_HOST" mlstats -e "SELECT COALESCE(tdl.da,0) '$domain' FROM (select LEFT(first_date, 10) fdl from messages where LEFT(first_date, 4) > 1979 group by fdl order by first_date) list_all LEFT JOIN (select LEFT(first_date, 10) fdl, count(distinct(email_address)) da, SUBSTRING_INDEX(email_address, '@', -1) domain from messages m join messages_people p on m.message_ID = p.message_id where email_address LIKE '%$domain%' group by fdl order by first_date) tdl ON tdl.fdl = list_all.fdl" \
  | sed 's/\t/,/g' > $OPENSHIFT_REPO_DIR/libs/queries/working/${domain}.domain
done;

## combine dates and list counts into csv

paste -d , $OPENSHIFT_REPO_DIR/libs/queries/working/list_of_dates.txt `ls $OPENSHIFT_REPO_DIR/libs/queries/working/*.domain` > $OPENSHIFT_REPO_DIR/php/domains.csv

## clean temp files

#rm *.txt *.list

## write top of domains.html
echo "<html>
<head>
<script type=\"text/javascript\"
  src=\"dygraph-combined.js\"></script>
</head>
<body>
<div id=\"graphdiv\"
  style=\"width:1000px; height:500px;\"></div>
<p><b>Show Series:</b></p>
<p>"  > $OPENSHIFT_REPO_DIR/php/domains.html


## get count of lists, create a pair of these lines below for each series

COUNTER=0

for domain in `sort $OPENSHIFT_REPO_DIR/libs/queries/working/top_five_domains`; do
  echo "    <input type=checkbox id=\"$COUNTER\" checked onClick=\"change(this)\">
    <label for=\"$COUNTER\"> $domain</label><br/>" >> $OPENSHIFT_REPO_DIR/php/domains.html
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
    \"domains.csv\", // path to CSV file
    {
      title: 'Mailing List Participants Over Time, Top Five Domains',
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
</html>" >> $OPENSHIFT_REPO_DIR/php/domains.html
