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


final int GESTURE_RIGHT_HAND_HAIR = 0;
final int GESTURE_LEFT_HAND_HAIR = 1;

final int GESTURE_RIGHT_HAND_CHIN = 2;
final int GESTURE_LEFT_HAND_CHIN = 3;

final int GESTURE_RIGHT_HAND_FAR_FROM_BODY = 4;
final int GESTURE_LEFT_HAND_FAR_FROM_BODY = 5;

final int GESTURE_TWO_HANDS_EARS = 6;


final int GESTURE_RIGHT_HAND_CIRCLES = 7;
final int GESTURE_LEFT_HAND_CIRCLES = 8;

final int GESTURE_TWO_HANDS_GOING_UP = 9;
final int GESTURE_FULL_BODY_TWIST = 10;

final int GESTURE_COUNT = 11;

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
  //context.enableDepth(320,240,30); // faster

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


  gestureName[GESTURE_RIGHT_HAND_HAIR] = "right hand in hair";
  gestureName[GESTURE_LEFT_HAND_HAIR] = "left hand in hair";
  
  gestureName[GESTURE_RIGHT_HAND_CHIN] = "right hand on chin";
  gestureName[GESTURE_LEFT_HAND_CHIN] = "left hand on chin";
  
  gestureName[GESTURE_TWO_HANDS_EARS] = "two hand in ears";
  gestureName[GESTURE_RIGHT_HAND_FAR_FROM_BODY] = "right hand far from body";
  gestureName[GESTURE_LEFT_HAND_FAR_FROM_BODY] = "left hand far from body";
  
  gestureName[GESTURE_RIGHT_HAND_CIRCLES] = "right hand Circles";
  gestureName[GESTURE_LEFT_HAND_CIRCLES] = "left hand Circles";
  
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

noSmooth();

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
      strokeWeight(6);
      drawSkeleton(userList[i]);
    }  

    // if in spot


    int userId = userList[i];

    for(int j = 0; j < SKEL_COUNT; j++)
    {
      float confidence = context.getJointPositionSkeleton(userId, joints[j], jointPos[j]);
      jointValid[j] = confidence > 0.5;
    }


    // 
    // static gesture check
    //

  final int GESTURE_HAND_FAR_FROM_BODY_THRESHOLD = 400; //mm. todo slider

    if (jointValid[SKEL_HEAD] && jointValid[SKEL_RIGHT_HAND])
    {
      float diffX = jointPos[SKEL_HEAD].x - jointPos[SKEL_RIGHT_HAND].x;
      float diffY = jointPos[SKEL_HEAD].y - jointPos[SKEL_RIGHT_HAND].y;
      float diffZ = jointPos[SKEL_HEAD].z - jointPos[SKEL_RIGHT_HAND].z;

      if (diffZ > GESTURE_HAND_FAR_FROM_BODY_THRESHOLD)
      {
        gestureState[GESTURE_RIGHT_HAND_FAR_FROM_BODY] = true;
      }
      else
      {
        gestureState[GESTURE_RIGHT_HAND_FAR_FROM_BODY] = false;
      }

// println(diffX, diffY, diffZ);

      if (diffZ > 0 && diffZ < GESTURE_HAND_FAR_FROM_BODY_THRESHOLD 
        && abs(diffX) < 100
        && diffY > 100
        && diffY < 300

        )
      {
        gestureState[GESTURE_RIGHT_HAND_CHIN] = true;
      }
      else
      {
       gestureState[GESTURE_RIGHT_HAND_CHIN] = false; 
      }



    }

    if (jointValid[SKEL_HEAD] && jointValid[SKEL_LEFT_HAND])
    {
      
      float diffX = jointPos[SKEL_HEAD].x - jointPos[SKEL_LEFT_HAND].x;
      float diffY = jointPos[SKEL_HEAD].y - jointPos[SKEL_LEFT_HAND].y;
      float diffZ = jointPos[SKEL_HEAD].z - jointPos[SKEL_LEFT_HAND].z;


      if (diffZ > GESTURE_HAND_FAR_FROM_BODY_THRESHOLD)
      {
        gestureState[GESTURE_LEFT_HAND_FAR_FROM_BODY] = true;
      }
      else
      {
        gestureState[GESTURE_LEFT_HAND_FAR_FROM_BODY] = false;
      }


      if (diffZ > 0 && diffZ < GESTURE_HAND_FAR_FROM_BODY_THRESHOLD 
        && abs(diffX) < 100
        && diffY > 100
        && diffY < 300

        )
      {
        gestureState[GESTURE_LEFT_HAND_CHIN] = true;
      }
      else
      {
       gestureState[GESTURE_LEFT_HAND_CHIN] = false; 
      }

    }


    
    //GESTURE_HAND_CHIN = 1;

    
drawJointDiff(jointPos[SKEL_HEAD], jointPos[SKEL_LEFT_HAND]);
drawJointDiff(jointPos[SKEL_HEAD], jointPos[SKEL_RIGHT_HAND]);

    drawJoint(jointPos[SKEL_HEAD]);
    drawJoint(jointPos[SKEL_LEFT_HAND]);
    drawJoint(jointPos[SKEL_RIGHT_HAND]);

    

//GESTURE_HAND_HAIR = 0;
//GESTURE_TWO_HANDS_EARS




    // update conductor: check gestureState and activate pins
    // todo: patterns, pulses, etc.




  }


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
  textAlign(LEFT, CENTER);
  text(gestureName[g], x, y + rectHeight/2);

  //println("var: "+ gestureState[GESTURE_HAND_FAR_FROM_BODY]);
}


  fill(255);
  textSize(20);

  text("FPS: " + nf(round(frameRate),2), 10, 10); 

  //update arduino
}


void drawJoint(PVector real)
{
    PVector p = new PVector();
    context.convertRealWorldToProjective(real, p);

    textAlign(CENTER, CENTER);
    textSize(16); 

    rect(p.x, p.y, 10, 10);
    text(nf(int(real.z), 4), int(p.x), int(p.y));  
}

void drawJointDiff(PVector r1, PVector r2)
{
    PVector p1 = new PVector();
    context.convertRealWorldToProjective(r1, p1);

    PVector p2 = new PVector();
    context.convertRealWorldToProjective(r2, p2);

    textAlign(CENTER, CENTER);
    textSize(16); 

    line(p1.x, p1.y, p2.x, p2.y);


    PVector rdiff = PVector.sub(r1, r2);
    float dist = PVector.dist(r1, r2);
    PVector pmean = PVector.div(PVector.add(p1, p2), 2);

    text(nf(int(dist), 4), int(pmean.x), int(pmean.y));  
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

