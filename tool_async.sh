#!/bin/bash

start_time=$SECONDS
MONTHS_EN=(None Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
MONTHS_ES=(None Ene Feb Mar Abr May Jun Jul Ago Sep Oct Nov Dic)

for ARGUMENT in "$@"

do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done


rm -rf "$target_folder"
mkdir -p "$target_folder"
mkdir -p "$target_folder/videos"
mkdir -p "$target_folder/resized"
mkdir -p "$target_folder/resized_batch_progress"
mkdir -p "$target_folder/resized_global_progress"

echo "#####################"
echo "Step #1 : scale video"
echo "#####################"

max_iterations=$(find "$source_folder" -type f -print | wc -l)
count=1

echo 

for source_file in $(find "$source_folder" -maxdepth 1 -type f); do
    
    echo -e "current file is $source_file"
    bash scale.sh target_folder=$target_folder source_file=$source_file &

    if [[ $count = $batch_count ]]; then

        echo
        while [ true ] ; do
          batch_progress_count=$(find "$target_folder/resized_batch_progress" -type f -print | wc -l)             
          if [[ $batch_progress_count = $batch_count ]]; then
            count=1
            rm -rf "$target_folder/resized_batch_progress"
            mkdir -p "$target_folder/resized_batch_progress"
            break
          else
            echo -e "scale batch progress: $batch_progress_count/$batch_count \r"  
            sleep 2;          
          fi
        done;  
    else    
      count=$(($count +1))
      global_progress_count=$(find "$target_folder/resized_global_progress" -type f -print | wc -l)             
      echo -e "scale global progress: $global_progress_count/$max_iterations \r"
    fi
done

while [ true ] ; do
    global_progress_count=$(find "$target_folder/resized_global_progress" -type f -print | wc -l)             
    if [[ $global_progress_count = $max_iterations ]]; then
      break
    fi
    echo -e "scale global progress: $global_progress_count/$max_iterations \r"
    sleep 2;    
done;

echo "#####################"
echo "Step #2 : add text"
echo "#####################"

max_iterations=$(find "$target_folder/resized" -type f -print | wc -l)
count=1

for source_file in $(find "$target_folder/resized" -maxdepth 1 -type f | sort); do
    echo -e "\nprogress: $count/$max_iterations \r"
    count=$(($count +1))
    
    echo "current file is $source_file"
    filename=$(basename -- "$source_file")
    extension="${filename##*.}"
    filename="${filename%.*}"

    date_str=$(echo "$filename" | cut -d _ -f 1) 

    month_str=$(date -d "$date_str" +'%m')
    month_str=${month_str#0}
    year_str=$(date -d "$date_str" +'%Y')
    day_str=$(date -d "$date_str" +'%d')

    text="$year_str   ${MONTHS_ES[$month_str]}   $day_str"    

    if [[ "$extension" = "mp4" ]]; then
        ffmpeg -y -hide_banner -loglevel error -i "$source_file" -vf "drawtext=text='$text':x=(w-text_w)/2:y=h-th-10:fontsize=80:fontcolor=white:boxcolor=black@0.4:bordercolor=black:borderw=15" "$target_folder/videos/$filename.mp4"        
    else
        ffmpeg -y -loop 1 -hide_banner -loglevel error -i "$source_file" -c:v libx264 -t $duration -pix_fmt yuv420p -vf "drawtext=text='$text':x=(w-text_w)/2:y=h-th-10:fontsize=80:fontcolor=white:boxcolor=black@0.4:bordercolor=black:borderw=15" "$target_folder/videos/$filename.mp4"        
    fi

    echo "Text: $target_folder/videos/$filename.mp4"
done


echo "#####################"
echo "Step #3 : concat"
echo "#####################"

concat_file="$target_folder/files.txt"
> "$concat_file"

for source_file in $(find "$target_folder/videos" -maxdepth 1 -type f | sort); do
    echo "file '$source_file'">>"$concat_file"
done

cat "$concat_file"

ffmpeg -hide_banner -loglevel error -y -r 25 -f concat -safe 0 -i "$concat_file" -codec copy -c:v libx264 -b:v 3M -strict -2 "$target_folder/output.mp4" 

ffmpeg -hide_banner -loglevel error -i "$target_folder/output.mp4" -i "$sound_file" -shortest -c:v copy -map 0:v:0 -map 1:a:0 "$target_folder/output_ready.mp4" 

elapsed=$(( SECONDS - start_time ))
echo -e "\n"
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"