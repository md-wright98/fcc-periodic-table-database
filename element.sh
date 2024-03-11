#!/bin/bash

# script to lookup a periodic table element in the database by its name, symbol or atomic number and return relevant information about the element.

# Create PSQL variable for SQL queries
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align --tuples-only -c"

PERIODIC_TABLE() {

# error message if no argument is provided to the function
  if [[ -z $1 ]]
  then
    echo Please provide an element as an argument.
    exit
  else 
    SELECTED_ELEMENT=$1
    # look up element in database
    # if argument is a number then search for atomic_number in elements table
    if [[ $SELECTED_ELEMENT =~ ^[0-9]+$ ]]
    then
      ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements AS e JOIN properties AS p ON p.atomic_number = e.atomic_number JOIN types AS t ON p.type_id = t.type_id WHERE e.atomic_number = $SELECTED_ELEMENT")
    # if argument not a number, search for symbol or name in elements table
    else
      ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements AS e JOIN properties AS p ON p.atomic_number = e.atomic_number JOIN types AS t ON p.type_id = t.type_id WHERE e.symbol = '$SELECTED_ELEMENT' OR e.name = '$SELECTED_ELEMENT'")
    fi
    # if no element is retrieved
    if [[ -z $ELEMENT ]]
    # print error message
    then
      echo I could not find that element in the database.
    else
      IFS="|"
      echo "$ELEMENT" | while read ATOMIC_NUMBER SYMBOL NAME TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
      do
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      done
    fi
  fi

}

PERIODIC_TABLE $1