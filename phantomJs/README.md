synthetic for mobile website using casper JS and phantom JS

USAGE:

-sh-4.1$ casperjs test commobile_final.js --ssl-protocol=tlsv1 --verbose=true --log-level=debug

-sh-4.1$ casperjs test commobile_final.js --ssl-protocol=tlsv1

Test file: commobile_final.js

COMCAST WEB TEST
CHECK_SITE_UX CRITICAL: COMCAST MOBILE MAIL LINK UX Failure: failed 1. Screenshot saved to 'fail.png'.|

-sh-4.1$

NRPE CONF:

-sh-4.1$ hostname

restool-cmcd-01c.sys.comcast.net

-sh-4.1$ vim /etc/nagios/nrpe.cfg

command[check_mobile]=/usr/bin/casperjs test /home/skumar063c/comcast_mobile/final_script/commobile_final.js --ssl-protocol=tlsv1 --concise 2> /dev/null

FROM NAGIOS:

-sh-4.1$ hostname

respoller-ch2d-03c.sys.comcast.net

-sh-4.1$ /data/nagios/libexec/check_nrpe8k -n -t 20 -H restool-cmcd-01c.sys.comcast.net -c check_mobile

Test file: /home/skumar063c/comcast_mobile/final_script/commobile_final.js

PASS COMCAST WEB TEST (NaN test)

CHECK_SITE_UX CRITICAL: COMCAST MOBILE MAIL LINK UX Failure: failed 1. Screenshot saved to 'fail.png'.|
