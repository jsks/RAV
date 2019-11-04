create table trips (started_at timestamp not null);
create table aggregated (datestr date not null, count int not null);

.mode csv
.import sqlite_pipe trips

insert into aggregated
select date(started_at, 'localtime') as datestr, count(*) as count
       from trips
       group by datestr;
