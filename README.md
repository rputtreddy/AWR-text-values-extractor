# AWR-text-values-extractor

What motivated me to write this automation?

I had a requirement to do capacity planning and understanding the daily trend analysis of oracle database nearly using one month of data where I used to get lot of AWR reports. All the AWR reports I can't look manually. So If I extract the required data from AWR and can use this data to upload it in influxDB and with the help of grafana I can build a dashboards just like OEM (Oracle Enterprise Manager).

Objective
1) Extract the required information from AWR Report which is useful for analyzing capacity planning.
2) Identifiy the potential issues using AWR report.
3) How to keep track of any specific SQL performance using trending.
etc....


What I am sharing?
1) Perl script which will extract the data from multiple files and will save it in CSV format.

Not sharing?
1) How to load this CSV data into influxDB
2) How to create dashboards using grafana

awrparser-list.pl --> With this script you can fetch Foreground wait events, Foreground wait event class details & Instance activity stats details. You can uncomment the respective file handle column names based on your requirement.

awrparser-sqllist.pl --> With this script you can extract SQL ordered by Elapsed Time, SQL ordered by CPU Time & SQL ordered by User I/O Wait Time details. You can get the remaining section of details as well with small modification on code.
