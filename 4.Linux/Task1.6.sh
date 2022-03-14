#! /bin/bash

echo "Enter a string"
read string

if [ ${#string} = 1 ]
then

	case $string in
	[a-z])
		echo "LowerCase";;
	[A-Z])
		echo "UpperCase";;
	[0-9])
		echo "Digit";;
	' ')
		echo "Space";;
	*)
		echo "Punctuation";;
	esac

else

	echo "The length of string is not one"

fi
