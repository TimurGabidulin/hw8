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





#show a list of cities to depart from
function List_Cities {
	local city
	city=$(dialog --output-fd 1 --radiolist "Choose a city to depart" 0 0 7 Portland Portland off Seattle Seattle off 'Los Angeles' 'Los Angeles' off 'Las Vegas' 'Las Vegas' off Denver Denver off Chicago Chicago off 'New York' 'New York' off) || return 1
	echo "$city"
	}




#show a list of cities to arrive implemented bonus feature remove departure from destination choices
function Destination_city {
	local city=$1
	local destination

	case "$city" in
		Portland)
			destination=$(dialog --output-fd 1 --radiolist "Choose your destination" 0 0 6 Seattle Seattle off 'Los Angeles' 'Los Angeles' off 'Las Vegas' 'Las Vegas' off Denver Denver off Chicago Chicago off 'New York' 'New York' off) || return 1
			;;
		Seattle)
			destination=$(dialog --output-fd 1 --radiolist "Choose destination" 0 0 6 Portland Portland off 'Los Angeles' 'Los Angeles' off 'Las Vegas' 'Las Vegas' off Denver Denver off Chicago Chicago off 'New York' 'New York' off) || return 1
            ;;

        'Los Angeles')
            destination=$(dialog --output-fd 1 --radiolist "Choose destination" 0 0 6 Portland Portland off Seattle Seattle off 'Las Vegas' 'Las Vegas' off Denver Denver off Chicago Chicago off 'New York' 'New York' off) || return 1
            ;;

        'Las Vegas')
            destination=$(dialog --output-fd 1 --radiolist "Choose destination" 0 0 6 Portland Portland off Seattle Seattle off 'Los Angeles' 'Los Angeles' off Denver Denver off Chicago Chicago off 'New York' 'New York' off) || return 1
            ;;

        Denver)
            destination=$(dialog --output-fd 1 --radiolist "Choose destination" 0 0 6 Portland Portland off Seattle Seattle off 'Los Angeles' 'Los Angeles' off 'Las Vegas' 'Las Vegas' off Chicago Chicago off 'New York' 'New York' off) || return 1
            ;;

        Chicago)
            destination=$(dialog --output-fd 1 --radiolist "Choose destination" 0 0 6 Portland Portland off Seattle Seattle off 'Los Angeles' 'Los Angeles' off 'Las Vegas' 'Las Vegas' off Denver Denver off 'New York' 'New York' off) || return 1
            ;;

        'New York')
            destination=$(dialog --output-fd 1 --radiolist "Choose destination" 0 0 6 Portland Portland off Seattle Seattle off 'Los Angeles' 'Los Angeles' off 'Las Vegas' 'Las Vegas' off Denver Denver off Chicago Chicago off) || return 1
            ;;
	
	esac
	echo "$destination"
}



#ask the user the amount of bags they are going  to have
function Num_Bags {
	local bags
	bags=$(dialog --inputbox "Enter the amount of bags you are going to have" --output-fd 1 0 0 ) || return 1
	echo $bags
	
}


function To_Ymd {
	local date_text=$1
	
	local day=${date_text:0:2}
	local month=${date_text:3:2}
	local year=${date_text:6:4}
	
	echo "$year$month$day"
}


#ask the user the date they want to depart using a calendar interface implement bonus feature
function Departure_Date {
	local date
	local today

	today=$(date "+%Y%m%d")

	while true; do
		date=$(dialog --output-fd 1 --calendar "Choose departure date" 0 0) || return 1

		if [ "$(To_Ymd "$date")" -ge "$today" ]; then
			echo "$date"
			break
		else
			dialog --msgbox "Not allowing departure before today." 0 0 >/dev/tty
		fi
	done
}




#ask the user the date the want to return using a calendar interface
function Return_Date {
	local departure=$1
	local date

	while true; do
		date=$(dialog --output-fd 1 --calendar "Choose your return date" 0 0) || return 1

		if [ "$(To_Ymd "$date")" -lt "$(To_Ymd "$departure")" ]; then
			dialog --msgbox "Return date cannot be before departure!" 0 0 >/dev/tty
		else
			echo "$date"
			break
		fi
	done
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
	
	# 1.Ask Name
	if ! name=$(Ask_Name); then
		clear
		echo "Cancelled"
		return 1
	fi

	# 2.Search for existing reservation
	if Search_Reservation "$name"; then
		Remove_Reservation "$name"
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
	dialog --title "Confirmation" --ok-label "Confirm"  --msgbox " Name: $name \n Bags: $bags \n From: $city \n To: $destination\n Departure: $departure\n Return: $returning" 0 0
	
	clear
	
	
	# 9.print all user input in the terminal
	echo "$name | $bags | $city | $destination | $departure | $returning"

	# 10.Save Reservation
	put_into_a_file "$name" "$bags" "$city" "$destination" "$departure" "$returning"
}




#Calling
main
