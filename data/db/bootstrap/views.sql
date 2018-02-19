create or replace view seat_attendance as
	select s.id, s.type, d.party, count(1) as quantity
	from Seats s join Deputies d on s.id = d.SeatId join Attendances a on a.DeputyId = d.id
	where a.attendance in ('A', 'AO', 'PM', 'IV')
	group by s.id, s.type, d.party;

create or replace view attendance_frequency as
	select s.quantity, count(1) as frequency
	from seat_attendance s
    group by s.quantity;

create or replace view attendance_list as
	select sq.id, sq.type, sq.state, sq.area as district,
			SUBSTRING_INDEX(GROUP_CONCAT(CAST(sq.displayName AS CHAR) ORDER BY latestAttendance desc), ',', 1 ) as displayName,
      SUBSTRING_INDEX(GROUP_CONCAT(CAST(sq.party AS CHAR) ORDER BY latestAttendance desc), ',', 1 ) as party,
      GROUP_CONCAT(distinct sq.displayName SEPARATOR ', ') as attendanceEntry,
      SUM(sq.entries) as entries
	from (
		select s.id, s.type, s.state, s.area, d.displayName, d.party, count(1) as entries,  max(latestAttendance) latestAttendance
		from Seats s join Deputies d on d.SeatId = s.id join Attendances a on a.DeputyId = d.id
		and (a.attendance in ('A' , 'AO', 'PM', 'IV'))
		group by s.id, s.type, s.state, s.area, d.id, d.displayName, d.party
		order by s.id, max(latestAttendance) asc
	) sq
	group by sq.id, sq.type, sq.state, sq.area;
