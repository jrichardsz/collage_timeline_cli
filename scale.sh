#!/bin/bash

for ARGUMENT in "$@"

do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

echo -e "Scale starting: $source_file"
filename=$(basename -- "$source_file")
extension="${filename##*.}"
filename="${filename%.*}"

date_str=
if [[ "$filename" =~ ^IMG-.* ]]; then
    date_str=$(echo "$filename" | cut -d - -f 2) 
fi

if [[ "$filename" =~ ^IMG_.* ]]; then
    date_str=$(echo "$filename" | cut -d _ -f 2) 
fi    

if [[ "$filename" =~ ^VID_.* ]]; then
    date_str=$(echo "$filename" | cut -d _ -f 2) 
fi

new_file_name="$date_str""_$(uuidgen)"

if [[ "$extension" = "mp4" ]]; then
    ffmpeg -y -hide_banner -loglevel error -i "$source_file" -vcodec libx264 -vf "scale=w=1280:h=720:force_original_aspect_ratio=1,pad=1280:720:(ow-iw)/2:(oh-ih)/2" -acodec copy "$target_folder/resized/$new_file_name.mp4"
else
    ffmpeg -y -loop 1 -hide_banner -loglevel error -i "$source_file" -c:v libx264 -t $duration -pix_fmt yuv420p -vf "scale=w=1280:h=720:force_original_aspect_ratio=1,pad=1280:720:(ow-iw)/2:(oh-ih)/2" "$target_folder/resized/$new_file_name.mp4"  
fi

ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$target_folder/resized/$new_file_name.mp4"

echo "Resized: $target_folder/resized/$new_file_name.mp4"

echo "" > "$target_folder/resized_global_progress/$new_file_name"
echo "" > "$target_folder/resized_batch_progress/$new_file_name"