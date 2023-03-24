#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ The Salon ~~\n"


MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
 

  echo -e "How may I help you?\n"
  #want to add a "more" option
  # do i need to _automatically_ insert list numbers by their service_id?
  #echo -e "\n1) Haircut\n2) Shave\n3) Haircut & Shave\n4) Cleanup\n"  #\n4. More Options
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | sed 's/ |/)/g'
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    #is there a more efficient way to do this?
    1) APPOINTMENT_MENU ;;
    2) APPOINTMENT_MENU ;;
    3) APPOINTMENT_MENU ;;
    4) APPOINTMENT_MENU ;;
    # 00 will redo this with a new database 00
    # want to do a "more menu" option
    # 4) MORE_MENU ;;
    *) MAIN_MENU "Please select a valid option." ;;
  esac
}

# 00 prolly need to reoorg tree — right now, I have separate menus for each service, as in the bike exercise. But I should actually set it up so that any valid result opens the services menu 00
APPOINTMENT_MENU(){
  echo -e "\nAppointment Details\n"

  echo -e "\nPlease enter your phone number."
  read CUSTOMER_PHONE
  # check customer_id
  GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if not there
  if [[ -z $GET_CUSTOMER_ID ]]
  then
    # ask to enter name
    echo -e "\nOur records show that you are a new customer. Please enter your name below."
    read CUSTOMER_NAME
    # insert to customers table
    ADD_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
 
  # get customer ID
  GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  echo -e "\nOk, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g'), when would you like your appointment to be?"
  read SERVICE_TIME

  # insert entry into appointments calendar with service_id, customer_id, and appointment time
  ADD_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$GET_CUSTOMER_ID', '$SERVICE_ID_SELECTED','$SERVICE_TIME')")
  GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

  #confirm the appointment
  # echo "Ok, $(echo $GET_CUSTOMER_NAME | sed -E 's/^ *| *$//g'), you are confirmed."
  echo -e "\nI have put you down for a $(echo $GET_SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}

MAIN_MENU
