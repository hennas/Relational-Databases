#!/bin/bash

USERNAME=
PSQL="psql -tA -U $USERNAME -d number_guess -c"
RANDOM_TO_GUESS=$(($RANDOM % 1000))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")

# if user not found
if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES ('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")

  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  GAME_INFO=$($PSQL "SELECT COUNT(*), MIN(total_guesses) FROM games INNER JOIN users USING(user_id) WHERE user_id = $USER_ID")
  IFS="|" read TOTAL_GAMES TOTAL_GUESSES <<< "$GAME_INFO"
  
  echo -e "\nWelcome back, $USERNAME! You have played $TOTAL_GAMES games, and your best game took $TOTAL_GUESSES guesses."
fi

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id) VALUES ($USER_ID)")
GAME_ID=$($PSQL "SELECT game_id
FROM games AS g 
INNER JOIN (SELECT user_id, MAX(start_time) AS max_time
            FROM games
            GROUP BY user_id) AS t
ON g.user_id = t.user_id AND g.start_time = t.max_time
WHERE g.user_id = $USER_ID ")
TOTAL_GUESSES=0 

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

while true
do
  ((TOTAL_GUESSES+=1))
  # if guess is not an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
  # if guess is greater than the random number
  elif [[ $GUESS -gt $RANDOM_TO_GUESS ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    read GUESS
  # if guess is lower than the random number
  elif [[ $GUESS -lt $RANDOM_TO_GUESS ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    read GUESS
  # if guess is correct
  else
    UPDATE_GAME_RESULT=$($PSQL "UPDATE games SET end_time = NOW(), total_guesses = $TOTAL_GUESSES WHERE game_id = $GAME_ID")
    echo -e "\nYou guessed it in $TOTAL_GUESSES tries. The secret number was $RANDOM_TO_GUESS. Nice job!"
    break
  fi
done