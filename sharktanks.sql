use campusx;
SELECT * FROM campusx.sharktank;


--- 1.You Team must promote shark Tank India season 4, The senior come up with the idea
--- to show highest funding domain wise so that new startups can be attracted, and you 
--- were assigned the task to show the same.
select * from(
Select Industry,`Total_Deal_Amount(in_lakhs)` 
,row_number() over(partition by industry
order by `Total_Deal_Amount(in_lakhs)` desc) 
as 'ran' from sharktank
group by Industry,`Total_Deal_Amount(in_lakhs)`
)t where ran = 1;

--- 2.You have been assigned the role of finding the domain where female 
---- as pitchers have female to male pitcher ratio >70%
select industry,(FP/MP)*100 as 'ratio' from(
select industry,sum(Male_Presenters) as 'MP',
sum(Female_Presenters) as 'FP'from sharktank
group by industry having sum(Male_Presenters)>0 
and sum(Female_Presenters) > 0
)t 
where (FP/MP)*100 > 70;

--- 3.You are working at marketing firm of Shark Tank India, you have got the task to 
--- determine volume of per season sale pitch made, pitches who received offer and 
--- pitches that were converted. Also show the percentage of pitches converted 
--- and percentage of pitches entertained.
select a.season_number,total,CR, (CR/total)*100 as 
'converted_pitches',AC,(AC/total)*100 as 'Accepted_pitches' from (
select season_number,count(Startup_Name) 'total'
from sharktank group by season_number ) a
inner join (
select season_number,count(Received_Offer) 'CR' 
from sharktank where Received_Offer = "Yes" group by season_number
) b 
on a.season_number = b.season_number
inner join(
select season_number,count(Accepted_Offer) 'AC' 
from sharktank where Accepted_Offer = "Yes" group by season_number
) c
on b.season_number = c.season_number;

--- 4.As a venture capital firm specializing in investing in startups featured on a 
--- renowned entrepreneurship TV show, you are determining the season with the highest 
--- average monthly sales and identify the top 5 industries with the highest average 
--- monthly sales during that season to optimize investment decisions?
set @sea = (select season_number from ( 
select season_number,avg(`Monthly_Sales(in_lakhs)`) 
as 'agm' from sharktank
group by season_number order by agm desc limit 1 
)t);
select @sea;
select industry,round(avg(`Monthly_Sales(in_lakhs)`),2) 
as 'igm' from sharktank
where season_number = @sea
group by industry order by igm desc limit 5;

--- 5.As a data scientist at our firm, your role involves solving real-world challenges
--- like identifying industries with consistent increases in funds raised over multiple 
--- seasons. This requires focusing on industries where data is available across all 
--- three seasons.Once these industries are pinpointed, your task is to delve into the 
--- specifics,analyzing the number of pitches made,offers received, and offers converted
--- per season within each industry.
with validindustries as (
select industry,
Max(case when season_number = 1 then `Total_Deal_Amount(in_lakhs)` end) as season1,
Max(case when season_number = 2 then `Total_Deal_Amount(in_lakhs)` end) as season2,
Max(case when season_number = 3 then `Total_Deal_Amount(in_lakhs)` end) as season3
from sharktank
group by industry
having season3>season2 and season2>season1 and season1!=0
)

select b.season_number,a.industry,
count(startup_name) as 'total',
count(case when b.received_offer = 'yes' then b.startup_name end) as 'received',
count(case when b.accepted_offer = 'yes' then b.startup_name end) as 'received'
from validindustries as a inner join sharktank as b 
on a.industry = b.industry
group by b.season_number, a.industry;

---  6.Every shark wants to know in how much year their investment will be returned, so you 
--- must create a system for them, where shark will enter the name of the startup’s and 
--- the based on the total deal and equity given in how many years their principal amount 
--- will be returned and make their investment decisions.


--- 7.In the world of startup investing, we're curious to know which big-name investor, 
--- often referred to as "sharks," tends to put the most money into each deal on average. 
--- This comparison helps us see who's the most generous with their investments and how 
--- they measure up against their fellow investors.

select sharkname,round(avg(investment),2) as 'average' from(
select `Namita_Investment_Amount(in lakhs)` as investment,'Namita' as sharkname from 
sharktank where `Namita_Investment_Amount(in lakhs)`>0
union all
select `Vineeta_Investment_Amount(in_lakhs)` as investment,'vinita' as sharkname from 
sharktank where `Vineeta_Investment_Amount(in_lakhs)`>0
union all
select `Anupam_Investment_Amount(in_lakhs)` as investment,'Anupam' as sharkname from 
sharktank where `Anupam_Investment_Amount(in_lakhs)`>0
union all
select `Aman_Investment_Amount(in_lakhs)` as investment,'Aman' as sharkname from 
sharktank where `Aman_Investment_Amount(in_lakhs)`>0
union all
select `Peyush_Investment_Amount((in_lakhs)` as investment,'Peyush' as sharkname from 
sharktank where `Peyush_Investment_Amount((in_lakhs)`>0
union all
select `Amit_Investment_Amount(in_lakhs)` as investment,'Anupam' as sharkname from 
sharktank where `Amit_Investment_Amount(in_lakhs)`>0
union all
select `Ashneer_Investment_Amount` as investment,'Ashneer' as sharkname from 
sharktank where `Ashneer_Investment_Amount`>0
)k
group by sharkname;


