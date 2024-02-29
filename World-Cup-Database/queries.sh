#! /bin/bash

USERNAME=
PSQL="psql --username=$USERNAME --dbname=worldcup --no-align --tuples-only -c"

echo -e "\nTotal number of goals in all games from winning teams:"
echo "$($PSQL "SELECT SUM(winner_goals) FROM games")"

echo -e "\nTotal number of goals in all games from both teams combined:"
echo "$($PSQL "SELECT SUM(winner_goals + opponent_goals) FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams:"
echo "$($PSQL "SELECT AVG(winner_goals) FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams rounded to two decimal places:"
echo "$($PSQL "SELECT ROUND(AVG(winner_goals), 2) FROM games")"

echo -e "\nAverage number of goals in all games from both teams:"
echo "$($PSQL "SELECT AVG(winner_goals + opponent_goals) FROM games")"

echo -e "\nMost goals scored in a single game by one team:"
echo "$($PSQL "SELECT MAX(winner_goals) FROM games")"
# WITH max_goals AS (SELECT MAX(winner_goals) AS m FROM games 
# UNION SELECT MAX(opponent_goals) AS m FROM games) SELECT MAX(m) FROM max_goals;

echo -e "\nNumber of games where the winning team scored more than two goals:"
echo "$($PSQL "SELECT COUNT(*) FROM games WHERE winner_goals > 2")"

echo -e "\nWinner of the 2018 tournament team name:"
echo "$($PSQL "SELECT t.name FROM teams AS t
INNER JOIN games AS g ON t.team_id=g.winner_id 
WHERE g.year = 2018 AND g.round = 'Final'")"

echo -e "\nList of teams who played in the 2014 'Eighth-Final' round:"
echo "$($PSQL "SELECT t.name AS team_name FROM teams AS t 
INNER JOIN games AS g ON t.team_id=g.winner_id 
WHERE g.year = 2014 AND g.round = 'Eighth-Final' 
UNION 
SELECT t.name AS team_name FROM teams AS t 
INNER JOIN games AS g ON t.team_id=g.opponent_id 
WHERE g.year = 2014 AND g.round = 'Eighth-Final' 
ORDER BY team_name")"

echo -e "\nList of unique winning team names in the whole data set:"
echo "$($PSQL "SELECT DISTINCT(t.name) AS unique_names FROM teams AS t 
INNER JOIN games AS g ON t.team_id=g.winner_id 
ORDER BY unique_names")"

echo -e "\nYear and team name of all the champions:"
echo "$($PSQL "SELECT g.year, t.name FROM teams AS t 
INNER JOIN games AS g ON t.team_id=g.winner_id 
WHERE g.round = 'Final' ORDER BY g.year")"

echo -e "\nList of teams that start with 'Co':"
echo "$($PSQL "SELECT name FROM teams WHERE name LIKE 'Co%'")"
