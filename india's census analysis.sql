use indiancensus;
select * from data1;
select * from data2;

-- gether data for gujarat 
select * from data1 where State = 'Gujarat';
-- population of the india 
-- Select individual population values without commas
SELECT REPLACE(population, ',', '') FROM data2;

-- Select the sum of population after removing commas
SELECT SUM(REPLACE(population, ',', '')) as 'Total population of india' FROM data2;

-- average growth of india 
select avg(Growth) as 'average growth population growth of  india' from data1;

-- average growth by state
select avg(Growth) as 'average growth by state',state  from data1 group by State order by avg(Growth) desc;

-- average sex ratio 
select round(avg(Sex_Ratio)) as 'Average sex ratio of india' from data1;


-- average sex ratio state wise 
select round(avg(Sex_Ratio)) as 'Average sex ratio statewise', state from data1 group by state order by round(avg(Sex_Ratio)) desc;

-- average literacy rate state wise 
select round(avg(literacy)) as 'Average literacy rate statewise', state from data1 group by state order by round(avg(literacy)) desc; 

-- select Sex_Ratio and growth state wise 
select state,Growth,Sex_Ratio from data1;

-- state which has literacy rate more than 90
select state,round(avg(Literacy)) as 'average literacy statewise' from data1 group by state 
having round(avg(Literacy))>90 order by round(avg(Literacy)) desc;
-- order of execution in sql having comes before order by 
-- top 3 states which has highest growth percentage
SELECT state, avg(growth) AS growth_percentage
FROM data1 group by state
ORDER BY growth_percentage DESC
LIMIT 3;

-- lowest  3 sex ratio 
select state, round(avg(Sex_Ratio)) as 'sex ratio per state ' from data1 group by state order by round(avg(Sex_Ratio)) limit 3; 

-- top 3 and bottom 3 state as per literacy 
(SELECT state, AVG(literacy) AS avg_literacy
FROM data1 
GROUP BY state 
ORDER BY AVG(literacy) DESC 
LIMIT 3)
UNION
(SELECT state, AVG(literacy) AS avg_literacy
FROM data1 
GROUP BY state 
ORDER BY AVG(literacy) ASC 
LIMIT 3);

-- state starting with letter a 
select distinct state from data1 where lower(state) like 'a%';

-- state which is starting with 'a' and ending with 'b' 
select distinct state from data1 where lower(state) like 'a%' or lower(state) like '%b';

SET SQL_SAFE_UPDATES = 0;

UPDATE data2
SET population = REPLACE(population, ',', '');


-- number of male and number of female which are present in a state district
-- first joining both table 
select d.state,sum(d.male)  as 'Total Male',sum(d.female) as 'Total Female'  from
(select c.district,c.state,round(c.population/(c.Sex_Ratio+1)) as male, round ((c.population*c.Sex_Ratio)/(c.Sex_Ratio+1)) as female from
(select a.district,a.state,a.sex_ratio/1000 as 'Sex_Ratio',b.population from data1 a join data2 b on a.district=b.district) c)d group by d.state;

-- total literacy rate 
select c.state,sum(literatepeople) as 'total literate population',sum(iliteratepeople) as 'total iliterate population' from 
(select d.district , d.state ,round(((d.literacy_ratio)*population))as 'literatepeople',
round(((1-literacy_ratio)*population)) as 'iliteratepeople'  from
(select a.district,a.state,a.literacy/100 as 'literacy_ratio',b.population from data1 a join data2 b on a.district=b.district)d)c 
group by c.state;

-- population in previous census
select c.state,sum(previous_decade_population) as 'previous decade population', sum(current_census_population) as 'current_population' from
(select d.district,d.state,round((d.population)/(1+d.Growth/100)) as 'previous_decade_population',population as 'current_census_population' from
(select a.district,a.state,a.Growth,b.population from data1 a join data2 b on a.district=b.district)d)c 
group by c.state;
  
-- window funcation 
-- output of top 3 district 
select a.* from 
(select district,state,literacy , rank() over(partition by state order by literacy desc) rnk from data1) a
where 
a.rnk in (1,2,3) order by state;