--- 8.Develop a stored procedure that accepts inputs for the season number and the name 
--- of a shark.The procedure will then provide detailed insights into the total investment
--- made by that specific shark across different industries during the specified season.
--- Additionally, it will calculate the percentage of their investment in each sector 
---  relative to the total investment in that year, giving a comprehensive understanding 
---  of the shark investment distribution and impact.
DELIMITER //
create PROCEDURE getseasoninvestment(IN season INT, IN sharkname VARCHAR(100))
BEGIN
      
    CASE 

        WHEN sharkname = 'namita' THEN
            set @total = (select  sum(`Namita_Investment_Amount(in lakhs)`) from sharktank where Season_Number= season );
            SELECT Industry, sum(`Namita_Investment_Amount(in lakhs)`) as 'sum' ,(sum(`Namita_Investment_Amount(in lakhs)`)/@total)*100 as 'Percent' FROM sharktank WHERE season_Number = season AND `Namita_Investment_Amount(in lakhs)` > 0
            group by industry;
        WHEN sharkname = 'Vineeta' THEN
            SELECT industry,sum(`Vineeta_Investment_Amount(in_lakhs)`) as 'sum' FROM sharktank WHERE season_Number = season AND `Vineeta_Investment_Amount(in_lakhs)` > 0
            group by industry;
        WHEN sharkname = 'Anupam' THEN
            SELECT industry,sum(`Anupam_Investment_Amount(in_lakhs)`) as 'sum' FROM sharktank WHERE season_Number = season AND `Anupam_Investment_Amount(in_lakhs)` > 0
            group by Industry;
        WHEN sharkname = 'Aman' THEN
            SELECT industry,sum(`Aman_Investment_Amount(in_lakhs)`) as 'sum'  FROM sharktank WHERE season_Number = season AND `Aman_Investment_Amount(in_lakhs)` > 0
             group by Industry;
        WHEN sharkname = 'Peyush' THEN
             SELECT industry,sum(`Peyush_Investment_Amount(in_lakhs)`) as 'sum'  FROM sharktank WHERE season_Number = season AND `Peyush_Investment_Amount(in_lakhs)` > 0
             group by Industry;
        WHEN sharkname = 'Amit' THEN
              SELECT industry,sum(`Amit_Investment_Amount(in_lakhs)`) as 'sum'   WHERE season_Number = season AND `Amit_Investment_Amount(in_lakhs)` > 0
             group by Industry;
        WHEN sharkname = 'Ashneer' THEN
            SELECT industry,sum(`Ashneer_Investment_Amount`)  FROM sharktank WHERE season_Number = season AND `Ashneer_Investment_Amount` > 0
             group by Industry;
        ELSE
            SELECT 'Invalid shark name';
    END CASE;
    
END //
DELIMITER ;

drop procedure getseasoninvestment;
call getseasoninvestment(2, 'Namita');

--- 9.In the realm of venture capital, we're exploring which shark possesses the most diversified investment portfolio across various industries. 
--- By examining their investment patterns and preferences, we aim to uncover any discernible trends or strategies that may shed light on their decision-making
--- processes and investment philosophies.

select sharkname, 
count(distinct industry) as 'unique industy',
count(distinct concat(pitchers_city,' ,', pitchers_state)) as 'unique locations' 
from 
(
		SELECT Industry, Pitchers_City, Pitchers_State, 'Namita'  as sharkname 
        from sharktank where  `Namita_Investment_Amount(in lakhs)` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Vineeta'  as sharkname 
        from sharktank where `Vineeta_Investment_Amount(in_lakhs)` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Anupam'  as sharkname 
        from sharktank where  `Anupam_Investment_Amount(in_lakhs)` > 0 
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Aman'  as sharkname 
        from sharktank where `Aman_Investment_Amount(in_lakhs)` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Peyush'  as sharkname 
        from sharktank where   `Peyush_Investment_Amount((in_lakhs)` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Amit'  as sharkname 
        from sharktank where `Amit_Investment_Amount(in_lakhs)` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Anupam'  as sharkname 
        from sharktank where  `Anupam_Investment_Amount(in_lakhs)` > 0 
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Ashneer'  as sharkname 
        from sharktank where `Ashneer_Investment_Amount` > 0
)t  
group by sharkname 
order by  'unique industry' desc ,'unique location' desc;

