#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

PROVIDE_INFO () {
  NUMBER="$1"
  SYMBOL="$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$1")"
  NAME="$($PSQL "SELECT name FROM elements WHERE atomic_number=$1")"
  TYPE="$($PSQL "SELECT type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1")"
  MASS="$($PSQL "SELECT atomic_mass FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1")"
  MELTING_POINT="$($PSQL "SELECT melting_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1")"
  BOILING_POINT="$($PSQL "SELECT boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1")"
  
  echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else

  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # find by atomic number
    NUMBER_FIND_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
    SYMBOL_FIND_RESULT=
    NAME_FIND_RESULT=
  else
    NUMBER_FIND_RESULT=    
    # find by symbol 
    SYMBOL_FIND_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
    # find by name
    NAME_FIND_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
  fi


  if [[ -z $NUMBER_FIND_RESULT ]]
  then
    if [[ -z $SYMBOL_FIND_RESULT ]]
    then
      if [[ -z $NAME_FIND_RESULT ]]
      then
        echo "I could not find that element in the database."
      else
        PROVIDE_INFO $NAME_FIND_RESULT
      fi
    else
      PROVIDE_INFO $SYMBOL_FIND_RESULT
    fi
  else
    PROVIDE_INFO $NUMBER_FIND_RESULT
  fi
fi