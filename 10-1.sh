#!/bin/bash
for ((i=11016; i<20000; i++))
do
		M2 --script MVTest10Vert.m2 $i
done
