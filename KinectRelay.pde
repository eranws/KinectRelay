/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

 import SimpleOpenNI.*;

 import processing.serial.*;

 import cc.arduino.*;

 Arduino arduino;

 SimpleOpenNI  context;
 color[]       userClr = new color[] { 
  color(0, 127, 0), 
  color(0, 0, 127), 
  color(0, 127, 127)
};




/*
final int SKEL_HEAD = 0;
final int SKEL_NECK = 1;
final int SKEL_LEFT_SHOULDER = 2;
final int SKEL_LEFT_ELBOW = 3;
final int SKEL_LEFT_HAND = 4;
final int SKEL_RIGHT_SHOULDER = 5;
final int SKEL_RIGHT_ELBOW = 6;
final int SKEL_RIGHT_HAND = 7;

final int SKEL_TORSO = 8;
final int SKEL_LEFT_HIP = 9; 
final int SKEL_LEFT_KNEE = 10;
final int SKEL_LEFT_FOOT = 11;

final int SKEL_RIGHT_HIP = 12;
final int SKEL_RIGHT_KNEE = 13;
final int SKEL_RIGHT_FOOT = 14;

final int SKEL_COUNT = 15;
*/

final int SKEL_HEAD = 0;
//final int SKEL_NECK = 1;
final int SKEL_LEFT_SHOULDER = 1;
final int SKEL_LEFT_ELBOW = 2;
final int SKEL_LEFT_HAND = 3;
final int SKEL_RIGHT_SHOULDER = 4;
final int SKEL_RIGHT_ELBOW = 5;
final int SKEL_RIGHT_HAND = 6;

//final int SKEL_TORSO = 8;
//final int SKEL_LEFT_HIP = 9; 
//final int SKEL_LEFT_KNEE = 10;
//final int SKEL_LEFT_FOOT = 11;
//
//final int SKEL_RIGHT_HIP = 12;
//final int SKEL_RIGHT_KNEE = 13;
//final int SKEL_RIGHT_FOOT = 14;

final int SKEL_COUNT = 7;


int[] joints = new int[SKEL_COUNT];
PVector[] jointPos = new PVector[SKEL_COUNT];
boolean[] jointValid = new boolean[SKEL_COUNT];


final int GESTURE_HAND_HAIR = 0;
final int GESTURE_HAND_CHIN = 1;
final int GESTURE_TWO_HANDS_EARS = 2;
final int GESTURE_HAND_FAR_FROM_BODY = 3;

final int GESTURE_SINGLE_HAND_CIRCLES = 4;
final int GESTURE_TWO_HANDS_GOING_UP = 5;
final int GESTURE_FULL_BODY_TWIST = 6;

final int GESTURE_COUNT = 7;

boolean gestureState[] = new boolean[GESTURE_COUNT];
String gestureName[] = new String[GESTURE_COUNT];

final int PIN_FOHN = 1;
final int PIN_LUFTER = 2;
final int PIN_RASIERAPPARAT = 3;
final int PIN_BOHRMASCHINE = 4;
final int PIN_STAUBSAUGER = 5;
final int PIN_MIXER = 6;
final int PIN_RADIOGERAT = 7;
final int PIN_WASSERKESSEL = 8;


