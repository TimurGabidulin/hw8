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
function Ask_Name {
	local name
        	name=$(dialog --inputbox "Enter your name" --output-fd 1 0 0 ) || return 1
        	echo "$name"
}


function List_Cities {
	local city
	city=$(dialog --output-fd 1 --radiolist "Choose a city to depart" 0 0 7 a 'Portland' on b 'Sesttle' off c 'Los Angeles' off d 'Las Vegas' off e 'Denver' off f 'Chicago' off g 'New York' off) || return 1
	echo "$city"
	}

function Num_Bags {
	local bags
	bags=$(dialog --inputbox "Enter the amount of bags you are going to have" --output-fd 1 0 0 ) || return 1
	echo $bags
	
}


#Main function for Core functions
function main {
	local name
	local city
	local bags
	
	if ! name=$(Ask_Name); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	if ! city=$(List_Cities); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	if ! destination=$(local_destination); then
	clear
	echo "Cancelled" 
	return 1
	fi 
	
	
	if ! bags=$(Num_Bags); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	dialog --title "Confirmation" --ok-label "Confirm"  --msgbox " Name: $name \n Bags: $bags \n From: $city" 14 55
	
	clear
	
	
	
	echo "Hello, $name. You are departing from $city. To destination: $destination. You are going to have $bags bags"
}






#Calling
function main{
local user 
local city
local destination 
