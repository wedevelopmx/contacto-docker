/*
* ProfileDetails hold all deputies that have attended a session
*/
drop table if exists ProfileDetails;

create table ProfileDetails (
	id integer,
    type varchar(255),
    state varchar(255),
    district integer,
    displayName varchar(255),
    slug varchar(255),
    profileNumber varchar(50),
    status varchar(255),
    party varchar(255),
    DeputyId integer,
    birth datetime,
    startDate datetime,
    building varchar(255),
    email varchar(255),
    phone varchar(255),
    studies varchar(255),
    academics varchar(255),
    twitter varchar(255),
    facebook varchar(255),
    attendances integer,
    latestAttendance date,
    primary key(id, DeputyId),
    unique (id, DeputyId),
	index active_profile_index (id, state, slug, attendances, latestAttendance)
);

create index index_profile_details on ProfileDetails (slug);

update Profiles set birth = null where birth = '';
update Profiles set startDate = null where startDate = '';

insert into ProfileDetails(id, type, state, district, displayName, slug, profileNumber, status, party, DeputyId,
	birth, startDate, building, email, phone, studies, academics, twitter, facebook, attendances, latestAttendance)
select s.id, s.type, s.state, s.area, d.displayName, d.slug, p.profileNumber, p.status, d.party, d.id,
	STR_TO_DATE( p.birth, '%d/%m/%Y'), STR_TO_DATE( p.startDate, '%d/%m/%Y'), p.building, p.email, p.phone,
    p.studies, p.academics, p.twitter, p.facebook, count(1), max(a.attendanceDate)
  from Seats s join Deputies d on s.id = d.SeatId
  left outer join Attendances a on a.SeatId = s.id and a.DeputyId = d.id
  left outer join Profiles p on p.id = d.id
  group by s.id, s.type, s.state, s.area, d.displayName, d.slug, p.profileNumber, p.status, d.party, d.id,
	 p.birth, p.startDate, p.building, p.email, p.phone, p.studies, p.academics, p.twitter, p.facebook
   having count(1)  > 1;

-- select * from ProfileDetails;

/*
* ActiveDeputies hold all active deputies
*/

drop table if exists ActiveDeputies;

create table ActiveDeputies (
	id integer primary key,
    type varchar(255),
    state varchar(255),
    area integer,
    party varchar(255),
    displayName varchar(255),
		slug varchar(255),
    birth date,
    studies varchar(255),
    academics varchar(255),
    attendances integer,
    latestAttendances date
);

