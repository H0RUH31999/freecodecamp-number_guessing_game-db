#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

echo "Enter your username:"
read USERNAME

DOES_USER_EXIST=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
NUMBER_OF_GAMES=$($PSQL "SELECT COUNT(*) FROM users FULL JOIN games USING(user_id) WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM users INNER JOIN games USING(user_id) WHERE username='$USERNAME'")

if [[ -z $DOES_USER_EXIST ]]
  then
    USERNAME_INSERT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    echo "Welcome back, $USERNAME! You have played $NUMBER_OF_GAMES games, and your best game took $BEST_GAME guesses."
fi

NUMBER_TO_GUESS=$((1 + $RANDOM % 1000))
ATTEMPTS=1
echo "Guess the secret number between 1 and 1000:"

while read INPUT
  do
    if [[ ! $INPUT =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
      else
        if [[ $INPUT -eq $NUMBER_TO_GUESS ]]
          then
            break;
          else 
            if [[ $INPUT -gt $NUMBER_TO_GUESS ]]
              then
                echo -n "It's lower than that, guess again:"
              elif [[ $INPUT -lt $NUMBER_TO_GUESS ]]
                then
                  echo -n "It's higher than that, guess again:"
            fi
        fi
    fi

    ATTEMPTS=$(( $ATTEMPTS + 1 ))
  done

echo "You guessed it in $ATTEMPTS tries. The secret number was $NUMBER_TO_GUESS. Nice job!"

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
GAME_INSERT=$($PSQL "INSERT INTO games(number_of_guesses, user_id) VALUES($ATTEMPTS, $USER_ID)")
