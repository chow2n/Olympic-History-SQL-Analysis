select * from OLYMPIC_HISTORY;
select * from NOC_REGIONS;

-- How many olympics games have been held?
select count(distinct games) from olympic_history;

-- List down all Olympics games held so far.
select distinct games from olympic_history;

-- Mention the total no of nations who participated in each olympics game?
select games, count(distinct noc) as total_countries
from olympic_history
group by games
order by games;

-- Which nation has participated in all of the olympic games
select region, count(distinct games) as total_participated_games
from olympic_history o
join noc_regions n
	on o.noc = n.noc
group by region
having count(distinct games) = 51

-- Identify the sport which was played in all summer olympics.
with summer as
	(select count(distinct games) as total_summer_games
	from olympic_history
	where season = 'Summer'),
	
	summer_sports as
	(select distinct sport, games
	from olympic_history
	where season = 'Summer'
	order by games),
	
	num_of_games as
	(select sport, count(games) as num_of_games
	from summer_sports
	group by sport)

select * 
from num_of_games nog
join summer s
	on s.total_summer_games = nog.num_of_games

-- Fetch the top 5 athletes who have won the most gold medals.
with temp1 as
	(select name, count(1) as total_gold_medals 
	from olympic_history
	where medal = 'Gold'
	group by name
	order by total_gold_medals desc),
	
	temp2 as
	(select *, 
	 dense_rank() over(order by total_gold_medals desc) as medalrank
	from temp1)
select *
from temp2
where medalrank < 6

-- List down total gold, silver and bronze medals won by each country.
select country,
	coalesce(gold, 0) as gold,
	coalesce(silver, 0) as silver,
	coalesce(bronze, 0) as bronze
from crosstab('select region as country, medal, count(1) as total_medals
			from olympic_history o
			join noc_regions n
				on o.noc = n.noc
			where medal != ''NA''
			group by region, medal
			order by region, medal',
			 'values(''Bronze''), (''Gold''), (''Silver'')')
		as result(country VARCHAR, bronze BIGINT, gold BIGINT, silver BIGINT)
order by gold desc, silver desc, bronze desc