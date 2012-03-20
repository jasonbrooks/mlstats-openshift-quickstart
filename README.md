Venus on OpenShift
=========================

Mailing List Stats is a tool to analyze mailing list archives. It can retrieve the archives from a remote web page (usually, the archives web page), or read them from a local directory. It generates a brief report, and write everything to a MySQL database (called mlstats unless other name is indicated).

This quickstart is intended to get users up and running quickly with mlstats. Add the URLs for the archive pages of the list you wish to analyze to the file libs/lists_list, push to openshift, and the project's scripts will generate charts of the data with the javascript charting library Dygraphs.

More information on mlstats can be found at http://forge.morfeo-project.org/projects/libresoft-tools and information on dygraphs can be found at http://dygraphs.com/.

Running on OpenShift
--------------------

Create an account at http://openshift.redhat.com/

Create a PHP application

	rhc app create -a mlstats -t php-5.3

Add cron support to your application
    
	rhc app cartridge add -a mlstats -c cron-1.4
    
Add this upstream mlstats quickstart repo

	cd mlstats
	rm php/index.php
	git remote add upstream -m master git://github.com/jasonbrooks/mlstats-openshift-quickstart.git
	git pull -s recursive -X theirs upstream master

Customize lists configuration, adding mailing list archive pages, such as http://mail.python.org/pipermail/mailman-announce/.

	vi libs/lists_list

Commit configuration customizations

	git commit -a -m "added lists to lists_list"

Then push the repo upstream to OpenShift

	git push        

That's it, you can now check out your application at:

	http://mlstats-$yourdomain.rhcloud.com

The mlstats script that loads the database runs at deploy time and again each day, and lives at .openshift/action_hooks/deploy and .openshift/cron/daily/update for these respective purposes. These scripts multiple trigger query/charting scripts that live in libs/queries. These scripts generate html files which they drop in php/ for serving.

Once your mlstats setup is up and running, you can use OpenShift's port forwarding feature to run arbitrary queries using your preferred local mysql query tool:

    rhc-port-forward -a mlstats
