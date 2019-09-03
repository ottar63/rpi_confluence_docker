#!/bin/bash
#
# Sleep 60 seconds to be sure MySQL is started
sleep 60
/opt/atlassian/confluence/bin/start-confluence.sh -fg
