
# ╔╦╗ ╦ ╦ ╔═╗ ╦ ╔═╗
# ║║║ ║ ║ ╚═╗ ║ ║  
# ╩ ╩ ╚═╝ ╚═╝ ╩ ╚═╝

# author	Niraj
# github	niraj998

# ┌─┐┌─┐┌┐┌┌─┐┬┌─┐┬ ┬┬─┐┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
# │  │ ││││├┤ ││ ┬│ │├┬┘├─┤ │ ││ ││││└─┐
# └─┘└─┘┘└┘└  ┴└─┘└─┘┴└─┴ ┴ ┴ ┴└─┘┘└┘└─┘

# uncomment your music players below.
# 

Control="MPD"
[ -n "$(pgrep spotify)" ] && Control="spotify"
[ -n "$(pgrep brave-bin)" ] && Control="brave-bin"
# [ -n "$(pgrep rhythmbox)" ] && Control="rhythmbox"
# [ -n "$(pgrep audacious)" ] && Control="audacious"
# [ -n "$(pgrep clementine)" ] && Control="clementine"
# [ -n "$(pgrep strawberry)" ] && Control="strawberry"
#



# saves covers here
Cover=/tmp/cover.png
# if cover not found in metadata use this instead
bkpCover=~/nix/dots/eww/music.svg # TODO: Fix this
# mpd music directory
mpddir="$HOME/Music/iTunes Media"

# ┌─┐┬  ┌─┐┬ ┬┌─┐┬─┐┌─┐┌┬┐┬    ┌─┐┌─┐┬─┐┬┌─┐┌┬┐┌─┐
# ├─┘│  ├─┤└┬┘├┤ ├┬┘│   │ │    └─┐│  ├┬┘│├─┘ │ └─┐
# ┴  ┴─┘┴ ┴ ┴ └─┘┴└─└─┘ ┴ ┴─┘  └─┘└─┘┴└─┴┴   ┴ └─┘

########################## Title ##########################
title() {
title=$(playerctl --player=$Control metadata --format {{title}})
[ -z "$title" ] && title="Play Something"
echo "$title"
}

########################## Artist ##########################
artist() {
artist=$(playerctl --player=$Control metadata --format {{artist}})
[ -z "$artist" ] && artist="Artist"
echo "$artist"
}

########################## Album ##########################
album() {
album=$(playerctl --player=$Control metadata --format {{album}})
[ -z "$album" ] && album="Album"
echo "$album"
}

########################## Status ##########################
status() {
status=$(playerctl --player=$Control status)
[ -z "$status" ] && status="Stopped"
echo "$status"
}

########################## Time ##########################
ctime() {
time=$(playerctl --player=$Control position --format "{{ duration(position) }}")
[ -z "$time" ] && time="0:00"
echo "$time"
}

########################## Length ##########################
length() {
length=$(playerctl --player=$Control metadata --format "{{ duration(mpris:length) }}")
[ -z "$length" ] && length="0:00"
echo "$length"
}

########################## Time Seconds ##########################
ctimeS() {
time=$(playerctl --player=$Control position)
[ -z "$time" ] && time="0"
echo "$time"
}

########################## Length Seconds ##########################
lengthS() {
length=$(playerctl --player=$Control metadata  --format "{{ mpris:length }}")
[ -z "$length" ] && length="0"
length=$(($length/1000000))
echo "$length"
}

########################## trackNumber ##########################
playlist() {
playlist=$(playerctl --player=$Control metadata xesam:trackNumber)
[ -z "$playlist" ] && playlist="0"
echo "$playlist"
}

########################## Cover ##########################
cover() {
albumart="$(playerctl --player=$Control metadata mpris:artUrl | sed -e 's/open.spotify.com/i.scdn.co/g')"
[ $(playerctl --player=$Control metadata mpris:artUrl) ] && curl -s "$albumart" --output $Cover || cp $bkpCover $Cover 
echo "$Cover"
}

########################## Statusicon ##########################
statusicon() {
icon=""
[ $(playerctl --player=$Control status) = "Playing" ] && icon=""
[ $(playerctl --player=$Control status) = "Paused" ] && icon=""
echo "$icon"
}

########################## Percent ##########################
perc() {
time_song="$(ctimeS)"
len_song="$(lengthS)"
divided=$(python -c "print(($time_song/$len_song)*100)")
echo "$divided"
}

############### Set Position With Percentage ##########################
set_position() {
len_song="$(lengthS)"
playerctl position --player=$Control $(python -c "print($1/100*$len_song)")
}

########################## Spotify Volume ######################
sp_volume() {
# value between 0 and 1 
normalized=$(python -c "print($1/101)")
$(playerctl --player=$Control volume $normalized)
}

sp_get_volume() {
# value between 0 and 1 
normalized=$(python -c "print($1/101)")
$(playerctl --player=$Control volume $normalized)
}
########################## Lyrics ##########################
lyrics() {
Title=$(playerctl --player=$Control metadata --format {{title}})
Artist=$(playerctl --player=$Control metadata --format {{artist}})
URL="https://api.lyrics.ovh/v1/$Artist/$Title"
lyrics=$(curl -s "$( echo "$URL" | sed s/" "/%20/g | sed s/"&"/%26/g | sed s/,/%2C/g | sed s/-/%2D/g)" | jq '.lyrics' )
[ "$lyrics" = "null" ] && lyrics=$( curl -s --get "https://makeitpersonal.co/lyrics" --data-urlencode "artist=$Artist" --data-urlencode "title=$Title")
printf "$lyrics" | less
}

