#!/usr/bin/python
# usage MoveFilterWheel.py position channel offset
import maestro
import sys
import argparse
import time
# parse input arguments
parser = argparse.ArgumentParser()
parser.add_argument('p', help='enter position', type=int)
parser.add_argument('c', help='enter channel', type=int)
parser.add_argument('o', help='enter park position', type=int)
args = parser.parse_args()
pos = args.p
chan = args.c
park = args.o
servo = maestro.Controller()
servo.setAccel(chan,2) # set acceleration
servo.setSpeed(chan,25) # set speed
#servo.setTarget(chan,park) # go to park position
time.sleep(3)
servo.setTarget(chan,pos) # move to filter pos
servo.close


