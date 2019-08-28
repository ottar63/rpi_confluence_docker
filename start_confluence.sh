docker run  --rm --name confluence --link mysql57:mysql57 -p 8090:8090 -v /data/atlassian/confluence_home:/var/atlassian/confluence ottar63/rpi-mysql-confluence

