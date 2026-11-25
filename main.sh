#!/bin/bash

#########
# Student: Timur Gabidulin
# Student2: Alisha Rothe
# Assignment: Assignment 8:  A Traver Reservation System in Bash
# Class: CSE224
# Professor: Nicholas Macias

# Synopsis:
#	A bash script runs a travel reservation system entirely through dialog window.
#	It asks for the traveler's name, then shows a menu of at least seven departure cities,
# 	followed by a menu of destination cities. Two calendar dialogue collect the departure
#	and return dates, and a final prompt asks how many bags will be checked. The script
#	shows a summary of the trip.
#
#	The script checks res.txt in the current directory for an existing reservation under the
#	traveler's name. It matches only on the name. If it finds a match, it shows the old
#	reservation and asks whether to replace it. If the user chooses to replace it, the old
#	reservation is deleted and the new one is appended as a single line:

#	name| number of bags | departure city | destination city | departure date | return date

#########






#Ask_Name
# Show an input box asking for the traveler's name and returns it.
# Returns 1 if the user cancels.
function Ask_Name {
	local name
        	name=$(dialog --inputbox "Enter your name" --output-fd 1 0 0 ) || return 1
        	echo "$name"
}






#List_Cities
# Shows a radio list of seven departure cities and return the chose city.
# Returns 1 if the user cancels.
function List_Cities {
	local city
	local list_of_cities=("Portland" "Seattle" "Los Angeles" "Las Vegas" "Denver" "Chicago" "New York")
	local choices=()
	local departure

	for city in "${list_of_cities[@]}"; do
		choices+=("$city" "$city" off)
	done

	departure=$(dialog --output-fd 1 --radiolist "Choose a city to depart" 0 0 7 "${choices[@]}") || return 1

	echo "$departure"
}






#Destination_city
# Show a radio list of destination cities with the departure city removed,
# so a traveler cannot fly to the city they leave from.
# Returns the chosen city, or 1 if th euser cancels.
function Destination_city {
	local departure=$1
	local destination
	local list_of_cities=("Portland" "Seattle" "Los Angeles" "Las Vegas" "Denver" "Chicago" "New York")
	local choices=()
	
	for city in "${list_of_cities[@]}"; do
		if [ "$city" != "$departure" ]; then
			choices+=("$city" "$city" off)
		fi
	done
	
	destination=$(dialog --output-fd 1 --radiolist "Choose your destination" 0 0 6 "${choices[@]}") || return 1
	
	echo "$destination"
}






#Num_Bags
# Show an input box asking how many bags will be checked and returns the value entered. 
# Returns 1 if the user cancels.
function Num_Bags {
	local bags
	bags=$(dialog --inputbox "Enter the amount of bags you are going to have" --output-fd 1 0 0 ) || return 1
	echo $bags
	
}






#Departure_Date
# Shows a calendar dialog for the departure date. 
# It rejects any date before today and asks again until a valid date is chosen. 
# Returns 1 if the user cancels. 
function Departure_Date {
	local date today

	today=$(date +%Y%m%d)

	while true; do
		date=$(dialog --output-fd 1 --date-format "%Y%m%d" --calendar "Choose departure date" 0 0) || return 1

		if [ "$date" -ge "$today" ]; then
			echo "$date"
			break
		else
			dialog --output-fd 1 --title "Invalid date" --msgbox "Not allowing departure before today." 0 0
		fi
	done
}






#Return_Date
# Shows a calendat dialog for the return date.
# If rejects any date earlier than the departure date and asks again until a valid date is chosen. 
# Return 1 if the user cancels.
function Return_Date {
	local departure=$1
	local date

	while true; do
		date=$(dialog --output-fd 1 --date-format "%Y%m%d" --calendar "Choose your return date" 0 0) || return 1

		if [ "$date" -lt "$departure" ]; then
			dialog --output-fd 1 --title "Invalid date" --msgbox "Return date cannot be before departure!" 0 0
		else
			echo "$date"
			break
		fi
	done
}






#dateVisual
# Converts a date from YYYYMMDD to MM/DD/YYYY for display and storage.
function dateVisual {
	echo "$1" | sed 's/\(....\)\(..\)\(..\)/\2\/\3\/\1/'
}






