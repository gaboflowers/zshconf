function yt() {
    if [ -z "$1" ]; then
        echo " Uso: $0 [link del yutú]"
    else
        mpv $1 --slang=en
    fi
}

alias yt-mp3="youtube-dl -x --audio-format mp3"

function yt-save() {
    if [ -z "$2" ]; then
        echo " Uso: $0 <link youtube> <título (=[nombre].mp3)> [argumentos de mid3v2]"
    else
        ytdloutput=$(youtube-dl -x --audio-format mp3 $1)
        filename=$(echo $ytdloutput | grep ffmpeg | grep Destination | awk '{$1=""; $2=""; print}' | sed 's/^ *//g')
        echo "[youtube-dl] saved to $filename"
        mv $filename "$2.mp3"
        echo "[me] moved to $2.mp3"
        mid3v2 "$2.mp3" -t $2 "${@:3}" # Me gusta que mis archivos de canción tengan el nombre de su título.
                                       # Puede usarse otro modificando el '-t' (título) de mid3v2, pero qué lata
        mid3v2 "$2.mp3"
    fi
}

function id3() {
    sep="\t"
    if [ "$1" = "-F" ]; then
        sep="$2"
        shift 2
    fi

    if [ -z "$1" ]; then
        echo " Uso: $0 [-F <separador>] <archivo de audio>"
    else
        mid3out=$(mid3v2 -l $1 2> /dev/null)
        retval=$?
        if [ "$retval" -eq 0 ]; then
            echo $mid3out | awk -v sep="$sep" '/^IDv2 tag/{gsub(/^IDv2 tag info for /,"");file=$0} /^TIT2=/{gsub(/^\w+=/,"");name=$0} /^TPE1=/{gsub(/^\w+=/,"");artist=$0} /^TALB=/{gsub(/^\w+=/,"");album=$0} /^TDRC=/{gsub(/^\w+=/,"");date=$0} /^TRCK=/{gsub(/^\w+=/,"");track=$0} END{print track sep album " (" date ")" sep artist sep file }'
        fi
        return $retval
    fi
}

function _lm() {
    sep="\t"
    if [ "$1" = "-F" ]; then
        sep="$2"
    fi

    for fname in *; do
        [ -e "$fname" ] || continue
        [ ! -d "$fname" ] || continue
        info=$(id3 -F "$sep" "$fname")
        if [ "$?" -eq 0 ]; then
            echo $info;
        else
            echo "$fname failed"
        fi
    done
}
# Quiero seguir teniendo la funcionalidad de _lm, para poder hacer
# cosas como
#   _lm | sort -t $'\t' -k 2,2d -k 1,1n | grep [...] | awk -F'\t' '{print [...]}'

alias lm='_lm -F ";" | tabulate -I ";" -O "   "' # 'list music'