# ┌┬┐┌─┐┌┬┐  ┌─┐┌─┐┬─┐┬┌─┐┌┬┐┌─┐
# │││├─┘ ││  └─┐│  ├┬┘│├─┘ │ └─┐
# ┴ ┴┴  ─┴┘  └─┘└─┘┴└─┴┴   ┴ └─┘

########################## Title ##########################
mpctitle() {
title=$(mpc -f %title% current)
[ -z "$title" ] && title="Play Something"
echo "$title"
}

########################## Artist ##########################
mpcartist() {
artist=$(mpc -f %artist% current)
[ -z "$artist" ] && artist="Artist"
echo "$artist"
}

########################## Album ##########################
mpcalbum() {
album=$(mpc -f %album% current)
[ -z "$album" ] && album="Album" 
echo "$album"
}

########################## Cover ##########################
mpccover() {
ffmpeg -i "$mpddir"/"$(mpc current -f %file%)" "${Cover}" -y || cp $bkpCover $Cover
echo "$Cover" && exit
}

########################## Time ##########################
mpctime() {
time=$(mpc status %currenttime%)
[ -z "$time" ] && time="0:00"
echo "$time"
}

########################## Length ##########################
mpclength() {
length=$(mpc status %totaltime%)
[ -z "$length" ] && length="0:00" 
echo "$length"
}

########################## Icon ##########################
mpcicon() {
status=$(mpc status | head -2 | tail -1 | cut -c2-7 )
icon=""
[ "$status" = "playin" ] && icon=""
[ "$status" = "paused" ] && icon=""
echo "$icon"
}

########################## Status ##########################
mpcstatus() {
stat=$(mpc status | head -2 | tail -1 | cut -c2-7 )
status="Stopped"
[ "$stat" = "playin" ] && status="Playing"
[ "$stat" = "paused" ] && status="Paused"
echo "$status"
}

########################## Percent ##########################
mpcperc() {
perc=$(mpc status %percenttime%)
[ -z "$perc" ] && perc="0" 
echo "$perc"
}

########################## Playlist ##########################
mpcsongpos() {
pos=$(mpc status %songpos%)
allsongs=$(mpc status %length%)
playlist="$pos/$allsongs"
[ -z "$pos" ] && playlist="0/0"
echo "$playlist"
}

########################## Lyrics ##########################
mpclyrics() {
Title=$(mpc -f %title% current)
Artist=$(mpc -f %artist% current)
URL="https://api.lyrics.ovh/v1/$Artist/$Title"
lyrics=$(curl -s "$( echo "$URL" | sed s/" "/%20/g | sed s/"&"/%26/g | sed s/,/%2C/g | sed s/-/%2D/g)" | jq '.lyrics' )
[ "$lyrics" = "null" ] && lyrics=$( curl -s --get "https://makeitpersonal.co/lyrics" --data-urlencode "artist=$Artist" --data-urlencode "title=$Title")
printf "$lyrics" | less
}

# ┬ ┬┌─┐┬  ┌─┐
# ├─┤├┤ │  ├─┘
# ┴ ┴└─┘┴─┘┴  

doc() {
echo "Usage:
  music [Options]

Options:
  previous	previous song
  next		next song
  toggle	toggle between play-pause song
  title		shows title of current song
  album		shows album of current song
  artist	shows artist of current song
  status	music status (playing/paused/stopped)
  statusicon	music status icons (playing/paused/stopped)
  coverloc	saves cover and shows location to cover of current song
  showcover	opens cover using feh
  time		shows current time of song
  timeS		shows current time of song in seconds
  length	shows length of song
  lengthS	shows length of song in seconds
  percent	shows percent song
  setposition	sets position in song
  playlist	shows playlist position of current song
  lyrics	shows lyrics"
}

# ┌─┐┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
# │ │├─┘ │ ││ ││││└─┐
# └─┘┴   ┴ ┴└─┘┘└┘└─┘

case $Control in
	MPD)
	case $1 in 
		next)		mpc -q next		;;
		previous)	mpc -q prev		;;
		toggle)		mpc -q toggle		;;
		title)		mpctitle		;;
		artist)		mpcartist		;;
		album)		mpcalbum		;;
		status)		mpcstatus		;;
		statusicon)	mpcicon			;;
		player)		echo "$Control"		;;
		coverloc)	mpccover		;;
		showcover)	mpccover | xargs feh	;;
		time)		mpctime			;;
		timeS)		mpctime			;;
		length)		mpclength		;;
		lengthS)		mpclength		;;
		percent)	mpcperc			;;
		playlist)	mpcsongpos		;;
		lyrics)		mpclyrics		;;
		*)		doc			;;
	esac
	;;
	*)
	case $1 in 
		next)		playerctl --player=$Control next	;;
		previous)	playerctl --player=$Control previous	;;
		toggle)		playerctl --player=$Control play-pause	;;
		title)		title					;;
		artist)		artist					;;
		album)		album					;;
		status)		status					;;
		statusicon)	statusicon				;;
		player)		echo "$Control"				;;
		coverloc)	cover					;;
		showcover)	cover | xargs feh 			;;
		time)		ctime 					;;
		timeS)		ctimeS 					;;
		length)		length 					;;
		lengthS)	lengthS 					;;
		percent)	perc				;;
		setposition)	set_position $2				;;
		playlist)	playlist				;;
		lyrics)		lyrics					;;
		sp_volume) sp_volume $2 ;;
		*)		doc					;;
	esac
esac 2>/dev/null
