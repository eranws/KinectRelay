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

 import java.util.ArrayList;

 public class PVectorArrayList extends ArrayList<PVector>{}

 Arduino arduino;

 final int on = Arduino.LOW;
 final int off = Arduino.HIGH;


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

final int HISTORY_SIZE = 10;

//ArrayList<PVector> history = new ArrayList<PVector>();


PVectorArrayList histories[] = new PVectorArrayList[SKEL_COUNT];


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



/// GESTURE thresholds
final int GESTURE_HAND_FAR_FROM_BODY_MIN_Z = 500; //mm. todo slider

final int GESTURE_HAND_CHIN_MAX_Z = 200;
final int GESTURE_HAND_CHIN_MAX_X = 100;
final int GESTURE_HAND_CHIN_MIN_Y = 100;
final int GESTURE_HAND_CHIN_MAX_Y = 300;
///
final int GESTURE_HAND_HAIR_MIN_X = -300;
final int GESTURE_HAND_HAIR_MAX_X = 100;
final int GESTURE_HAND_HAIR_MIN_Y = -300;
final int GESTURE_HAND_HAIR_MAX_Y = 50;
final int GESTURE_HAND_HAIR_MAX_Z = 200;
///
final int GESTURE_TWO_HANDS_EARS_MIN_X = 100;
final int GESTURE_TWO_HANDS_EARS_MAX_X = 200;
final int GESTURE_TWO_HANDS_EARS_MIN_Y = -50;
final int GESTURE_TWO_HANDS_EARS_MAX_Y = 150;
final int GESTURE_TWO_HANDS_EARS_MIN_Z = -100;
final int GESTURE_TWO_HANDS_EARS_MAX_Z = 100;


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
  	histories[i] = new PVectorArrayList();
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
  	arduino.digitalWrite(i, off);
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


  for (int i=0; i<GESTURE_COUNT; i++)
  {
  	gestureState[i] = false;
  }

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

    	if(jointValid[j])
    	{
    		histories[j].add(new PVector(jointPos[j].x, jointPos[j].y, jointPos[j].z));
    		if (histories[j].size() > HISTORY_SIZE)
    		{
    			histories[j].remove(0);
    		}
    	}
    	else
    	{
    		histories[j].clear();
    	}
    }


    if (jointValid[SKEL_HEAD] 
    	&& jointValid[SKEL_RIGHT_HAND]
    	&& jointValid[SKEL_LEFT_HAND]
    	)
    {

    	float diffXL = jointPos[SKEL_HEAD].x - jointPos[SKEL_LEFT_HAND].x;
    	float diffYL = jointPos[SKEL_HEAD].y - jointPos[SKEL_LEFT_HAND].y;
    	float diffZL = jointPos[SKEL_HEAD].z - jointPos[SKEL_LEFT_HAND].z;

    	float diffXR = jointPos[SKEL_HEAD].x - jointPos[SKEL_RIGHT_HAND].x;
    	float diffYR = jointPos[SKEL_HEAD].y - jointPos[SKEL_RIGHT_HAND].y;
    	float diffZR = jointPos[SKEL_HEAD].z - jointPos[SKEL_RIGHT_HAND].z;

    	gestureState[GESTURE_RIGHT_HAND_FAR_FROM_BODY] = checkHandFar(diffZR, diffZL);
    	gestureState[GESTURE_RIGHT_HAND_CHIN] = checkHandChin(diffXR, diffYR, diffZR, diffXL, diffYL, diffZL);
    	gestureState[GESTURE_RIGHT_HAND_HAIR] = checkHandHair(diffXR, diffYR, diffZR, diffXL, diffYL, diffZL);

    	gestureState[GESTURE_LEFT_HAND_FAR_FROM_BODY] = checkHandFar(diffZL, diffZR);
    	gestureState[GESTURE_LEFT_HAND_CHIN] = checkHandChin(diffXL, diffYL, diffZL, diffXR, diffYR, diffZR);
    	gestureState[GESTURE_LEFT_HAND_HAIR] = checkHandHair(-diffXL, diffYL, diffZL, diffXR, diffYR, diffZR);

    	gestureState[GESTURE_TWO_HANDS_EARS] = checkTwoHandsEars(diffXR, diffYR, diffZR, diffXL, diffYL, diffZL);


    	gestureState[GESTURE_RIGHT_HAND_CIRCLES] = checkCircle(SKEL_RIGHT_HAND);
    	gestureState[GESTURE_LEFT_HAND_CIRCLES] = checkCircle(SKEL_LEFT_HAND);


    	gestureState[GESTURE_TWO_HANDS_GOING_UP] = checkTwoHandsGoingUp();
    	gestureState[GESTURE_FULL_BODY_TWIST] = checkFullBodyTwist();
    }
///


}



    // update conductor: check gestureState and activate pins
    // todo: patterns, pulses, etc.


