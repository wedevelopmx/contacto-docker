-- Deputies with active alternates from different party
select a.id, count(1) from (
	select s.id, s.type, d.party, count(1) as quantity 
	from Seats s join Deputies d on s.id = d.SeatId join Attendances a on a.DeputyId = d.id 
	where a.attendance in ('A', 'AO', 'PM', 'IV') 
	group by s.id, s.type, d.party
) a group by a.id
having count(1) > 1;

-- select * from Deputies where SeatId in (21, 417);
-- 
-- update Deputies set party ='pve' where id = 521;
-- update Deputies set party ='prd' where id = 917;

