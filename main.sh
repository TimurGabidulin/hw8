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
        	name=$(dialog --inputbox "Enter your name" --output-fd 1 0 0)
        	echo "$name"
}


function List_Cities {
	local city
	cities=$(dialog --output-fd 1 --radiolist "Choose a city to depart" 0 0 3 a 'City 1' on b 'City 2' off c 'City 3' off)
	
	
}



#Main function for Core functions
function main {
	local user
	local cities
	
	if ! user=$(Ask_Name); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	if ! city=$(List_Cities); then
		clear
		echo "Cancelled"
		return 1
	fi
	
	clear
	echo "Hello, $user. You are departing from $city."
}






#Calling
main