#!/bin/sh
PID=`pgrep $1`
if [ -n "$PID" ]; then
    while ps -p $PID > /dev/null;
        do sleep 1;
    done;
else
    >&2 echo "Could not find process \"$1\"";
fi
