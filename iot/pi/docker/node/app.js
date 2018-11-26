var rpio = require('rpio');

/*
 * Set the initial state to low.  The state is set prior to the pin
 * being actived, so is safe for devices which require a stable setup.
 */
rpio.open(18, rpio.OUTPUT, rpio.LOW);
 
/*
 * The sleep functions block, but rarely in these simple programs does
 * one care about that.  Use a setInterval()/setTimeout() loop instead
 * if it matters.
 */
for (var i = 0; i < 5; i++) {
        /* On for 1 second */
        console.log("ON")
        rpio.write(18, rpio.HIGH);
        rpio.sleep(1);
 
        /* Off for half a second (500ms) */
        console.log("ON")
        rpio.write(18, rpio.LOW);
        rpio.msleep(500);
}