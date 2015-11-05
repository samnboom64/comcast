var x = require('casper').selectXPath;
var last_timestamp, started_at;
last_timestamp = started_at  = Date.now();
var perf_data = [];
var failures = [];


casper.options.viewportSize = {width: 375, height: 667};
casper.userAgent("Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4");
/*casper.on('page.error', function(msg, trace) {
   this.echo('Error: ' + msg, 'ERROR');
   for(var i=0; i<trace.length; i++) {
       var step = trace[i];
       this.echo('   ' + step.file + ' (line ' + step.line + ')', 'ERROR');
   }
});*/





casper.test.begin('COMCAST WEB TEST', function(test) {
   casper.start('http://m.comcast.net');
   casper.waitForSelector(x("//a[normalize-space(text())='Sign in']"),
       function success() {
           timerize(elapsed("Home page loaded", true));
           test.assertExists(x("//a[normalize-space(text())='Sign in']"));
           this.click(x("//a[normalize-space(text())='Sign in']"));
           this.capture('comcast1.png', {top: 0,left: 0,width: 400,height: 700});
},
       function fail() {
                fail1('failed 1');
   });



   casper.waitForSelector("form#signin input[type=submit][value='SIGN IN']",
       function success() {
        timerize(elapsed("find SIGN IN Button", true));
        test.assertExists("form#signin input[type=submit][value='SIGN IN']");
        this.capture('comcast2.png');
       },
       function fail() {
                fail1('failed 2');
   });




   casper.waitForSelector("form#signin input[name='user']",
       function success() {
           timerize(elapsed("Visiting Login Page", true));
           test.assertExists("form#signin input[name='user']");
           this.click("form#signin input[name='user']");
                this.capture('comcast3.png', {top: 0,left: 0,width: 400,height: 700});
       },
       function fail() {
                        fail1('failed 3');
//           test.assertExists("form#signin input[name='user']");
   });
   casper.waitForSelector("input[name='user']",
       function success() {
                timerize(elapsed("Filling Login credential", true));
                this.sendKeys("input[name='user']", "res-support.bmail01-ch");
                this.capture('comcast4.png', {top: 0,left: 0,width: 400,height: 700});
       },
       function fail() {
                        fail1('failed 4');
   });
   casper.waitForSelector("input[name='passwd']",
       function success() {
           timerize(elapsed("Filling Login password", true));
           this.sendKeys("input[name='passwd']", "keyn0tes");
           this.capture('comcast5.png', { top: 0,left: 0,width: 400,height: 700});
       },
       function fail() {
                 fail1('failed 5');
   });
   casper.waitForSelector("form#signin input[type=submit][value='SIGN IN']",
       function success() {
                timerize(elapsed("Click Sign In Buton", true));
                 test.assertExists("form#signin input[type=submit][value='SIGN IN']");
                this.click("form#signin input[type=submit][value='SIGN IN']");
                this.capture('comcast6.png', { top: 0,left: 0,width: 400,height: 700});

       },
       function fail() {
                fail1('failed 6');
   });


casper.waitForSelector(".mobile_email .icon",
       function success() {
        timerize(elapsed("Go back to Home", true));
        test.assertExists(".mobile_email .icon");
//        this.echo("Current location is:" + this.getCurrentUrl());
        this.capture('comcast7.png', {top: 0,left: 0,width: 400,height: 700});
        this.click(".mobile_email .icon");
       },
       function fail() {
        fail1('failed 7');
   });




casper.waitForPopup(/https\:\/\/web\.mail\.comcast\.net\/zimbra/, function success() {
                timerize(elapsed("Zimbra PopUP", true));
                test.assertEquals(this.popups.length, 1, "Check if popup was loaded.");
                this.capture('comcast7.png', { top: 0, left:0, width:400, height:  700});
//              this.echo("Current location is:" + this.getCurrentUrl());
        },
        function fail()
                        {
                                fail1('failed 8');
//              this.echo("Failed to load gaana popup");

});

casper.wait(2000, function() {
                this.capture('comcast8.png', { top: 0, left:0, width:400, height:  700});
  //              this.echo("Casper waited for 10 seconds to allow gaana to redirect etc.");
//              this.echo("Current location is:" + this.getCurrentUrl());
        });



casper.withPopup(/https\:\/\/web\.mail\.comcast\.net\/zimbra/, function success() {
                timerize(elapsed("Zimbra PopUP1", true));
                this.capture('comcast9.png', { top: 0, left:0, width:400, height:  700});
//              this.echo("Current location is:" + this.getCurrentUrl());
                this.capture('comcast10.png', { top: 0, left:0, width:400, height:  700});

},
function fail() {
                fail1('failed 9');

});

casper.wait(2000, function() {
    //          this.echo("Casper waited for 10 seconds to allow gaana to redirect etc.");
  //            this.echo("Current location is:" + this.getCurrentUrl());
                this.capture('comcast11.png', { top: 0, left:0, width:400, height:  700});
        });





   casper.run(function() {
        done1('success');

test.done();});



/*FUNCTION TO TEST SUCCESS RESULTS*/
function done1(pass){

perf_data.unshift(elapsed("Total"));
              var result = "OK";
               var message = "COMCAST MOBILE MAIL WEB LINK";
               nagios_exit(
                   "CHECK_SITE_UX",
                   result,
                   message,
                   perf_data.join(' ')
               );

}
function elapsed(label, reset) {
    var now = Date.now();
    var elapsed_ms;

    if (reset) {
        elapsed_ms = now - last_timestamp;
        last_timestamp = now;
            }
    else {
        elapsed_ms = now - started_at;
    }

    return "'" + label + "'=" + elapsed_ms + 'ms';
}

function timerize(p) {
    perf_data.push(p);
}

/*FUNCTION FOR Fail TEST RESULTS*/

function fail1(desc) {
casper.capture('fail.png', { top: 0, left:0, width:1000, height:  1000});

    nagios_exit(
        "CHECK_SITE_UX",
        'CRITICAL',
        "COMCAST MOBILE MAIL LINK UX Failure: " + desc + ". Screenshot saved to 'fail.png'.",
        perf_data.join(' ')
    );
}


/*FUNCTION FOR NAGIOS EXIT CODE AND MESSAGE*/
function nagios_exit (plugin_name, state, message, perfdata) {
    var exit_code, valid_state;

    switch (state.toUpperCase()) {
    case 'CRITICAL':
        valid_state = state;
        exit_code = 2;
        break;

    case 'WARNING':
        valid_state = state;
        exit_code = 1;
        break;

    case 'OK':
        valid_state = state;
        exit_code = 0;
        break;

    default:
        valid_state = 'UNKNOWN';
        exit_code = 3;
    }

    console.log(plugin_name + ' ' + valid_state + ': ' + message + '|' + perfdata);
    casper.exit(exit_code);
}

});
