#!/bin/bash
DIR="/srv/Raspi-WaterTemp/www/graphs"

# Per Second, Store for 15 min.
# Per Minute, Store for 3 days.
rrdtool create ${DIR}/watertemp.rrd \
--start now-1m \
--step 1 \
DS:temp:GAUGE:15:U:U \
RRA:AVERAGE:0.5:1:900 \
RRA:AVERAGE:0.5:60:3600 \
RRA:MIN:0.5:60:4400 \
RRA:MAX:0.5:60:4400 \
