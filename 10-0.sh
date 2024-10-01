#!/bin/bash
for ((i=1016; i<10000; i++))
do
		M2 --script MVTest10Vert.m2 $i
done
