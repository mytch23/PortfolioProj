Select *
From Portfolio..PlayerStats


--Looking at Points Scored per Minute
--Shows how prolific a scorer a player is when on the court

Select Player,MP, PPG,round((ppg/mp),3) as Simple_Scoring_Rate
From Portfolio..PlayerStats
Where [PLAYED %]>.5
--Where player plays in more than 50% of the games
Order by Simple_Scoring_Rate desc


--Looking at Shots taken per minute
--Shows how many shots taken when player is on the court

Select Player, MP,FGA,FTA, round((FGA+FTA)/mp,3) as Simple_Shooting_Rate
From Portfolio..PlayerStats
Where [PLAYED %]>.5
--Where player plays in more than 50% of the games
Order by Simple_Shooting_Rate desc


--Looking at which player had the most points per game on each team 

Select Team, MAX(ppg) as High_PPG
From Portfolio..PlayerStats
Where [PLAYED %]>.5
--Where player plays in more than 50% of the games
Group by Team
order by High_PPG desc


--Comparing scoring rate and shooting rate
--Shows how efficient a player is with their shot attempts
--Higher number= more efficient; Lower number= less efficient

Select Team,Player,PPG,[eFG%], round((ppg/mp),3) as Simple_Scoring_Rate,round((FGA+FTA)/mp,3) as Simple_Shooting_Rate ,round((ppg/mp)-(FGA+FTA)/mp,3)as Simple_Efficiency_Rating
From  Portfolio..PlayerStats
Where FGA>10 AND [PLAYED %]>.5
--Where player attempts at least 10 shots per game and plays in more than 50% of the games
order by Simple_Efficiency_Rating desc


--Looking at Player scoring compared to their team's Points per Game
--Shows which players scored the largest percentage of their team's points

Select team.Team,Player, PPG, round((PPG/PTS)*100,3) as Percentage_Points_Scored
From Portfolio..PlayerStats play 
Join Portfolio..TeamStats team
   on play.Team= team.Team
Order by Percentage_Points_Scored desc


--Looking at Total Team Salary

Select Team, Player, Salary, Pos, Sum(Salary) over (Partition by Team order by Player) as Rolling_Team_Salary
From Portfolio..Salary
where Salary is not null
order by 1 asc


--Looking to see if Player Salary relates to Player Effiency

Drop Table if exists #SalaryVsEfficiency
Create Table #SalaryVsEfficiency
(
Team nvarchar(255),
Player nvarchar(255),
PPG float,
Salary money,
Simple_Efficiency_Rating float,
Rolling_Team_Salary float
)

Insert into #SalaryVsEfficiency

Select play.Team, play.Player, play.PPG,sal.Salary, round((ppg/mp)-(FGA+FTA)/mp,3)as Simple_Efficiency_Rating,
Sum(sal.Salary) over (Partition by play.Team order by sal.salary) as Rolling_Team_Salary
From Portfolio..PlayerStats play 
Join Portfolio..Salary sal
   on play.Player= sal.Player
 
 Select *
 From #SalaryVsEfficiency


 Create view SalaryVsEfficiency as
 Select play.Team, play.Player, play.PPG,sal.Salary, round((ppg/mp)-(FGA+FTA)/mp,3)as Simple_Efficiency_Rating,
Sum(sal.Salary) over (Partition by play.Team order by sal.salary) as Rolling_Team_Salary
From Portfolio..PlayerStats play 
Join Portfolio..Salary sal
   on play.Player= sal.Player