#! /bin/bash

ones=0
twos=0
threes=0
fours=0
fives=0
sixes=0
for i in {1..700}
do
	x=$(($RANDOM % 6 + 1))
	
	case $x in
	1)
	ones=$((ones+1));;
	2)
	twos=$((twos+1));;
	3)
	threes=$((threes+1));;
	4)
	fours=$((fours+1));;
	5)
	fives=$((fives+1));;
	6)
	sixes=$((sixes+1));;

	esac
done

echo "единиц = $ones"
echo "двоек = $twos"
echo "троек = $threes"
echo "четверок = $fours"
echo "пятерок = $fives"
echo "шестерок = $sixes"



