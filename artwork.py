#!/usr/bin/python
import sys,os
sizes = ['640x960','640x1136','768x1024','1536x2048','1024x768','2048x1536'];
icons = ['29x29','40x40', '58x58', '60x60', '76x76', '80x80', '120x120', '152x152'];

QUALITY=90
RADIUS=1.5
SIGMA=1.0
AMOUNT=1.7
THRESOLD=0.02

filename = sys.argv[1]

root = filename.split('.')

for s in sizes:
   os.system('convert -resize '+s+'\! -unsharp 1.5x1.0+1.7+0.02 -quality 90 -verbose '+filename+' '+root[0]+s+'.png ')

for s in icons:
   os.system('convert -resize '+s+'\! -unsharp 1.5x1.0+1.7+0.02 -quality 90 -verbose '+filename+' '+root[0]+s+'.png ')
