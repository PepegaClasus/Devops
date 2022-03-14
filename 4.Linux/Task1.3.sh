#! /bin/bash




echo "Enter a string "
while [ true ]
do
	read -t 5  string
if [ $? = 0 ]
then
	echo $string
	exit;
else
	echo "The time is over"
	exit;

fi

done
