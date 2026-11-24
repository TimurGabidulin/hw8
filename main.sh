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
#	The script checks res.txt in the currecnt directory for an existing reservation under the
#	traveler's name. It matches only on the name. If it finds a match, it deletes that old
#	reservation, then appends the new one as a single line.

#	name| number of bags | departure city | destination city | departure date | return date

#########






# Show user input where they put their name
function Ask_Name {
	local name
        	name=$(dialog --inputbox "Enter your name" --output-fd 1 0 0 ) || return 1
        	echo "$name"
}






#Show a list of cities to depart from
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






#Show a list of cities to arrive implemented bonus feature remove departure from destination choices
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






#Ask the user the amount of bags they are going  to have
function Num_Bags {
	local bags
	bags=$(dialog --inputbox "Enter the amount of bags you are going to have" --output-fd 1 0 0 ) || return 1
	echo $bags
	
}






#Ask the user the date they want to depart using a calendar interface implement bonus feature
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






#Ask the user the date the want to return using a calendar interface
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






# Change the visual of a date to print like DD/MM/YYYY instead of YYYYMMDD
function dateVisual {
	echo "$1" | sed 's/\(....\)\(..\)\(..\)/\2\/\3\/\1/'
}





#Search for a reservation with the same name
function Search_Reservation {
	local name=$1

	grep "^$name|" res.txt
}






#Remove the old reservation if the name already exists
function Remove_Reservation {
	local name=$1

	grep -v "^$name|" res.txt > temp.txt
	mv temp.txt res.txt
}






#Show the old reservation and ask if the user wants to replace it
function Existing_Prompt {
	local record=$1
	local name
	local bags
	local dep_city
	local dest_city
	local dep_date
	local ret_date

	name=$(echo "$record" | cut -d'|' -f1)
	bags=$(echo "$record" | cut -d'|' -f2)
	dep_city=$(echo "$record" | cut -d'|' -f3)
	dest_city=$(echo "$record" | cut -d'|' -f4)
	dep_date=$(echo "$record" | cut -d'|' -f5)
	ret_date=$(echo "$record" | cut -d'|' -f6)

	dialog --title "Existing reservation" --yes-label "Replace" --no-label "Keep" --yesno " You already have a reservation \n\n Name: $name \n Bags: $bags \n From: $dep_city \n To: $dest_city \n Departure: $dep_date \n Return: $ret_date \n\n Do you want to replace it?" 0 0
}






#Store all information into a file
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



#Main function for Core functions
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
		if Existing_Prompt "$existing"; then
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




#Calling
main
