import RPi.GPIO as GPIO
import time

# Configure the PIN # 18
# GPIO.setmode(GPIO.BOARD)
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

GPIO.setup(18, GPIO.OUT)

# Blink Interval 
blink_interval = .5 #Time interval in Seconds

# Blinker Loop
while True:
 print "ON"
 GPIO.output(18, GPIO.HIGH)
 time.sleep(blink_interval)
 print "OFF"
 GPIO.output(18, GPIO.LOW)
 time.sleep(blink_interval)

# Release Resources
GPIO.cleanup()