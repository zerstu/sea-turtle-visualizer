# sea-turtle-visualizer
Based heavily on the 'bunnyrotate.pde' sketch provided by Adafruit: https://learn.adafruit.com/ahrs-for-adafruits-9-dof-10-dof-breakout/visualizing-data

### Requirements:
- The latest version of [Processing](https://processing.org/download/)
- [Saito's OBJ Loader](https://github.com/taseenb/OBJLoader) library for Processing
- [G4P GUI library](http://www.lagers.org.uk/g4p/) for Processing

To install libraries, copy the zip into the Processing libraries. Many of the above links describe how to import libraries into Processing.

### Features:
- This program accepts text files (".txt") with data from the 9DoF Razor IMU and the SparkFun Pressure Sensor Breakout and shows a 3D model of a turtle that demonstrates yaw, pitch, roll, and depth over time.

- The data should be in the format:
time | roll | pitch | yaw | depth

- There should NOT be a header in the text file.

- At the beginning of the program, you must submit the name of the file you wish to process. This file must be in the same folder as the program itself.

- Depending on the frequency of the data, you can change the frameRate of the program in line 59.

[[https://github.com/zerstu/sea-turtle-visualizer/blob/master/exampleImage.PNG]]
