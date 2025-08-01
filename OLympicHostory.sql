/* Total Number of summer Olympic games */

select * from athlete_events;
select * from noc_regions;

/* Find the number of games played in each Olympics */

select games , count(distinct sport)
from athlete_events
group by games;

/*/* Find the total number of Gold medals won each year */
  
  select `Year`, count(Medal) as Gold_Medals
from athlete_events
where Medal = 'Gold'
group by `Year`
order by `Year`;

/*  Identify the sport which was played in all summer olympics.*/
with t1 as (select count(distinct games) as TotalSummerGames
from athlete_events
where season = 'Summer'
order by games) ,

 t2 as 
(select distinct sport , games
from athlete_events
where season = 'summer'
order by games),
 t3 as 
( select sport, count(games) as Totalgames
from t2 
group by sport)
select *
from t3 join t1 on t1.TotalSummerGames = t3.Totalgames;

  /* Which nation has participated in all of the olympic games? */
  
 
  with totalgames as
  (select count(distinct games) as TotalGames
  from athlete_events),
  totalcountries as 
  (select games, n.region
  from athlete_events a join noc_regions n on a.noc = n.noc
  group by games, n.region),
  countrypart as
  (select region, count(1)  as totalpgames
  from totalcountries
  group by region)

  select *
  from  countrypart cp join totalgames t on  cp.totalpgames = t.totalgames
  order by 1;
  
  /* 7. Which Sports were just played only once in the olympics.*/
  
  select  sport, count(games) as TotalGamesPlayed
  from athlete_events
  group by sport
  having  TotalGamesPlayed = 1;
  
   with t1 as
          	(select distinct games, sport
          	from athlete_events),
          t2 as
          	(select sport, count(1) as no_of_games
          	from t1
          	group by sport)
      select t2.*, t1.games
      from t2
      join t1 on t1.sport = t2.sport
      where t2.no_of_games = 1
      order by t1.sport;
/* Fetch the total no of sports played in each olympic games.*/

select  games, count(distinct sport) as TotalSport
from athlete_events
group by games
order by Totalsport desc;

/* Fetch oldest athletes to win a gold medal */
  
  select name, age, event, medal
  from athlete_events
  where medal = 'Gold'
  order by age desc
  limit 2;
  
 with temp as
            (select name,sex,cast(case when age = 'NA' then '0' else age end as unsigned) as age
              ,team,games,city,sport, event, medal
            from athlete_events),
        ranking as
            (select *, rank() over(order by age desc) as rnk
            from temp
            where medal='Gold')
    select *
    from ranking
    where rnk = 1;
    
    /* Fetch the top 5 athletes who have won the most gold medals.*/

select  Name,  count(*) as TotalMedals
from athlete_events
where Medal = 'Gold'
group by Name
order by TotalMedals desc;

WITH MedalCount AS (
  SELECT 
    name,
    sport,
    COUNT(medal) AS total_medals
  FROM athlete_events
  WHERE medal ='Gold'
  GROUP BY name, sport
),
RankedMedals AS (
  SELECT *,
         dense_rank() OVER ( ORDER BY total_medals DESC) AS rnk
  FROM MedalCount
)
SELECT name, sport, total_medals
FROM RankedMedals
WHERE rnk = 1
ORDER BY total_medals DESC
limit 5;  

/*  Fetch the top 5 athletes who have won the most medals (gold/silver/bronze). */

select  Name,  count(*) as TotalMedals
from athlete_events
where Medal in ('Gold','Silver','bronze')
group by Name
order by TotalMedals desc;

/*  Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.*/

select count(*) as TotalMedal , n.region
from athlete_events a join noc_regions n on a.noc = n.noc
where Medal In ('Gold','Silver','Bronze')
group by n.region
order by count(*) desc
limit 5;


 with t1 as
            (select n.region, count(1) as total_medals
            from athlete_events a
            join noc_regions n on a.noc = n.noc
            where medal <> 'NA'
            group by n.region
            order by total_medals desc),
        t2 as
            (select *, dense_rank() over(order by total_medals desc) as rnk
            from t1)
    select *
    from t2
    where rnk <= 5;
    
    /* List down total gold, silver and bronze medals won by each country.

Problem Statement */

select n.region,
sum(Case when medal = 'Gold' then 1 else 0 end) as Gold_medals,
sum(Case when medal = 'Silver' then 1 else 0 end) as Silver_medals,
sum(case when medal = 'bronze' then 1 else 0 end) as Bronze_medals,
count(a.medal) as Total_Medals
from athlete_events a join noc_regions n on a.noc = n.noc
where a.Medal is not null
group by n.region
order by total_medals desc;


select n.region, games,
sum(Case when medal = 'Gold' then 1 else 0 end) as Gold_medals,
sum(Case when medal = 'Silver' then 1 else 0 end) as Silver_medals,
sum(case when medal = 'bronze' then 1 else 0 end) as Bronze_medals,
count(a.medal) as Total_Medals
from athlete_events a join noc_regions n on a.noc = n.noc
where a.Medal is not null
group by n.region, games
order by games;

/* Identify which country won the most gold, most silver and most bronze medals in each olympic games. */

with medalcounts as 
(select a.games, n.region, a.medal
from athlete_events a join noc_regions n on a.noc = n.noc
where a.medal is not null),
Goldcounts as 
(select games, region, count(*) as GoldMedals, rank() over(partition by games order by count(*)desc) as rnk
from medalcounts
where medal = 'Gold'
group by games, region),
Silvercounts as (select games, region, count(*) as SilverMedals, rank() over(partition by games order by count(*)desc) as rnk
from medalcounts
where medal = 'Silver'
group by games, region),
Bronzecount as 
(select games, region, count(*) as BronzeMedals, rank() over( partition by games order by count(*) desc) as rnk
from medalcounts
where medal = 'bronze'
group by games, region)

select
  g.games,
  g.region as topgoldcountry,
  g.goldmedals,
  s.region as topsilvercountry,
  s.silvermedals,
  b.region as topbronzecountry,
  b.bronzemedals
  
from goldcounts g
join silvercounts s ON g.games = s.games AND s.rnk = 1
join bronzecount b ON g.games = b.games AND b.rnk = 1
WHERE g.rnk = 1
ORDER BY g.games;

/*  In which Sport/event, India has won highest medals. */

select a.sport, n.region, a.Medal, a.Games, count(*) as TotalMedals
from athlete_events a join noc_regions n on a.noc = n.noc
where n.region = 'India'and a.Medal <> 'NA'
group by a.sport, n.region, a.Medal, a.games;

 /*In which Sport/event, India has won highest medals. */
    with t1 as
        	(select sport, count(1) as total_medals
        	from athlete_events
        	where medal <> 'NA'
        	and team = 'India'
        	group by sport
        	order by total_medals desc),
        t2 as
        	(select *, rank() over(order by total_medals desc) as rnk
        	from t1)
    select sport, total_medals
    from t2
    where rnk = 1;

 