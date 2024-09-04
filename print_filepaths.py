#!/usr/bin/python3
import sys,os

data = sys.stdin.read()

results = []
lines = data.split("\n")
for line in lines:
	line = line.strip()
	if "/" not in line:
		continue;
	line = line[line.find("/"):]
	if os.path.exists(line):
		results.append(line)

results = list(set(results))
for result in results:
	print(result)
