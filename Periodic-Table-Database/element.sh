#! /bin/bash

USERNAME=
PSQL="psql -tA --username=$USERNAME --dbname=periodic_table -c"

# check whether input is given
if [[ $1 ]]
then
  # check if input is number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  # check if input is symbol
  elif [[ $(echo -n $1 | wc -m) -le 2 ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
  # otherwise input is name
  else
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
  fi

  # if not found
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  else
    # get element info and print it to the user
    ELEMENT_INFO=$($PSQL "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
    FROM elements INNER JOIN properties USING(atomic_number) 
    INNER JOIN types USING(type_id) 
    WHERE atomic_number = $ATOMIC_NUMBER")

    IFS="|" read NAME SYMBOL TYPE MASS MELT_POINT BOIL_POINT <<< "$ELEMENT_INFO"

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
  fi
else
  echo "Please provide an element as an argument."
fi