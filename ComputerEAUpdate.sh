#!/bin/bash

# Name: ComputerEAUpdate.sh
# Date: 05-29-2022
# Author: Michael Permann
# Version: 1.0
# Purpose: Updates text field computer extension attribute of computer record using computer serial 
# number and value from comma separated text file. The text file of computer serial numbers and extension 
# attribute values can be provided interactively.
# Usage: ComputerEAUpdate.sh "Computer_EA_Name" "/path/to/csv/of/computer/serial/numbers/and/ea/values"

APIUSER="user"
APIPASS="pass"
JPSURL="https://jss.url:8443"
EA_NAME=$1
IMPORTLIST=$2
XML=""
declare -a SERIAL_NUM_ARRAY
SERIAL_NUM_ARRAY=()
declare -a EA_VALUE_ARRAY
EA_VALUE_ARRAY=()

while IFS=, read -r SERIAL_NUM EA_VALUE
do
  SERIAL_NUM_ARRAY+=("$SERIAL_NUM")
  EA_VALUE_ARRAY+=("$EA_VALUE")
done < "$IMPORTLIST"
echo "Size of serial num array: ${#SERIAL_NUM_ARRAY[@]}"
echo "Size of EA value array  : ${#EA_VALUE_ARRAY[@]}"
echo "Array of serial nums:" "${SERIAL_NUM_ARRAY[@]}"
echo "Array of EA values  :" "${EA_VALUE_ARRAY[@]}"
echo -e "\n"

for ((i = 0; i < ${#SERIAL_NUM_ARRAY[@]}; i++))
do
  echo "Serial_Number,EA_Value,Array_Index"
  echo "${SERIAL_NUM_ARRAY[$i]},${EA_VALUE_ARRAY[$i]},$i"
  XML="<computer><extension_attributes><extension_attribute><name>$EA_NAME</name><value>${EA_VALUE_ARRAY[$i]}</value></extension_attribute></extension_attributes></computer>"
  echo "XML to send to Jamf Pro"
  echo "$XML"
  curl -s -k -u "${APIUSER}":"${APIPASS}" "${JPSURL}/JSSResource/computers/serialnumber/${SERIAL_NUM_ARRAY[$i]}" -X PUT -H Content-type:application/xml --data "$XML"
  echo -e "\n"
done
