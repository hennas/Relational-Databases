#! /bin/bash

USERNAME=
PSQL="psql -tA --username=$USERNAME --dbname=salon -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SCHEDULE_APPOINTMENT() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # print services
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  # get service selection
  read SERVICE_ID_SELECTED
  # check if number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SCHEDULE_APPOINTMENT "That is not a valid number. What would you like today?"
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if service not found
    if [[ -z $SERVICE_NAME ]] 
    then
      SCHEDULE_APPOINTMENT "I could not find that service. What would you like today?"
    else
      # get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if customer not found
      if [[ -z $CUSTOMER_ID ]] 
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      fi
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # get time
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # add appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

SCHEDULE_APPOINTMENT