insert into ActiveDeputies (id, type, state, area, party, displayName, slug, birth, studies, academics, attendances, latestAttendances)
select s.id,
	SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT CAST(s.type AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as type,
    SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT CAST(s.state AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as state,
    SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT CAST(s.area AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as area,
	SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT CAST(d.party AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as party,
    SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT CAST(d.displayName AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as displayName,
		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT CAST(d.slug AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as slug,
    STR_TO_DATE(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT CAST(p.birth AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ), '%d/%m/%Y') as birth,
    SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT CAST(p.studies AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as studies,
    SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT CAST(p.academics AS CHAR) ORDER BY a.attendanceDate desc), ',', 1 ) as academics,
    count(1) - 1 as attendances,
    max(a.attendanceDate) as latestAttendance
  from Seats s join Deputies d on s.id = d.SeatId
  left outer join Attendances a on a.SeatId = s.id and a.DeputyId = d.id and a.attendance in ('A', 'PM', 'AO', 'IV')
  left outer join Profiles p on p.id = d.id
  group by s.id having count(1) > 1;

-- select * from ActiveDeputies;

/*
* Next views are design as helpers for attendance graphs
*/

-- FRECUENCY
drop view if exists attendance_frequency;
	create view attendance_frequency as
	select attendances as quantity, count(1) as frequency from ActiveDeputies group by attendances ;

-- All legislature overview
drop view if exists attendance_overview;
create view attendance_overview as
	select round(avg(attendances), 2) as average, max(attendances) as max, min(attendances) as min,
		round(avg(attendances) + stddev(attendances)/2, 2) as max_std, round(avg(attendances) - stddev(attendances)/2,2) as min_std
	from ActiveDeputies;

-- Report by party
drop view if exists attendance_by_party ;
create view attendance_by_party as
	select party, round(avg(attendances), 2) as average, max(attendances) as max,
    min(attendances) as min, round(avg(attendances) + stddev(attendances)/2, 2) as max_std,
    round(avg(attendances) - stddev(attendances)/2,2) as min_std, count(1) as deputies
	from ActiveDeputies
	group by party order by average;

-- Report by state
drop view if exists attendance_by_state ;
create view attendance_by_state as
	select state,
    round(avg(attendances), 2) as average, max(attendances) as max, min(attendances) as min,
    round(avg(attendances) + stddev(attendances)/2, 2) as max_std,
    round(avg(attendances) - stddev(attendances)/2,2) as min_std, count(1) as deputies
	from ActiveDeputies
	group by state order by average;

-- Report by deputy type
drop view if exists attendance_by_deputy_type ;
create view attendance_by_deputy_type as
	select type, round(avg(attendances), 2) as average,
    max(attendances) as max, min(attendances) as min,
    round(avg(attendances) + stddev(attendances)/2, 2) as max_std,
    round(avg(attendances) - stddev(attendances)/2,2) as min_std, count(1) as deputies
	from ActiveDeputies
	group by type order by average;

/*
* Next views are design as helpers for chamber report
*/

drop view if exists chamber_by_party ;
create view chamber_by_party as
	select party, count(1)  as quantity
	from ActiveDeputies
	group by party
	order by count(1) desc;

drop view if exists chamber_by_studies ;
create view chamber_by_studies as
	select IFNULL(studies, "Desconocido") as studies, count(1) as quantity
	from ActiveDeputies
	group by studies
	order by count(1) desc;

drop view if exists chamber_studies_by_party ;
create view chamber_studies_by_party as
	create view chamber_studies_by_party as
	select party,
		sum(coalesce(case when studies = 'Doctorado' then 1 end, 0))  as doctorado,
		sum(coalesce(case when studies = 'Maestría' then 1 end, 0))  as maestria,
		sum(coalesce(case when studies = 'Licenciatura' then 1 end, 0))  as licenciatura,
		sum(coalesce(case when studies = 'Pasante/Licenciatura trunca' then 1 end, 0))  as pasante,
		sum(coalesce(case when studies = 'Profesor Normalista' then 1 end, 0))  as normalista,
		sum(coalesce(case when studies = 'Técnico' then 1 end, 0))  as tecnico,
		sum(coalesce(case when studies = 'Preparatoria' then 1 end, 0))  as preparatoria,
		sum(coalesce(case when studies = 'Secundaria' then 1 end, 0))  as secundaria,
		sum(coalesce(case when studies = 'Primaria' then 1 end, 0))  as primaria,
		sum(coalesce(case when ifnull(studies, true) = true then 1 end, 0))  as desconocido,
		sum(1) as deputies
	from ActiveDeputies
	group by party;


drop view if exists chamber_by_academics ;
create view chamber_by_academics as
	select IFNULL(academics, "Desconocido") as academics, count(1) as quantity
	from ActiveDeputies
	group by academics
	order by count(1) desc;

drop view if exists chamber_by_age;
create view chamber_by_age as
	select IFNULL(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y'), "Desconocido") age, count(1) quantity
	from ActiveDeputies
	group by IFNULL(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y'), "Desconocido") ;

drop view if exists chamber_party_avg_age ;
create view chamber_party_avg_age as
	select party, round(avg(IFNULL(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y'), 0)), 2) age, count(1) as quantity
	from ActiveDeputies where birth is not null
	group by party
   order by count(1);

drop view if exists chamber_party_age_distribution ;
create view chamber_party_age_distribution as
	select party,
   min(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y')) min,
   round(avg(IFNULL(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y'), 0)) - stddev(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y'))/2, 2) min_std,
   round(avg(IFNULL(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y'), 0)), 2) avg,
   round(avg(IFNULL(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y'), 0)) + stddev(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y'))/2, 2) max_std,
   max(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y')) max
	from ActiveDeputies where birth is not null
	group by party
   order by round(avg(IFNULL(DATE_FORMAT(now(), '%Y') - DATE_FORMAT(birth, '%Y'), 0)), 2) desc;

/*
* This view gives chamber sessions
*/
drop view if exists chamber_sessions;
	create view chamber_sessions as
	select s.id, s.name, date_format(min(a.attendanceDate), '%d/%m/%Y') as startDate, date_format(max(a.attendanceDate), '%d/%m/%Y') as endDate, count(distinct a.attendanceDate) as days
	from Sessions s join Attendances a on s.id = a.SessionId
	group by s.id, s.name;
