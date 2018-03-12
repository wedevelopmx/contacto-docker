drop table if exists ActiveDeputies ;

create table ActiveDeputies (
	id INTEGER primary key,
    type VARCHAR(255),
    state VARCHAR(255),
    district INTEGER,
    party VARCHAR(255),
    displayName VARCHAR(255),
    slug VARCHAR(255),
    attendance INTEGER,
    attendanceDate datetime,
    INDEX active_profile_index (id, state, slug, attendance, attendanceDate)
);

-- LIST PROFILE
insert ignore ActiveDeputies (id, type, state, district, party, displayName, slug, attendanceDate, attendance)
select s.id, s.type, s.state, s.area as district,
	SUBSTRING_INDEX(GROUP_CONCAT(CAST(d.party AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as party,
    SUBSTRING_INDEX(GROUP_CONCAT(CAST(d.displayName AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as displayName,
    SUBSTRING_INDEX(GROUP_CONCAT(CAST(d.slug AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as slug,
	max(a.attendanceDate) as latestAttendance,
    count(1) as attendances
from Seats s join Attendances a on s.id = a.SeatId join Deputies d on a.DeputyId = d.id and a.attendance in ('A' , 'AO', 'PM', 'IV')
group by s.id, s.type, s.state, s.area;

-- FRECUENCY
create view attendance_frequency as
select attendance as value, count(1) as frecuency from ActiveDeputies group by attendance ;


-- All legislature overview
create view attendance_overview as
select round(avg(attendance), 2) as average, max(attendance) as max, min(attendance) as min,
	round(avg(attendance) + stddev(attendance)/2, 2) as max_std, round(avg(attendance) - stddev(attendance)/2,2) as min_std
from ActiveDeputies;

-- Report by party
create view attendance_by_party as
select party, round(avg(attendance), 2) as average, max(attendance) as max, min(attendance) as min, round(avg(attendance) + stddev(attendance)/2, 2) as max_std, round(avg(attendance) - stddev(attendance)/2,2) as min_std, count(1) as deputies
from ActiveDeputies
group by party order by average;

-- Report by state
create view attendance_by_state as
select state, round(avg(attendance), 2) as average, max(attendance) as max, min(attendance) as min, round(avg(attendance) + stddev(attendance)/2, 2) as max_std, round(avg(attendance) - stddev(attendance)/2,2) as min_std, count(1) as deputies
from ActiveDeputies
group by state order by average;

-- Report by deputy type
create view attendance_by_deputy_type as
select type, round(avg(attendance), 2) as average, max(attendance) as max, min(attendance) as min, round(avg(attendance) + stddev(attendance)/2, 2) as max_std, round(avg(attendance) - stddev(attendance)/2,2) as min_std, count(1) as deputies
from ActiveDeputies 
group by type order by average;

--
-- INDIVIDUALS
--

-- PROFILE
-- select s.id, s.type, s.state, s.area as distict, d.displayName, d.slug, p.profileNumber, p.status, p.party,
-- 	p.birth, p.startDate, p.building, p.email, p.phone, p.studies, p.academics, p.twitter, p.facebook
-- from Seats s join Deputies d on s.id = d.SeatId left outer join Profiles p on p.id = d.id
-- where s.id in ( select SeatId from Deputies d where d.slug = 'jose-de-jesus-valdez-gomez' );

-- DISTRIBUTION
-- select a.attendance as name, a.description, count(1) as value
-- from Seats s join Attendances a on s.id = a.SeatId
-- where s.id = 1 group by a.attendance, a.description;
