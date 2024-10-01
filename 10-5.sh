#!/bin/bash
for ((i=51026; i<60000; i++))
do
		M2 --script MVTest10Vert.m2 $i
done
