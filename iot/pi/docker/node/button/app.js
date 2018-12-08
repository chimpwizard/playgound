const Gpio = require('onoff').Gpio;
const led = new Gpio(18, 'out');
const button = new Gpio(26, 'in', 'both');
 
console.log("Listening port 26...")
button.watch((err, value) => led.writeSync(value));