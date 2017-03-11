#!/bin/bash
DIR="/srv/Raspi-WaterTemp/www/graphs"

#Short
rrdtool graph ${DIR}/temp_short.png \
--title="Water Tempurature - Last 15Min" \
--vertical-label="Degrees (C)" \
--width 500 \
--height 200 \
--start -15minutes \
--end now \
--x-grid MINUTE:1:MINUTE:5:MINUTE:5:0:%X \
--y-grid 0.25:4 \
--watermark "Raspi-WaterTemp" \
DEF:tmin=${DIR}/watertemp.rrd:temp:MIN \
DEF:tmax=${DIR}/watertemp.rrd:temp:MAX \
DEF:tave=${DIR}/watertemp.rrd:temp:AVERAGE \
CDEF:tdif='tmax,tmin,-' \
HRULE:$(cat ${DIR}/targettemp.txt)#000000FF:' ' \
COMMENT:'Set Temp \: '$(cat ${DIR}/targettemp.txt)' C\n' \
AREA:tmin#FFFFFFFF:'' \
AREA:tdif#7f000066:'':STACK \
LINE1:tmin#7f000066:'' \
LINE1:tmax#7f000066:' ' \
GPRINT:tmax:MAX:'Peak\:%8.1lf C\n' \
LINE2:tave#7f0000ff:' ' \
GPRINT:tave:LAST:'Current\:%8.1lf C' \
GPRINT:tave:AVERAGE:'Average\:%8.1lf C' \
GPRINT:tave:MIN:'Min\:%8.1lf C\n' \
> /dev/null 2>&1

#Long
rrdtool graph ${DIR}/temp_long.png \
--title="Water Tempurature - Last 24H" \
--vertical-label="Degrees (C)" \
--width 500 \
--height 200 \
--start -24hours \
--end now \
--x-grid HOUR:1:HOUR:4:HOUR:4:0:%X \
--y-grid 0.25:4 \
--watermark "Raspi-WaterTemp" \
DEF:tmin=${DIR}/watertemp.rrd:temp:MIN \
DEF:tmax=${DIR}/watertemp.rrd:temp:MAX \
DEF:tave=${DIR}/watertemp.rrd:temp:AVERAGE \
CDEF:tdif='tmax,tmin,-' \
HRULE:$(cat ${DIR}/targettemp.txt)#000000FF:' ' \
COMMENT:'Set Temp \: '$(cat ${DIR}/targettemp.txt)' C\n' \
AREA:tmin#FFFFFFFF:'' \
AREA:tdif#7f000066:'':STACK \
LINE1:tmin#7f000066:'' \
LINE1:tmax#7f000066:' ' \
GPRINT:tmax:MAX:'Peak\:%8.1lf C\n' \
LINE2:tave#7f0000ff:' ' \
GPRINT:tave:LAST:'Current\:%8.1lf C' \
GPRINT:tave:AVERAGE:'Average\:%8.1lf C' \
GPRINT:tave:MIN:'Min\:%8.1lf C\n' \
> /dev/null 2>&1