//draw UI
for (int g=0; g < GESTURE_COUNT; g++)
{
	int rectHeight = 12;
	int rectWidth = 200;
	int rectX = 50;
	int rectY = 50;

	int x = rectX;
	int y = rectY + (rectHeight * 2) * g;

	color onColor = color(255, 0, 0);
	color offColor = color(50, 50, 50);

	fill(gestureState[g] ? onColor : offColor);
	stroke(0);

	rect(x, y, rectWidth, rectHeight);

	fill(255);
	textAlign(LEFT, CENTER);
	textSize(rectHeight);
	text(gestureName[g], x, y + rectHeight/2);

}


fill(255);
textSize(20);

text("FPS: " + nf(round(frameRate),2), 10, 10); 

updateArduino();

} //end draw


boolean checkHandFar(float diffZ, float diffZother)
{
	return  (diffZ > GESTURE_HAND_FAR_FROM_BODY_MIN_Z);
	//  diffZother ???
}

boolean checkHandChin(float diffX, float diffY, float diffZ, float diffXother, float diffYother, float diffZother)
{
	return (diffZ > 0 && diffZ < GESTURE_HAND_FAR_FROM_BODY_MIN_Z 
		&& abs(diffX) < GESTURE_HAND_CHIN_MAX_X
		&& diffY > GESTURE_HAND_CHIN_MIN_Y
		&& diffY < GESTURE_HAND_CHIN_MAX_Y
		);

  //  otherHandZ ???
}

boolean checkHandHair(float diffX, float diffY, float diffZ, float diffXother, float diffYother, float diffZother)
{
	return (abs(diffZ) < GESTURE_HAND_HAIR_MAX_Z
		&& diffX > GESTURE_HAND_HAIR_MIN_X
		&& diffX < GESTURE_HAND_HAIR_MAX_X

		&& diffY > GESTURE_HAND_HAIR_MIN_Y
		&& diffY < GESTURE_HAND_HAIR_MAX_Y
		);
}

boolean checkTwoHandsEars(float diffX, float diffY, float diffZ, float diffXother, float diffYother, float diffZother)
{
	return (
		-diffX > GESTURE_TWO_HANDS_EARS_MIN_X
		&& -diffX < GESTURE_TWO_HANDS_EARS_MAX_X
		&& diffY > GESTURE_TWO_HANDS_EARS_MIN_Y
		&& diffY < GESTURE_TWO_HANDS_EARS_MAX_Y
		&& diffZ > GESTURE_TWO_HANDS_EARS_MIN_Z
		&& diffZ < GESTURE_TWO_HANDS_EARS_MAX_Z

		&& diffXother > GESTURE_TWO_HANDS_EARS_MIN_X
		&& diffXother < GESTURE_TWO_HANDS_EARS_MAX_X
		&& diffYother > GESTURE_TWO_HANDS_EARS_MIN_Y
		&& diffYother < GESTURE_TWO_HANDS_EARS_MAX_Y
		&& diffZother > GESTURE_TWO_HANDS_EARS_MIN_Z
		&& diffZother < GESTURE_TWO_HANDS_EARS_MAX_Z
		);
}

boolean checkCircle(int joint_id) {

	ArrayList<PVector> history = histories[joint_id];

	if (history.size() < HISTORY_SIZE) {
		return false;
	}

  // check for enough movement
  float avgDist = 0.0f;
  PVector h0 = history.get(0);
  PVector avg = new PVector();
  avg.set(h0);

  
  for (int h=1; h < history.size(); h++)
  {
  	PVector r0 = history.get(h);
  	PVector r1 = history.get(h-1);

  	avg.add(r0);
  	avgDist += PVector.dist(r0, r1);
  }

  final float ANGLE_MAX = 1.1f;
  boolean angleOK = true;
  

  for (int h=2; h < history.size(); h++)
  {
    // check smoothness

    PVector r0 = history.get(h);
    PVector r1 = history.get(h-1);
    PVector r2 = history.get(h-2);
    

    PVector rdiff0 = PVector.sub(r0, r1);
    PVector rdiff1 = PVector.sub(r1, r2);


    float angle = PVector.angleBetween(rdiff0, rdiff1);
    //println("angle: "+angle);
    

    if (angle > ANGLE_MAX)
    	angleOK = false;

    //draw history
    PVector p0 = new PVector();
    PVector p1 = new PVector();
    context.convertRealWorldToProjective(r0, p0);
    context.convertRealWorldToProjective(r1, p1);

    line(p0.x, p0.y, p1.x, p1.y);
    rect(p1.x, p1.y, 3, 3);
}

avg.div(history.size());
avgDist /= (history.size() - 1);

PVector avgProj = new PVector();
context.convertRealWorldToProjective(avg, avgProj);

fill(0, 255, 0);
rect(avgProj.x, avgProj.y, 5, 5);

float minDistFromAvg = 1000.0;
float maxDistFromAvg = 0.0;

for (int h=0; h < history.size(); h++)
{
	PVector r0 = history.get(h);
	float dist = PVector.dist(r0, avg);

	minDistFromAvg = min(minDistFromAvg, dist);
	maxDistFromAvg = max(maxDistFromAvg, dist);
}

  //println(minDistFromAvg, maxDistFromAvg);
  
  return (avgDist > 30
  	&& minDistFromAvg > 20
  	&& maxDistFromAvg / (minDistFromAvg+0.001) < 3
  	&& angleOK
  	);
}

