#!/bin/bash

# Shows last BTC price (in USD) on Bitstamp exchange.
#
# <bitbar.title>Bitstamp last price plugin</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Damien Lajarretie</bitbar.author>
# <bitbar.author.github>dlajarretie</bitbar.author.github>
# <bitbar.desc>Shows last BTC price (in USD) on Bitstamp exchange.</bitbar.desc>
# <bitbar.image>http://i.imgur.com/aQCqOW6.png</bitbar.image>
#
# by Damien Lajarretie
# Based on Coinbase bitbar plugin by Mat Ryer

echo -n "BTC $"; curl -s "https://www.bitstamp.net/api/ticker/" | egrep -o '"last": "[0-9]+(\.)?([0-9]{0,2}")?' | sed 's/"last": //' | sed 's/\"//g'
echo -n "𝚵 $"; curl -s "https://coinmarketcap-nexuist.rhcloud.com/api/eth/price" | egrep -o '"usd":[0-9]+(\.)?([0-9]{2})?' | sed 's/"usd":/ /' | sed 's/\"//g'
echo -n "XMR $"; curl -s "https://coinmarketcap-nexuist.rhcloud.com/api/xmr/price" | egrep -o '"usd":[0-9]+(\.)?([0-9]{2})?' | sed 's/"usd":/ /' | sed 's/\"//g'
