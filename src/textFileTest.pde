// import libraries
import processing.serial.*;
import java.awt.datatransfer.*;
import java.awt.Toolkit;
import processing.opengl.*;
import saito.objloader.*;
import g4p_controls.*;
import java.io.*;
import java.awt.*;

// declare global variables
// a represents a specific data point within the data set and acts as a counter  
// dataPoints represents the total number of data points within the data set
// forward represents the "play" state of the program (play, rewind, fast forward, etc.)
int a = 0;
int dataPoints = 0;
int forward = 1;

float roll  = 0.0F;
float pitch = 0.0F;
float yaw   = 0.0F;
float depthValue;

// float zeroRoll = 0.0F;
// float zeroPitch = 0.0F;
// float zeroYaw = 0.0F;

//boolean fileExist;
String dataFile = "";

OBJModel model;

// UI controls.
GButton   playButton;
GButton   pauseButton;
GButton   rewind;
GButton   fastForward;
GLabel    time;
GLabel    yawHeading;
GLabel    pitchHeading;
GLabel    rollHeading;
GLabel    yawValue;
GLabel    pitchValue;
GLabel    rollValue;
GLabel    depthHeading;
GLabel    depthDisplay;
GSlider   scrubber;
GSlider   depth;

GWindow    fileNameWindow;
GTextField fileName;
GButton    clearField;
GButton    submit;

void setup()
{
  //size() changes the size of the display window
  size(1000, 1000, OPENGL);
  frameRate(10);
  
  //load new model
  model = new OBJModel(this);
  model.load("turtle-x7_decimated.stl.obj");
  model.scale(3);
  
  // change the display color
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  
  // declare, size, and place different UI elements
  playButton = new GButton(this, 120, 600, 100, 100);
  pauseButton = new GButton(this, 340, 600, 100, 100);
  rewind = new GButton(this, 560, 600, 100, 100);
  fastForward = new GButton(this, 780, 600, 100, 100, "1x");
  
  //using pictures to change the buttons to actual play/pause/rewind buttons
  playButton.setIcon("playbuttonsmall.png", 1);
  pauseButton.setIcon("pausebuttonsmall.png", 1);
  rewind.setIcon("rewindbuttonsmall.png", 1);
  fastForward.setFont(new Font("Sans_Serif", Font.PLAIN, 30));
  
  time = new GLabel(this, 700, 900, 100, 40, "0");
  yawHeading = new GLabel(this, 175, 700, 100, 100, "YAW");
  pitchHeading = new GLabel(this, 450, 700, 100, 100, "PITCH");
  rollHeading = new GLabel(this, 725, 700, 100, 100, "ROLL");
  yawValue = new GLabel(this, 175, 800, 200, 40, "0");
  pitchValue = new GLabel(this, 450, 800, 200, 40, "0");
  rollValue = new GLabel(this, 725, 800, 200, 40, "0");
  
  yawHeading.setFont(new Font("Sans_Serif", Font.PLAIN, 30));
  pitchHeading.setFont(new Font("Sans_Serif", Font.PLAIN, 30));
  rollHeading.setFont(new Font("Sans_Serif", Font.PLAIN, 30));
  yawValue.setFont(new Font("Sans_Serif", Font.PLAIN, 30));
  pitchValue.setFont(new Font("Sans_Serif", Font.PLAIN, 30));
  rollValue.setFont(new Font("Sans_Serif", Font.PLAIN, 30));
  
  //make scrubber have values from 0-1000 depending on where the ball is - default is a binary state (0/1)
  scrubber = new GSlider(this, 225, 900, 400, 50, 10);
  scrubber.setLimits(0, 1000);
  
  //also setting limits for the depth meter
  depth = new GSlider(this, 300, 100, 400, 50, 10);
  depth.setRotation(radians(90));  // rotate the slider so that it's vertical (to actually display depth)
  depth.setLimits(0, 400);
  
  depthHeading = new GLabel(this, 260, 30, 100, 100, "depth");
  depthDisplay = new GLabel(this, 260, 475, 100, 100, "0");
  
  //adding elements to a new window
  fileNameWindow = GWindow.getWindow(this, "Text File", 100, 50, 400, 300, JAVA2D);
  fileNameWindow.addDrawHandler(this, "windowDraw");
  fileName = new GTextField(fileNameWindow, 100, 50, 200, 25);
  submit = new GButton(fileNameWindow, 100, 150, 100, 40, "SUBMIT");
  submit.addEventHandler(this, "submitEvent");
  clearField = new GButton(fileNameWindow, 200, 150, 100, 40, "CLEAR");
  clearField.addEventHandler(this, "clearEvent");
}  
 
