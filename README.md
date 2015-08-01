# DiscoveryVideo
Script to download videos on discovery

##Requirements:
Only works on OSX / Linux. (Tested on OSX only)

- Ruby (ver 2.2.1)
- ffmpeg (ver 2.7.1)

##Usage:
`ruby discovery_video.rb uri [file_name] [offset]`
####uri
Compulsory

To get uri:

1. Right click, inspect element
2. Go to Resources
3. Go to others (or Frames/(viewer.aspx)/others for Chrome)
4. Open (double-click) video resource (.ts etc.) - don't save if prompted
5. Copy url

Example url: "http://ri.evvoclass.com/Panopto/Content/sessions3/10bd5186-260b-44b4-ac2f-142083941b45/71fa48a2-ace9-4b80-9a04-1a9ecf8f897a-0e79fd4d-c7ef-4a68-b6ef-f65ec9a95b66.hls/666683/00000.ts"

Truncate the final digits and extension

uri = "http://ri.evvoclass.com/Panopto/Content/sessions3/10bd5186-260b-44b4-ac2f-142083941b45/71fa48a2-ace9-4b80-9a04-1a9ecf8f897a-0e79fd4d-c7ef-4a68-b6ef-f65ec9a95b66.hls/666683/"

**NOTE:** Keep the '/'

####file_name
Optional, do not include extension
####offset
Optional

Offset is the last 5 digits of file (excluding extension)

A 50 minute video should have 300 chunks, so an offset of 150 is around halfway through the videos