#Search_Reservation
# Searches res.txt for a line starting with the given name 
# and print the matching reservation, if any. Matches on the name only.
function Search_Reservation {
	local name=$1

	grep "^$name|" res.txt
}






#Remove_Reservation
# Deletes any reservation in res.txt that matches the given name by rewriting the file without that line.
function Remove_Reservation {
	local name=$1

	grep -v "^$name|" res.txt > temp.txt
	mv temp.txt res.txt
}






#Existing_Reservation
# Splits an existing reservation record into its fields, displays it, and asks
# whether to Replace or Keep it. Returns 0 for Replace, 1 for Keep.
function Existing_Reservation {
	local record=$1
	local name
	local bags
	local dep_city
	local dest_city
	local dep_date
	local ret_date

	name=$(echo "$record"      | sed -E 's/^([^|]*).*/\1/')
	bags=$(echo "$record"      | sed -E 's/^([^|]*\|){1}([^|]*).*/\2/')
	dep_city=$(echo "$record"  | sed -E 's/^([^|]*\|){2}([^|]*).*/\2/')
	dest_city=$(echo "$record" | sed -E 's/^([^|]*\|){3}([^|]*).*/\2/')
	dep_date=$(echo "$record"  | sed -E 's/^([^|]*\|){4}([^|]*).*/\2/')
	ret_date=$(echo "$record"  | sed -E 's/^([^|]*\|){5}([^|]*).*/\2/')

	dialog --title "Existing reservation" --yes-label "Replace" --no-label "Keep" --yesno " You already have a reservation \n\n Name: $name \n Bags: $bags \n From: $dep_city \n To: $dest_city \n Departure: $dep_date \n Return: $ret_date \n\n Do you want to replace it?" 0 0
}






#put_into_a_file:
# Appends the reservation to res.txt as a single line.
function put_into_a_file {
	FILE="res.txt"

	local name=$1
	local bags=$2
	local dep_city=$3
	local dest_city=$4
	local dep_date=$5
	local ret_date=$6

	echo "$name|$bags|$dep_city|$dest_city|$dep_date|$ret_date" >> "$FILE"

	echo "Reservation save."
}






#############






#Main
# The program flow: creates res.txt if does not exist, asks for the name.
# Checks for an existing reservation, collects cities, bags, and dates.
# Shows a confirmation summary, prints the record to the terminal,
# removes the old reservation if it is being replaced, and saves the new one.
function main {
	#Variables
	local name
	local city
	local destination
	local bags
	local departure
	local returning
	local existing
	local replace=0

	#checks if file exists and if not it creates it
	if [ ! -f res.txt ]; then
		touch res.txt
	fi
	
	# 1.Ask Name
	if ! name=$(Ask_Name); then
		clear
		echo "Cancelled"
		return 1
	fi

	# 2.Check if the user already has a reservation
	existing=$(Search_Reservation "$name")

	if [ -n "$existing" ]; then
		if Existing_Reservation "$existing"; then
			replace=1
		else
			clear
			echo "Keeping your old reservation"
			echo "$existing"
			return 0
		fi
	fi
	
	# 3.Show list of cities to depart
	if ! city=$(List_Cities); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	# 4.Show list of cities to arrive
	if ! destination=$(Destination_city "$city"); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	# 5.Show the number of bags
	if ! bags=$(Num_Bags); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	# 6.show a calendar of departure dates
	if ! departure=$(Departure_Date); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	# 7.Show a calendar of return dates
	if ! returning=$(Return_Date "$departure"); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	
	# 8.Show all information the user inserted for confirmation
	dialog --title "Confirmation" --ok-label "Confirm"  --msgbox " Name: $name \n Bags: $bags \n From: $city \n To: $destination\n Departure: $(dateVisual "$departure")\n Return: $(dateVisual "$returning")" 0 0
	
	clear
	
	
	# 9.print all user input in the terminal
	echo "$name|$bags|$city|$destination|$(dateVisual "$departure")|$(dateVisual "$returning")"

	# 10.Save Reservation
	if [ "$replace" -eq 1 ]; then
		Remove_Reservation "$name"
	fi

	put_into_a_file "$name" "$bags" "$city" "$destination" "$(dateVisual "$departure")" "$(dateVisual "$returning")"

}






#Calling the main function
main
