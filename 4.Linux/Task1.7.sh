#! /bin/zsh

echo "Enter a metres"
read num

echo $(echo "$num/1609" | bc -l )
