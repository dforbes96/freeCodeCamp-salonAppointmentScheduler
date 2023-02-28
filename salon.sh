#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon  --tuples-only -c"

#function displays services and prompts user to choose one
MENU(){
  # give services info
  SERVICE_INFO=$($PSQL "SELECT service_id, name FROM services") 
  echo -e "\nWhat can we do for you today?"
  echo "$SERVICE_INFO" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  #if selection is not a service avaiable
  if [[ $SERVICE_ID_SELECTED != [0-5] ]]
  then
    #display error message and show menu again
    echo -e "\nSorry, that item is unavialable."
    MENU
  fi

}

# function checks if customer already has information saved
CUSTOMER_DATA(){

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #if customer not saved in database
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME

    CUSTOMER_INFO=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    echo -e "\nWelcome back,$CUSTOMER_NAME."

  fi

}

SCHEDULE_TIME(){

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //')
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED?"
  read SERVICE_TIME

  echo -e "\nI have you put down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME,$CUSTOMER_NAME."
  SCHEDULE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
}


echo -e "\n~~Welcome to Mo's Beauty Shop~~\n"

MENU

CUSTOMER_DATA

SCHEDULE_TIME
