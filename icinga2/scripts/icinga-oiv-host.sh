#!/bin/sh


/usr/bin/curl -s -k -X POST -H "Content-type: application/json" -d '{ "access_token":"856fe6e00dafb99d171d54120cb82b2b", "format":"json", "alarm":{"name":"'$HOSTDISPLAYNAME'","originating_system":"eventswitcher","impact_level":"low","alarm_type":"application","sop":"https://www.teamccp.com/confluence/display/xcal/SOP-for-reconnects"},"events": [{"subject":"'$HOSTDISPLAYNAME'", "application_name":"'$NOTIFICATIONTYPE'", "service_desk":"TEST","description":"Please follow this SOP to check the status of the alarm: http","host_impacted":"'$HOSTALIAS'", "event_status":"'$HOSTSTATE'","host_ip_address":"'$HOSTADDRESS'","initiated_at":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}]}' 'http://cpg-oiv-api.sys.comcast.net/v1/alarms'

