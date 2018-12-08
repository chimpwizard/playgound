const Gpio = require('onoff').Gpio;
const led = new Gpio(18, 'out');
const button = new Gpio(26, 'in', 'both');
 
console.log("Listening port 26...")

button.watch((err, value) => {
    if (err) {
      throw err;
    }
   
    led.writeSync(led.readSync() ^ 1);
});

process.on('SIGINT', () => {
    led.unexport();
    button.unexport();
});