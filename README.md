# Obstacle-Avoidance-Car

Project Description

The car has 6 sensors placed in the front and back of the frame. These sensors send an interrupt signal to the microcontroller when the car approaches an object. The car then moves to avoid that object, depending on which sensor has sent a signal. For instance, if the front-right sensor detects an object, the car will turn to the left. There is a servo that controls the turning of the front two wheels. The two back wheel motors are controlled by a motor driver, which receives a PWM to move the wheels. 

The three category’s that were used for the requirements of this project were I/0, Interrupts, and PWM.

Test Plan and Results

To test the car, we will place several obstacles or walls around it, and let it drive until it collides with an object. This will test both the sensors and the movement functions. We will also place an object in the car’s path, and then move the object to test the responsiveness of the car. 
It is important to test all directions within range of the sensors: front-left, front, front-right, back-left, back, and back-right. Each sensor causes the car to move in a different way. We expect the front sensor to cause the car to stop, switch the wheels to reverse, backup, turn either left or right until the sensor no longer detects an object, and then go forwards. We expect the front-left and front-right sensors to cause the car to turn right or left, respectively. We expect the back sensor to cause the car to switch the wheels to forward and speed up until the sensor no longer detects an object. We expect the back-left and back-right sensors to cause the car to go forwards and turn right or left, respectively. 

We were not able to fully test the car because the motors we used were not powerful enough to drive the car. However, we did test each sensor, and the car responded as expected to each one. Given more time, this project could be improved by using more powerful motors and a better battery. 

