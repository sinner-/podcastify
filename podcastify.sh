#!/usr/bin/env bash
TMP_DIR="/tmp"
XML_FILE="p.xml"
DEFAULT_IF=$(route | grep default | head -1 | awk '{print $8}')
IP=$(ip addr show dev "$DEFAULT_IF" | grep "inet " | awk  '{print $2}' | sed 's/.\{3\}$//')
DATE=$(date "+%a, %d %b %Y %H:%M:%S +0000")

cat <<EOF> $TMP_DIR/$XML_FILE
<?xml version="1.0" encoding="utf-8" ?>
<rss version="2.0" xml:base="http://$IP:8000/p.xml" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"  xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
        <title>Music</title>
        <description>Listen to Music!</description>
        <language>en</language>
        <atom:link href="http://$IP:8000/p.xml" rel="self" type="application/rss+xml" />
        <pubDate>$DATE</pubDate>
        <lastBuildDate>$DATE</lastBuildDate>
        <itunes:explicit>No</itunes:explicit>
EOF

IFS='
'
for FILE in $(ls *.mp3);
do
  DURATION=$(ffmpeg -i "$FILE"  2>&1 | grep Duration | awk '{print $2}' | sed 's/.\{4\}$//')
  HOURS=$(echo "$DURATION" | awk -F ":" '{print $1}')
  MINS=$(echo "$DURATION" | awk -F ":" '{print $2}')
  SECS=$(echo "$DURATION" | awk -F ":" '{print $3}')

  DURATION_SECS=$(echo \("$HOURS"*60*60\) + \("$MINS"*60\) + "$SECS" | bc)

  SIZE=$(ls -l "$FILE" | awk '{print $5}')
  cat <<EOF>> $TMP_DIR/$XML_FILE
        <item>
            <title>$(echo "$FILE" | sed 's/.\{4\}$//')</title>
            <pubDate>$DATE</pubDate>
            <enclosure url="http://$IP:8000/$FILE" length="$SIZE" type="audio/mpeg" />
            <guid>http://$IP:8000/$FILE</guid>
            <itunes:explicit>No</itunes:explicit>
            <itunes:duration>$DURATION_SECS</itunes:duration>
            <itunes:summary>
              <![CDATA[
                ]]>
            </itunes:summary>
            <description>
              <![CDATA[
                ]]>
            </description>
        </item>
EOF

done
unset IFS

cat <<EOF>>$TMP_DIR/$XML_FILE
    </channel>
</rss>
EOF
