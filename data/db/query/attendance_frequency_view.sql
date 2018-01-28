-- Attendance Frecuency + Accumulated frequency
select st2.quantity, st2.frequency, @running_total := @running_total + st2.frequency AS cumulative_frequency
from attendance_frequency st2 join (select @running_total := 0) r;

-- Congress average and maximum
select avg(quantity) as average, max(quantity) as max, min(quantity) as min
from seat_attendance;

-- Congress average by type
select type, avg(quantity) as average
from seat_attendance
group by type
order by average;

-- Average by party
select party, avg(quantity) as average, count(1) as deputies
from seat_attendance
group by party
order by average;

select type, party, avg(quantity) as average, count(1) as deputies
from seat_attendance
group by type, party
order by party, type;


select a.attendance as name, a.description, count(1) as value
from Attendances a left outer join Deputies de on de.id = a.DeputyId left outer join Seats s on s.id = de.SeatId
where s.id = 1 group by a.attendance, a.description
