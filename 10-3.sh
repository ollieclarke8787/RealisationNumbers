#!/bin/bash
for ((i=31036; i<40000; i++))
do
		M2 --script MVTest10Vert.m2 $i
done
