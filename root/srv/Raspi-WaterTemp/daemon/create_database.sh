#!/bin/bash
DIR="/srv/Raspi-WaterTemp/www/graphs"

# Per Second, Store for 1 hour.
# Per Minute, Store for 3 days.
rrdtool create ${DIR}/watertemp.rrd \
--start now-1m \
--step 1 \
DS:temp:GAUGE:10:U:U \
DS:targ:GAUGE:10:U:U \
RRA:AVERAGE:0.5:1:3600 \
RRA:MIN:0.5:1:3600 \
RRA:MAX:0.5:1:3600 \
RRA:AVERAGE:0.5:60:4400 \
RRA:MIN:0.5:60:4400 \
RRA:MAX:0.5:60:4400 \