boolean checkTwoHandsGoingUp() {

	ArrayList<PVector> historyR = histories[SKEL_RIGHT_HAND];
	ArrayList<PVector> historyL = histories[SKEL_LEFT_HAND];

	if (historyL.size() < HISTORY_SIZE 
		|| historyR.size() < HISTORY_SIZE ) {
		return false;
}

  // check for enough movement

  int rUpCount = 0;
  int lUpCount = 0;
  int rlSame = 0;

  for (int h=1; h < historyR.size(); h++)
  {
  	PVector r0 = historyR.get(h);
  	PVector r1 = historyR.get(h-1);

  	PVector l0 = historyL.get(h);
  	PVector l1 = historyL.get(h-1);

  	if ((r0.y - r1.y) > 10)
  		rUpCount++;

  	if ((l0.y - l1.y) > 10)
  		lUpCount++;

  	if (abs(r0.y - l0.y) < 100)
  		rlSame++;
  }


  // println(rUpCount, lUpCount, rlSame);
  
  return (rUpCount * 2 > (HISTORY_SIZE - 1)
  	&& lUpCount * 2 > (HISTORY_SIZE - 1)
  	&& rlSame * 2 > (HISTORY_SIZE - 1)
  	);
}



boolean checkFullBodyTwist() {

	ArrayList<PVector> historyR = histories[SKEL_RIGHT_SHOULDER];
	ArrayList<PVector> historyL = histories[SKEL_LEFT_SHOULDER];

	if (historyL.size() < HISTORY_SIZE 
		|| historyR.size() < HISTORY_SIZE ) {
		return false;
}

  // check for enough movement
  float avgAngle = 0.0f;
  float minAbsAngle = 999.9f;

  float[] angles = new float[HISTORY_SIZE-1];

  for (int h=1; h < historyR.size(); h++)
  {
  	PVector r0 = historyR.get(h);
  	PVector r1 = historyR.get(h-1);

  	PVector l0 = historyL.get(h);
  	PVector l1 = historyL.get(h-1);

  	PVector rdiff0 = PVector.sub(r0, l0);
  	PVector rdiff1 = PVector.sub(r1, l1);

  	float angle = PVector.angleBetween(rdiff0, rdiff1);

  	avgAngle += angle;
  	minAbsAngle = min(minAbsAngle, angle);
  	angles[h-1] = angle;
  }
  avgAngle /= (HISTORY_SIZE - 1);

  float minDistFromAvgAngle = 999.9f;

  for (int i=0; i < angles.length; i++)
  {
  	float diff = abs(angles[i] - avgAngle);
  	minDistFromAvgAngle = min(minDistFromAvgAngle, diff);
  }


  //println(minDistFromAvgAngle);

  return false; //minDistFromAvgAngle < THR


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
	int ts = 16;
	textSize(ts); 


	stroke(color(0, 255, 255));
	strokeWeight(3);
	line(p1.x, p1.y, p2.x, p2.y);


	PVector rdiff = PVector.sub(r1, r2);
	float dist = PVector.dist(r1, r2);
	PVector pmean = PVector.div(PVector.add(p1, p2), 2);

    //text(nf(int(dist), 4), int(pmean.x), int(pmean.y));
    //text(rdiff.toString(), int(pmean.x), int(pmean.y));
    text(nf(int(rdiff.x), 4), int(pmean.x), int(pmean.y)-ts*4);
    text(nf(int(rdiff.y), 4), int(pmean.x), int(pmean.y)-ts*3);
    text(nf(int(rdiff.z), 4), int(pmean.x), int(pmean.y)-ts*2);
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

void updateArduino()
{

	if (gestureState[GESTURE_RIGHT_HAND_CHIN] || gestureState[GESTURE_LEFT_HAND_CHIN])
	{
		arduino.digitalWrite(9, on);
	}
	else
	{
		arduino.digitalWrite(9, off);  
	}

	if (gestureState[GESTURE_RIGHT_HAND_HAIR] || gestureState[GESTURE_LEFT_HAND_HAIR])
	{
		arduino.digitalWrite(10, on);
	}
	else
	{
		arduino.digitalWrite(10, off);  
	}

	if (gestureState[GESTURE_RIGHT_HAND_FAR_FROM_BODY] || gestureState[GESTURE_LEFT_HAND_FAR_FROM_BODY])
	{
		arduino.digitalWrite(11, on);
	}
	else
	{
		arduino.digitalWrite(11, off);  
	}

	if (gestureState[GESTURE_TWO_HANDS_EARS])
	{
		arduino.digitalWrite(12, on);
	}
	else
	{
		arduino.digitalWrite(12, off);  
	}

}