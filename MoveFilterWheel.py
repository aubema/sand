#!/usr/local/bin/python
# usage MoveFilterWheel.py position channel
import maestro
pos = input()
chan = input()
servo = maestro.Controller()
servo.setAccel(chan,4) # set acceleration
servo.setSpeed(chan,4) # set speed
servo.setTarget(chan,4000) # go to 4000
servo.setTarget(chan,pos) # move to filter pos
servo.close


