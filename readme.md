# Collage Timeline Tool

A simple bash tool to concat images and videos in just one file adding:

- date label
- soundtrack

> Not tested on windows because I don't have and I don't like ms windows :b


## Technologies

- FFMPEG
- bash

> If you have ffmpeg, this should work with git bash,  mobaxterm or wsl. Anyway you can raise a ticket to create a powershell script

## Parameters

|name|value|description|
|:--|:--|:--|
|source_folder|/home/jane/images_and_videos|A folder containing images and videos [this](https://github.com/jrichardsz/collage_timeline_tool_cli/wiki/File-names-syntax) name syntax|
|target_folder|/home/jane/output|Where you want to get the video result|
|duration|10|Duration for video creation from an image|
|sound_file|/home/jane/songs/foo.mp3|Soundtrack|
|batch_count|25|Size of the block to be processed|

## Result

|file or folder|description|
|:--|:--|
|output_ready.mp4|Big video file containing all the images and videos sort by date. You can delete the other files and folders|
|output.mp4|Big video file containing all the images and videos sort by date without soundtrack|
|videos|All the files as videos with the date text at the bottom|


## Sync

```
bash tool.sh source_folder=/foo/2024/images target_folder=/tmp/workspace/2024 duration=15 sound_file=/tmp/workspace/input.mp3
```

## Async

If you have hundred of files, you can use this option to process in parallel way.

Set 10 or 25 into this variable: **batch_count** 

> For 181 files, the sync mode took 2 hours. Asynchronous mode with batch_count=25 took 50 minutes but my machine was very slow due to parallel processing :b

```
bash tool_async.sh source_folder=/foo/2024/images target_folder=/tmp/workspace/2024 duration=15 sound_file=/tmp/workspace/input.mp3 batch_count=10
```