void draw()
{
  // draw background - currently black
  background(190, 190, 190);
  
  // set a new co-ordinate space
  pushMatrix();
  
  // displace objects from 0,0 - this controls the location of the OBJ
  translate(650, 400, 0);
  
  // this while loop (and print statement) is required to prevent the program from proceeding while there is still no dataFile submitted
  while(dataFile == "")
  {
    println("");
  }
  
  // load data file
  String[] lines = loadStrings(dataFile);
  
  // initialize dataPoints
  dataPoints = lines.length;
  
  // pull the total time from the last line of data output
  String[] lastLine = split(lines[lines.length - 1], ",");
  String totalTime = lastLine[0];
  
  // pull zero values from the first data point
  // String[] zero = split(lines[0], ",");
  // zeroRoll = float(zero[0]);
  // zeroPitch = float(zero[1]);
  // zeroYaw = float(zero[2]);
  
  // simple 3 point lighting for dramatic effect.
  // slightly red light in upper right, slightly blue light in upper left, and white light from behind.
  pointLight(255, 200, 200,  400, 400,  500);
  pointLight(200, 200, 255, -400, 400,  500);
  pointLight(255, 255, 255,    0,   0, -500);
  
  // pull data from the the "a"th line in the data set - display time as well as yaw, pitch, and roll
  String[] list = split(lines[a], ",");
  
  roll  = float(list[1]);
  pitch = float(list[2]);
  yaw   = float(list[3]);
  
  /*
  roll  = float(list[0]) - zeroRoll;
  pitch = float(list[1]) - zeroPitch;
  yaw   = float(list[2]) - zeroYaw;
  */
  
  // \u00B0 is Unicode for the degree symbol
  time.setText(list[0] + "/" + totalTime);
  yawValue.setText(Float.toString(yaw) + "\u00B0");
  pitchValue.setText(Float.toString(pitch) + "\u00B0");
  rollValue.setText(Float.toString(roll) + "\u00B0");
  
  // appropriately rotates the object in order to demonstrate orientation
  rotateX(radians(roll));
  rotateZ(radians(pitch));
  rotateY(radians(yaw));
  
  pushMatrix();
  
  // push new style in order to save the noStroke() state for the model; without this you can't draw the axes
  pushStyle();
    noStroke();
    model.draw();
  popStyle();
  
  // draw the coordinate axes, centered at the turtle (within the same transformation matrix, so the translation + rotation will apply)
  pushStyle();
    stroke(0);
    strokeWeight(4);
    line(0, 0, 0, 300, 0, 0);
    line(0, 0, 0, 0, -300, 0);
    line(0, 0, 0, 0, 0, 300);
  popStyle();
  
  popMatrix();
  popMatrix();
  
  // control structure in order to advance, playback, or fast forward through the dataset
  // ensures the correct state as well as prevents OutOfBounds errors
  if(forward > 0 && !((a + forward) >= dataPoints))
    a += forward;
  else if(forward < 0 && a != 0)
    a--;
  
  // send correct value to scrubber so it displays correctly (moves as the dataset progresses)
  float scrubberValue = (float(a) / (dataPoints - 1)) * 1000;
  scrubber.setValue(scrubberValue);
  
  // set correct value of depth - unsure if there will end up being positive depth values, but either way this is included for error catching right now
  depthValue = float(list[4]);
  depth.setValue(50.0 + 10.0 * depthValue);
  depthDisplay.setText(list[4]);
  
  // if you're about to exceed the last data point or if you're at the first, then pause the program
  if((a + forward) > lines.length || a == 0)
    noLoop();
}

// allows you to control what happens when each button is pressed
public void handleButtonEvents(GButton button, GEvent event)
{
  if(button == playButton)
  {
    // ensure that we don't go out of bounds
    if(a < 0)
      a++;
    
    if((a + 2) > dataPoints)
        a = 0;
    
    // resume program and set forward to 1 (play normally)
    loop();
    forward = 1;
  }
  if(button == pauseButton)
  {
    // pause program
    forward = 0;
    noLoop();
  }
  if(button == rewind)
  {
    // ensure we don't go out of bounds
    if(a == dataPoints)
      a--;
    
    // resume program and set forward to -1 (play backwards)
    loop();
    forward = -1;
    fastForward.setText("1x");
  }
  if(button == fastForward)
  {
    if(forward == 1)
    {
      forward = 2;
      fastForward.setText("2x");
    }
    else if (forward == 2)
    {
      forward = 4;
      fastForward.setText("4x");
    }
    else if (forward == 4 || forward == -1)
    {
      forward = 1;
      fastForward.setText("1x");
    }
    
    // ensure we don't go out of bounds
    if(a < 0)
      a += forward;
    
    // resume program and set forward to 2 (play 2x speed)
    loop();
  }
}

public void handleSliderEvents(GValueControl slider, GEvent event)
{  
  if(slider == scrubber)
  {
    // TEST LINES
    int sliderValue = slider.getValueI();
    // println(sliderValue);
    
    // based on where the slider is pressed, set a (map the value of a from the dataPoints)
    a = int((sliderValue / 1000.0) * (dataPoints - 1));
  }
}

// not sure if this really impacts things because the sketch doesn't update much while noLoop() is active anyways...
void mousePressed()
{
  if (forward == 0)
    redraw();
}

// draw() for the new GWindow that was created
public void windowDraw(PApplet app, GWinData data){
    app.background(190, 190, 190);
}

// what happens when the submit button is pressed
public void submitEvent(GButton source, GEvent event) {
  dataFile = fileName.getText();
  
  /*
  String temp = fileName.getText();
  println(temp);
  File f = dataFile(temp);
  boolean fileExist = f.isFile();
  println(fileExist);
  
  if(fileExist == true)
    dataFile = temp;
  else if(fileExist == false)
    println("That file name does not exist. Please enter an existing file name.");
  */
  
  loop();
  a = 0;
  forward = 1;
}

// what happens when the clear button is pressed
public void clearEvent(GButton source, GEvent event) {
  fileName.setText("");
}
