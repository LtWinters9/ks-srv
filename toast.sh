#!/bin/bash

set -e 

while true; do

read -p "Do you want to proceed? (yes/no) " yn

case $yn in 
	yes ) echo ok, we will proceed;
		break;;
	no ) echo Aborted... ; exit 1;;
	* ) echo invalid response;;
esac

done
