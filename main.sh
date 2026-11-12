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


function Ask_Name {
	dialog --title "Informaion" --msgbox "This is a test" 0 0
}

function main {
	Ask_Name
	clear
}
main