#!/usr/bin/bash

. ~/.local/bin/SETTINGS.sh

now=$(date +%s)
sunset=$(date --date="$(sundial --lat="$latitude" --lon="$longitude" --sunset)" +%s)

if [ "$now" -ge "$sunset" ]; then
	feh --no-fehbg --bg-fill "$wp_nt" &
else
	DELAY="$(($sunset-$now))"
	feh --no-fehbg --bg-fill "$wp_dt" &
	(sleep "$DELAY" && feh --no-fehbg --bg-fill "$wp_nt") &
fi
