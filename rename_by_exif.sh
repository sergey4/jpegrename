#!/bin/bash
DESTDIR=/mnt/photo/sorted
if [ ! -d "$DESTDIR" ];
then
	echo "directory $DESTDIR doesn't exist, exiting..."
	exit 1
fi

create_dir () {
  if [ -d "$1" ];
  then
	  return
  fi
  mkdir "$1"
  if [ ! -d "$1" ];
  then
	  echo "creating dir failed, exiting..."
	  exit 2
  fi
}

generate_new_filename () {
	#echo "generate new filename called $1 $2 $3"
	for i in `seq 1 10`
	do
		local NEW_NAME="$1/$2"_v$i".$3"
		if [ ! -f "$NEW_NAME" ];
		then
			echo "$NEW_NAME"
			return
		fi
	done
	echo ""
	exit 1
}

EXIF_RAW=`exif --tag 0x9003 -m "$1"`
if [ -z "$EXIF_RAW" ];
then
	echo "$1 contains no exif"
else 
	DIR_YEAR=`echo $EXIF_RAW | awk -F':' '{print $1}'`
	DIR_YEAR_MONTH_DAY=`echo $EXIF_RAW | awk '{print $1}' | sed 's/:/_/g'`
	ORIG_FILE=`basename "$1"`
	ORIG_EXTENSION=${ORIG_FILE##*.}
	FILE_NAME=`echo $EXIF_RAW | sed 's/:/_/g;s/\ /_/g'`
	RELATIVE_PATH=$DIR_YEAR/$DIR_YEAR_MONTH_DAY
	NEW_FILENAME=$FILE_NAME.$ORIG_EXTENSION
	DESTDIR_FULL="$DESTDIR/$RELATIVE_PATH"
	echo "renaming $1 to $RELATIVE_PATH/$NEW_FILENAME"
	create_dir "$DESTDIR/$DIR_YEAR"
	create_dir "$DESTDIR_FULL"
	NEW_FULL_NAME="$DESTDIR_FULL/$NEW_FILENAME"
	if [ -f "$NEW_FULL_NAME" ];
	then
		NEW_FULL_NAME=$(generate_new_filename "$DESTDIR_FULL" "$FILE_NAME" "$ORIG_EXTENSION")
		if [ -z "$NEW_FULL_NAME" ];
		then
			echo "Error: cannot generate new name for $RELATIVE_PATH/$NEW_FILENAME, too many attempts, giving up"
			exit 1
		fi
		echo "file exists, generated new name = $NEW_FULL_NAME"
	fi	
	mv "$1" "$NEW_FULL_NAME"
fi
