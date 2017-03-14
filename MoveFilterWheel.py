#!/usr/bin/python
# usage MoveFilterWheel.py position channel
import maestro
import sys
import argparse
import time
# parse input arguments
parser = argparse.ArgumentParser()
parser.add_argument('p', help='enter position', type=int)
parser.add_argument('c', help='enter channel', type=int)
args = parser.parse_args()
pos = args.p
chan = args.c
servo = maestro.Controller()
servo.setAccel(chan,4) # set acceleration
servo.setSpeed(chan,30) # set speed
servo.setTarget(chan,4000) # go to 4000
# time.sleep(10)
servo.setTarget(chan,pos) # move to filter pos
servo.close


