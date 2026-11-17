#!/bin/bash

# 1. Dialog box to ask for the name.
# 2. List of cities to depart(include 7 or more cities).
# 3. Same list of cities which the traveler may be heading.
# 4. Calendar dialog with a leaving date.
# 5. Calendar dialog with a returning date.
# 6. Ask how many bags will be checking.

# 7. Display summary on the terminal
	# name | number of bags | departure city | destination city | departure date | return date

# 8. Find a file and search a user's name.
	# If already have a reservation, remove that reservation from the file.
#9. Add the user's reservation to the file. Store it as a single line:
	# name | number of bags | departure city | destination city | departure date | return date







#Implement required and bonus functions

# Show user input where they put their name
function Ask_Name {
	local name
        	name=$(dialog --inputbox "Enter your name" --output-fd 1 0 0 ) || return 1
        	echo "$name"
}

#show a list of cities to depart from
function List_Cities {
	local city
	city=$(dialog --output-fd 1 --radiolist "Choose a city to depart" 0 0 7 Portland Portland off Seattle Seattle off 'Los Angeles' 'Los Angeles' off 'Las Vegas' 'Las Vegas' off Denver Denver off Chicago Chicago off 'New York' 'New York' off) || return 1
	echo "$city"
	}

#show a list of cities to arrive
function Destination_city {
	local destination
	destination=$(dialog --output-fd 1 --radiolist "Choose your destination" 0 0 7 Portland Portland off Seattle Seattle off 'Los Angeles' 'Los Angeles' off 'Las Vegas' 'Las Vegas' off Denver Denver off Chicago Chicago off 'New York' 'New York' off) || return 1
	echo "$destination"
}

#ask the user the amount of bags they are going  to have
function Num_Bags {
	local bags
	bags=$(dialog --inputbox "Enter the amount of bags you are going to have" --output-fd 1 0 0 ) || return 1
	echo $bags
	
}

#ask the user the date they want to depart using a calendar interface
function Departure_Date {
	local date
	date=$(dialog --calendar "Choose your departure date" 0 0 --output-fd 1) || return 1
	echo "$date"
}

#ask the user the date the want to return using a calendar interface
function Return_Date {
	local date
	date=$(dialog --calendar "Choose your return date" 0 0 --output-fd 1) || return 1
	echo "$date"
}


function Search_Reservation {
	local name=$1
	
	grep "^$name|" res.txt
}

# removes the old reservation if the name already exists
function Remove_Reservation {
	local name=$1

	grep -v "^$name" res.txt > temp.txt 
	mv temp.txt res.txt
}

#store all information into a file
function put_into_a_file {
	FILE="res.txt"

	local name=$1
	local bags=$2
	local dep_city=$3
	local dest_city=$4
	local dep_date=$5
	local ret_date=$6

	echo "$name | $bags | $dep_city | $dest_city | $dep_date | $ret_date" >> "$FILE"

	echo "Reservation save."
}


#Main function for Core functions
function main {
	#Variables
	local name
	local city
	local destination
	local bags
	local departure
	local returning

	#checks if file exists and if not it creates it
	if [ ! -f res.txt ]; then
		touch res.txt
	fi
	
	#Ask Name
	if ! name=$(Ask_Name); then
		clear
		echo "Cancelled"
		return 1
	fi

	#Search for existing reservation
	if Search_Rservation "$name"; then
		Remove_Reservation "$name"
	fi
	
	#Show list of cities to depart
	if ! city=$(List_Cities); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	#Show list of cities to arrive
	if ! destination=$(Destination_city); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	#show the number of bags
	if ! bags=$(Num_Bags); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	#show a calendar of departure dates
	if ! departure=$(Departure_Date); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	#show a calendar of return dates
	if ! returning=$(Return_Date); then
		clear
		echo "Cancelled"
	fi
	
	
	#show all information the user inserted for confirmation
	dialog --title "Confirmation" --ok-label "Confirm"  --msgbox " Name: $name \n Bags: $bags \n From: $city \n To: $destination\n Departure: $departure\n Return: $returning" 0 0
	
	clear
	
	
	#print all user input in the terminal
	echo "$name | $bags | $city | $destination | $departure | $returning"

	#Save Reservatin
	put_into_a_file "$name" "$bags" "$city" "$destinatin" "$departure" "$returning"
}






#Calling
main
