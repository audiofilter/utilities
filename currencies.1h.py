#!/usr/bin/python
# -*- coding: utf-8 -*-
# <bitbar.title>Currency Tracker</bitbar.title>
# <bitbar.version>1.0</bitbar.version>
# <bitbar.author>Maxime Bertheau</bitbar.author>
# <bitbar.author.github>maxoumime</bitbar.author.github>
# <bitbar.desc>Keep an eye on the currencies you choose from your menu bar !</bitbar.desc>
# <bitbar.image>http://nothingreally.botler.me/bitbar.currency-tracker.png</bitbar.image>

import urllib2
import json

# Write here the currencies you want to see

# Base comparaison currency
currFrom = "USD"
# Array of tracked currencies
currTo = ["EUR", "GBP"]

urlParamTo = currTo[0]
if len(currTo) > 1:
    urlParamTo = ",".join(currTo)

url = "http://api.fixer.io/latest?base=" + currFrom + "&symbols=" + urlParamTo

result = urllib2.urlopen(url).read()

jsonCurr = json.loads(result)

rates = jsonCurr["rates"]
keys = rates.keys()

for key in reversed(keys):
    r = "%4.2f" % (int(100.0/rates[key])/100.0)
    print key + " $" + r

print "---"
print "From: " + currFrom