/*
    public class Conductor {

      onGesture(g){
        switch g:

        case GESTURE_HAND_HAIR: PIN_FOHN,
        case GESTURE_SINGLE_HAND_CIRCLES:  PIN_LUFTER,
        case GESTURE_HAND_CHIN: PIN_RASIERAPPARAT,
        case GESTURE_HAND_FAR_FROM_BODY:    PIN_BOHRMASCHINE,
        case GESTURE_TWO_HANDS_GOING_UP: PIN_STAUBSAUGER,
        case GESTURE_FULL_BODY_TWIST: PIN_MIXER,
        case GESTURE_TWO_HANDS_EARS: PIN_RADIOGERAT,
  //PIN_WASSERKESSEL;
      }
    }
    */



    int pin = 12;


    void setup()
    {
      size(640, 480);
      frameRate(30);

      context = new SimpleOpenNI(this);
      if (context.isInit() == false)
      {
        println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
        exit();
        return;
      }

      context.setMirror(true);
  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();


  joints[SKEL_HEAD] = SimpleOpenNI.SKEL_HEAD;

  joints[SKEL_LEFT_SHOULDER] = SimpleOpenNI.SKEL_LEFT_SHOULDER;
  joints[SKEL_LEFT_ELBOW] = SimpleOpenNI.SKEL_LEFT_ELBOW;
  joints[SKEL_LEFT_HAND] = SimpleOpenNI.SKEL_LEFT_HAND;

  joints[SKEL_RIGHT_SHOULDER] = SimpleOpenNI.SKEL_RIGHT_SHOULDER;
  joints[SKEL_RIGHT_ELBOW] = SimpleOpenNI.SKEL_RIGHT_ELBOW;
  joints[SKEL_RIGHT_HAND] = SimpleOpenNI.SKEL_RIGHT_HAND;

/*
  joints[SKEL_NECK] = SimpleOpenNI.SKEL_NECK;
  joints[SKEL_TORSO] = SimpleOpenNI.SKEL_TORSO;

  joints[SKEL_LEFT_HIP] = SimpleOpenNI.SKEL_LEFT_HIP;
  joints[SKEL_LEFT_KNEE] = SimpleOpenNI.SKEL_LEFT_KNEE;
  joints[SKEL_LEFT_FOOT] = SimpleOpenNI.SKEL_LEFT_FOOT;

  joints[SKEL_RIGHT_HIP] = SimpleOpenNI.SKEL_RIGHT_HIP;
  joints[SKEL_RIGHT_KNEE] = SimpleOpenNI.SKEL_RIGHT_KNEE;
  joints[SKEL_RIGHT_FOOT] = SimpleOpenNI.SKEL_RIGHT_FOOT;
  */

  for(int i = 0; i < SKEL_COUNT; i++)
  {
    jointPos[i] = new PVector();
  }


  gestureName[GESTURE_HAND_HAIR] = "hand in hair";
  gestureName[GESTURE_HAND_CHIN] = "hand on chin";
  gestureName[GESTURE_TWO_HANDS_EARS] = "two hand in ears";
  gestureName[GESTURE_HAND_FAR_FROM_BODY] = "hand far from body";
  gestureName[GESTURE_SINGLE_HAND_CIRCLES] = "Single hand Circles";
  gestureName[GESTURE_TWO_HANDS_GOING_UP]  = "two hands going up";
  gestureName[GESTURE_FULL_BODY_TWIST] = "full body twist";


  String[] arduinoList = Arduino.list();

//  if (arduinoList.length > 0)
//  {

  arduino = new Arduino(this, arduinoList[0], 57600);
  // Set the Arduino digital pins as outputs.
  for (int i = 0; i <= 13; i++)
  {
    arduino.pinMode(i, Arduino.OUTPUT);
  }
//  }


background(200, 0, 0);

stroke(0, 0, 255);
strokeWeight(6);
smooth();
}

void draw()
{
  background(200, 0, 0);

  // update the cam
  context.update();

  // draw depthImageMap
  //image(context.depthImage(), 0, 0);
  image(context.userImage(), 0, 0);


  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      stroke(color(255, 0, 0));
      drawSkeleton(userList[i]);
    }  

    // if in spot


    int userId = userList[i];

    for(int j = 0; j < SKEL_COUNT; j++)
    {
      float confidence = context.getJointPositionSkeleton(userId, joints[j], jointPos[j]);
      jointValid[j] = confidence > 0.5;
    }

    if (jointValid[SKEL_HEAD] && jointValid[SKEL_RIGHT_HAND])
    {
      float diff = jointPos[SKEL_HEAD].z - jointPos[SKEL_RIGHT_HAND].z;
      if (diff > 200)
      {
        gestureState[GESTURE_HAND_FAR_FROM_BODY] = true;
        //arduino.digitalWrite(pin, Arduino.HIGH);
      }
      else
      {
        gestureState[GESTURE_HAND_FAR_FROM_BODY] = false;
       //arduino.digitalWrite(pin, Arduino.LOW);
     }

     //stroke(255, 255, 0);
     //strokeWeight(2);
      //line(joint1_2d.x, joint1_2d.y, joint2_2d.x, joint2_2d.y);
    }

    // update conductor: check gestureState and activate pins
    // todo: patterns, pulses, etc.




  }

/*
//draw UI
for (int g=0; g < GESTURE_COUNT; g++)
{
  int rectHeight = 30;
  int rectWidth = 200;
  int rectX = 50;
  int rectY = 50;

  int x = rectX;
  int y = rectY + (rectHeight + 10) * g;

  color onColor = color(255, 0, 0);
  color offColor = color(50, 50, 50);

  fill(gestureState[g] ? onColor : offColor);
  stroke(0);

  rect(x, y, rectWidth, rectHeight);

  fill(255);
  text(gestureName[g], x, y + rectHeight/2);

  //println("var: "+ gestureState[GESTURE_HAND_FAR_FROM_BODY]);
}
*/
  fill(255);
  
  text("FPS: " + nf(round(frameRate),2), 10, 10); 

  //update arduino
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
   println(jointPos);
   */

   context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

   context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
   context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
   context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

   context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
   context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
   context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

   context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
   context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

   context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
   context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
   context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

   context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
   context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
   context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
 }



// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  context.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
  switch(key)
  {
    case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  

