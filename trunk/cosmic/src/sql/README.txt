on quarknet:
    pg_dump -D -U vdsdev8085 userdbdev8085_2004_1215 > quarknet-userdbdump.sql
    ssh quarknet-userdbdump.sql over to evitable

on evitable:
    in quarknet-userdbdump.sql:
        delete all SEQUENCE stuff at beginning and ALTER, SELECT stuff at end (only thing left is CREATE and INSERT)
        delete all feedback and response table stuff
    psql -U vdsdev8085:
        create database hibernate_jobs;
    psql -U vdsdev8085 -d hibernate_jobs-f quarknet-userdbdump.sql
    psql -U vdsdev8085:
        \c hibernate_jobs
        alter table answer rename to answer9;
        alter table project rename to project9;
        alter table question rename to question9;
        alter table survey rename to survey9;
        alter table comment rename to comment9; 
    change /usr/local/quarknet-test/tomcat/webapps/elab/WEB-INF/classes/hibernate.properties
    in quarknet/src/java:
        ant test-userdb

    in quarknet/src/sql
        psql -U vdsdev8085 -d hibernate_jobs -f map.sql 

    go to http://quarknet.uchicago.edu/elab/cosmic/controlReferences.jsp
    select References
    select SQL
    hit Download
    hit Open/Download
    open as a text file, paste the text into a new file such as [reference].sql
    repeat for Glossary
    run:
        psql -U vdsdev8085 -d hibernate_jobs -f [reference].sql 
        psql -U vdsdev8085 -d hibernate_jobs -f [glossary].sql 

    
