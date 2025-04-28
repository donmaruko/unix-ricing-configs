#!/bin/bash

# Night Shift settings
nightTempLow=4500
nightTempHigh=5800
nightGamma=1

if pgrep -x "wlsunset" > /dev/null
then
    killall wlsunset
else
    wlsunset -t $nightTempLow -T $nightTempHigh -g $nightGamma &
fi

