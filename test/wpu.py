import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM) # set up BCM GPIO numbering
GPIO.setup(4, GPIO.IN, pull_up_down=GPIO.PUD_UP)
