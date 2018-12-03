import RPi.GPIO as GPIO
import time

# Configure the PIN # 18
# GPIO.setmode(GPIO.BOARD)
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

GPIO.setup(18, GPIO.OUT)
GPIO.setup(26, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# Blink Interval 
blink_interval = .5 #Time interval in Seconds

# Blinker Loop
while True:
    input_state = GPIO.input(26)
    
    if input_state == False:
        print('Button Released')
        GPIO.output(18, GPIO.LOW)
    else:
        print('Button Pressed')
        GPIO.output(18, GPIO.HIGH)

    time.sleep(blink_interval)

# Release Resources
GPIO.cleanup()