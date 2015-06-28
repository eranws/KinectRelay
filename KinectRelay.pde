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

 import processing.video.*;

 import SimpleOpenNI.*;

 import processing.serial.*;

 import cc.arduino.*;

 import java.util.ArrayList;

 public class PVectorArrayList extends ArrayList<PVector>{}

 public class Action
 {
 	public int what;
 	public int when;
 	Action(int what, int when)
 	{
 		this.what = what;
 		this.when = when;
 	}

 }

 public class ActionArrayList extends ArrayList<Action>{}

 final int PIN_RAZOR		= 0;
 final int PIN_HAIR_DRYER	= 1; 
 final int PIN_HAND_MIXER	= 2;
 final int PIN_RADIO		= 3;
 final int PIN_VENTILATOR	= 4;
 final int PIN_VACUUM		= 5;
 final int PIN_BLENDER		= 6;
 final int PIN_PROJECTOR	= 7;

 final int PIN_COUNT = 8;
 public int pinMap[] = new int[PIN_COUNT];

 public class Sequencer
 {



 	public ActionArrayList actions[] = new ActionArrayList[PIN_COUNT];
 	

 	Sequencer()
 	{
 		for(int i = 0; i < PIN_COUNT; i++)
 		{
 			actions[i] = new ActionArrayList();
 		}

 		pinMap[PIN_PROJECTOR] 	= 5;
 		pinMap[PIN_RAZOR] 		= 6;
 		pinMap[PIN_HAIR_DRYER]	= 7;
 		pinMap[PIN_HAND_MIXER]	= 8;
 		pinMap[PIN_RADIO]		= 9;
 		pinMap[PIN_VENTILATOR] 	= 10;
 		pinMap[PIN_VACUUM] 		= 11;
 		pinMap[PIN_BLENDER] 	= 12;


 		for(int i = 0; i < ARDUINO_PIN_COUNT; i++)
 		{
 			pinName[i] = "X (unassigned)";

 		}
 		pinName[pinMap[PIN_PROJECTOR]] = "Projector";

 		pinName[pinMap[PIN_RAZOR]] 		= "Razor";
 		pinName[pinMap[PIN_HAIR_DRYER]]	= "Hair Dryer";
 		pinName[pinMap[PIN_HAND_MIXER]]	= "Hand Mixer";
 		pinName[pinMap[PIN_RADIO]]		= "Radio";
 		pinName[pinMap[PIN_VENTILATOR]] = "Ventilator";
 		pinName[pinMap[PIN_VACUUM]] 	= "Vacuum";
 		pinName[pinMap[PIN_BLENDER]] 	= "Blender";

 	}

 	void clear()
 	{
 		for(int i = 0; i < PIN_COUNT; i++)
 		{
 			actions[i].clear();
 		}
 	}

 	void addSequence(int pin, int[] s, int rep, int delay)
 	{
 		int cumsum = millis() + delay;
 		for (int r=0; r<rep; r++)
 		{
 			for (int i=0; i<s.length; i++)
 			{

 				seq.actions[pin].add(new Action(i%2==0 ? on : off, cumsum));
 				cumsum += s[i];
 			}
 		}
 	}

 	void addSequence(int pin, int[] s, int rep)
 	{
 		addSequence(pin, s, rep, 0);
 	}

 	void addSequenceSafe(int pin, int[] s, int rep)
 	{
 		if (seq.actions[pin].isEmpty())
 		{
 			addSequence(pin, s, rep, 0);	
 		}
 	}



 	void update()
 	{
		// check time of head of queue - turn on/off pin
		for(int i = 0; i < PIN_COUNT; i++)
		{
			if (actions[i].size() > 0)
			{
				Action a = actions[i].get(0);
				if (a.when < millis())
				{
					actions[i].remove(0);
					arduinoWrapper.digitalWrite(pinMap[i], a.what);
				}
			}
		}

	}

	void draw()
	{
		// draw actions[]
	}


}

Sequencer seq;

public class ArduinoWrapper {
	PApplet app;
	Arduino realArduino;	
	boolean connected = false;

	boolean pinState[] = new boolean[ARDUINO_PIN_COUNT];

	ArduinoWrapper(PApplet app)
	{
		String[] arduinoList = Arduino.list();

		if (arduinoList.length > 0)
		{
			connected = true;
			realArduino = new Arduino(app, arduinoList[0], 57600);
		}

		for (int i=0; i<ARDUINO_PIN_COUNT; i++)
		{
			pinState[i] = false;
		}

	}

	void digitalWrite(int pin, int val)
	{
		if (connected)
		{
			realArduino.digitalWrite(pin, val);
		}

		pinState[pin] = (val == on);
	}

	void pinMode(int pin, int val)
	{
		if (connected)
		{
			realArduino.pinMode(pin, val);
		}
	}



}
ArduinoWrapper arduinoWrapper;

final int on = Arduino.LOW; //inverted relay 
final int off = Arduino.HIGH; //inverted relay


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

final int HISTORY_SIZE = 20;

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


final int GESTURE_HAND_CHIN_MAX_X = 100;
final int GESTURE_HAND_CHIN_MIN_Y = 100;
final int GESTURE_HAND_CHIN_MAX_Y = 300;
final int GESTURE_HAND_CHIN_MAX_Z = 200;

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

final int ARDUINO_PIN_COUNT = 14;
String pinName[] = new String[ARDUINO_PIN_COUNT];

final int STATE_IDLE = 0;
final int STATE_MORE_THAN_ONE = 1;
final int STATE_IN_SPOT = 2;
int state = STATE_IDLE;

final int demoTimeout = 15 * 1000; // 15 seconds
int demoLastReset;

Movie currentMovie;
Movie movie1;
Movie movie2;
Movie movie3; // more than 1
Movie movie4; // mov2 -> mov1
Movie movie5; // mov1 -> mov2


boolean drawGui = false;
boolean drawDepth = false;
boolean drawMovie = true;



void movieEvent(Movie m) {
	m.read();
}

void setup()
{
	//size(640, 480);
	size(displayWidth, displayHeight);

	frameRate(60);

	movie1 = new Movie(this, "mov1.mp4");
	movie2 = new Movie(this, "mov2.mp4");
	movie3 = new Movie(this, "mov3.mp4");
	movie4 = new Movie(this, "mov4.mp4");
	movie5 = new Movie(this, "mov5.mp4");

	currentMovie = movie1;
	currentMovie.loop();

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



  seq = new Sequencer();
  arduinoWrapper = new ArduinoWrapper(this);


  for (int i = 0; i <= 13; i++)
  {
  	arduinoWrapper.pinMode(i, Arduino.OUTPUT);
  }

  demoLastReset = millis();

  turnOffAll();
  delay(500);
  turnOffAllSafeAndSlow();

  noSmooth();

}

void draw()
{
	background(0);

	if (drawMovie)
	{
		image(currentMovie, 0, 0, displayWidth, displayHeight);	
	}
	
 	//image(movie2, mouseX, mouseY);
 	context.update();
 	if (drawDepth)
 	{
 		/* image(context.depthImage(), 0, 0) */
 		image(context.userImage(), 0, 0);
 	}
 	for (int i=0; i<GESTURE_COUNT; i++)
 	{
 		gestureState[i] = false;
 	}

 	int[] userList = context.getUsers();

 	int userId = -1;
 	int usersInSpot = 0;

 	for (int i=0; i<userList.length; i++){

 		if (context.isTrackingSkeleton(userList[i]))
 		{
 			stroke(color(255, 0, 0));
 			strokeWeight(6);
 			drawSkeleton(userList[i]);
 		}  


 		PVector com = new PVector();
 		context.getCoM(userList[i], com);


 		PVector spot = new PVector(0, 0, 2500);
 		float spotRadiusMin = 300;
 		float spotRadiusMax = 400;

 		PVector ds = new PVector(com.x - spot.x, com.z - spot.z);
 		if (ds.mag() < spotRadiusMin)
 		{
 			usersInSpot++;
 			userId = userList[i];	
 		}

 	}


 	if (usersInSpot == 0)
 	{
  	//run demo after timeout

  	if (state != STATE_IDLE)
  	{
  		state = STATE_IDLE;
  		for(int j = 0; j < SKEL_COUNT; j++)
  		{
  			histories[j].clear();
  		}
  		currentMovie.pause();
  		currentMovie = movie4;
  		currentMovie.loop();
  		movie1.jump(0.0);

  		demoLastReset = millis();

  		arduinoWrapper.digitalWrite(pinMap[PIN_PROJECTOR], off);
  	}
  	else
  	{
  		//println(demoLastReset);

  		if (millis() - demoLastReset > demoTimeout)
  		{
  			runDemo();
  		}
  	}

  	float md = currentMovie.duration();
  	float mt = currentMovie.time();

  	if (md-mt < 0.05)
  	{
  		if (currentMovie == movie4)
  		{
  			currentMovie.pause();
  			currentMovie.jump(0.0);

  			currentMovie = movie1;
  			currentMovie.loop();
  		}
  	}
  }

  if (usersInSpot > 1)
  {
  	
  	if (state != STATE_MORE_THAN_ONE)
  	{
  		state = STATE_MORE_THAN_ONE;

  		currentMovie.pause();
  		currentMovie = movie3;
  		currentMovie.loop();

  		arduinoWrapper.digitalWrite(pinMap[PIN_PROJECTOR], off);
  	}
  	
  }

  if (usersInSpot == 1)
  {
  	if (state != STATE_IN_SPOT)
  	{
  		state = STATE_IN_SPOT;

  		currentMovie.pause();
  		currentMovie = movie5;
  		currentMovie.loop();
  		movie2.jump(0.0);

  		turnOffAll();

  		arduinoWrapper.digitalWrite(pinMap[PIN_PROJECTOR], on);


  	}

  	float md = currentMovie.duration();
  	float mt = currentMovie.time();
  	if (md-mt < 0.05)
  	{
  		if (currentMovie==movie5) 
  		{
  			currentMovie.pause();
  			currentMovie.jump(0.0);

  			currentMovie = movie2;
  			currentMovie.loop();
  		}
  	}

  	updateJointHistory(userId);
  	upsateGestureState();
  }




  if (drawGui)
  {

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


  	for (int g=0; g < ARDUINO_PIN_COUNT; g++)
  	{
  		int rectHeight = 20;
  		int rectWidth = 200;
  		int rectX = 50;
  		int rectY = 50;

  		int x = 400 + rectX;
  		int y = rectY + (rectHeight * 2) * g;

  		color onColor = color(255, 0, 0);
  		color offColor = color(50, 50, 50);

  		fill(arduinoWrapper.pinState[g] ? onColor : offColor);
  		stroke(0);

  		rect(x, y, rectWidth, rectHeight);

  		fill(255);
  		textAlign(LEFT, CENTER);
  		textSize(rectHeight);
  		text(pinName[g], x, y + rectHeight/2);
  	}

  	fill(255);
  	textSize(20);

  	text("FPS: " + nf(round(frameRate),2), 10, 10); 

  }


  seq.update();

  updateArduino();

} //end draw


boolean checkSteady(int joint_id) {

	ArrayList<PVector> history = histories[joint_id];

	final int STEADY_COUNT = 4;

	if (history.size() < STEADY_COUNT) {
		return false;
	}

  // check for enough movement
  float avgDist = 0.0f;

  for (int h=1; h < STEADY_COUNT; h++)
  {
  	PVector r0 = history.get(history.size()-h);
  	PVector r1 = history.get(history.size()-h-1);

  	avgDist += PVector.dist(r0, r1);
  }

  //println(avgDist);

  return avgDist < 40;
}

boolean checkHandFar(float diffZ, float diffZother)
{
	return  (diffZ > GESTURE_HAND_FAR_FROM_BODY_MIN_Z);
	//  diffZother ???
}

boolean checkHandChin(float diffX, float diffY, float diffZ, float diffXother, float diffYother, float diffZother)
{
	return (diffZ > 0 && diffZ < GESTURE_HAND_CHIN_MAX_Z 
		&& abs(diffX) < GESTURE_HAND_CHIN_MAX_X
		&& diffY > GESTURE_HAND_CHIN_MIN_Y
		&& diffY < GESTURE_HAND_CHIN_MAX_Y

		&& diffYother > GESTURE_HAND_CHIN_MAX_Y
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

		&& diffYother > GESTURE_HAND_CHIN_MAX_Y
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
    if (drawGui)
    {
    	PVector p0 = new PVector();
    	PVector p1 = new PVector();
    	context.convertRealWorldToProjective(r0, p0);
    	context.convertRealWorldToProjective(r1, p1);

    	line(p0.x, p0.y, p1.x, p1.y);
    	rect(p1.x, p1.y, 3, 3);
    }

  }

  avg.div(history.size());
  avgDist /= (history.size() - 1);

  if (drawGui)
  {
   PVector avgProj = new PVector();
   context.convertRealWorldToProjective(avg, avgProj);

   fill(0, 255, 0);
   rect(avgProj.x, avgProj.y, 5, 5);
 }

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
	if (!drawDepth) return;

	PVector p = new PVector();
	context.convertRealWorldToProjective(real, p);

	textAlign(CENTER, CENTER);
	textSize(16); 

	rect(p.x, p.y, 10, 10);
	text(nf(int(real.z), 4), int(p.x), int(p.y));  
}

void drawJointDiff(PVector r1, PVector r2)
{
	if (!drawDepth) return;

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
	if (!drawDepth) return;
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
		case 'g':
		drawGui = !drawGui;
		break;

		case 'd':
		drawDepth = !drawDepth;
		break;

		case 'm':
		drawMovie = !drawMovie;
		break;

		

	}
}  

void updateJointHistory(int userId)
{
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
}

void upsateGestureState()
{	
	if (jointValid[SKEL_HEAD] && jointValid[SKEL_RIGHT_HAND] && jointValid[SKEL_LEFT_HAND])
	{    	
		float diffXL = jointPos[SKEL_HEAD].x - jointPos[SKEL_LEFT_HAND].x;
		float diffYL = jointPos[SKEL_HEAD].y - jointPos[SKEL_LEFT_HAND].y;
		float diffZL = jointPos[SKEL_HEAD].z - jointPos[SKEL_LEFT_HAND].z;

		float diffXR = jointPos[SKEL_HEAD].x - jointPos[SKEL_RIGHT_HAND].x;
		float diffYR = jointPos[SKEL_HEAD].y - jointPos[SKEL_RIGHT_HAND].y;
		float diffZR = jointPos[SKEL_HEAD].z - jointPos[SKEL_RIGHT_HAND].z;

		boolean rSteady = checkSteady(SKEL_RIGHT_HAND);
		boolean lSteady = checkSteady(SKEL_LEFT_HAND);

		if (rSteady)
		{
			gestureState[GESTURE_RIGHT_HAND_FAR_FROM_BODY] = checkHandFar(diffZR, diffZL);
			gestureState[GESTURE_RIGHT_HAND_CHIN] = checkHandChin(diffXR, diffYR, diffZR, diffXL, diffYL, diffZL);
			gestureState[GESTURE_RIGHT_HAND_HAIR] = checkHandHair(diffXR, diffYR, diffZR, diffXL, diffYL, diffZL);
		}

		if (lSteady)
		{
			gestureState[GESTURE_LEFT_HAND_FAR_FROM_BODY] = checkHandFar(diffZL, diffZR);
			gestureState[GESTURE_LEFT_HAND_CHIN] = checkHandChin(diffXL, diffYL, diffZL, diffXR, diffYR, diffZR);
			gestureState[GESTURE_LEFT_HAND_HAIR] = checkHandHair(-diffXL, diffYL, diffZL, diffXR, diffYR, diffZR);
		}

		if (lSteady && rSteady)
		{
			gestureState[GESTURE_TWO_HANDS_EARS] = checkTwoHandsEars(diffXR, diffYR, diffZR, diffXL, diffYL, diffZL);
		}	


		gestureState[GESTURE_RIGHT_HAND_CIRCLES] = checkCircle(SKEL_RIGHT_HAND);
		gestureState[GESTURE_LEFT_HAND_CIRCLES] = checkCircle(SKEL_LEFT_HAND);


		gestureState[GESTURE_TWO_HANDS_GOING_UP] = checkTwoHandsGoingUp();
		gestureState[GESTURE_FULL_BODY_TWIST] = checkFullBodyTwist();
	}
}


void updateArduino()
{
	if (gestureState[GESTURE_RIGHT_HAND_CHIN] || gestureState[GESTURE_LEFT_HAND_CHIN])
	{
		int[] s = new int[]{120, 120, 120, 120, 120, 120, 120, 120, 1000, 500};
		int repeat = 2;

		seq.addSequenceSafe(PIN_RAZOR, s, repeat);
	}

	if (gestureState[GESTURE_RIGHT_HAND_HAIR] || gestureState[GESTURE_LEFT_HAND_HAIR])
	{
		//Hair Dryer:
		int[] s = new int[]{3000, 1000};
		int repeat = 4;
		seq.addSequenceSafe(PIN_HAIR_DRYER, s, repeat);
	}

	if (gestureState[GESTURE_RIGHT_HAND_FAR_FROM_BODY] || gestureState[GESTURE_LEFT_HAND_FAR_FROM_BODY])
	{
		int[] s = new int[]{750, 250, 125, 125, 125, 125};
		int repeat = 4;
		seq.addSequenceSafe(PIN_HAND_MIXER, s, repeat);
	}

	if (gestureState[GESTURE_TWO_HANDS_EARS])
	{
		//Radio:
		int[] s = new int[]{500, 500, 2000, 1000};
		int repeat = 2;
		seq.addSequenceSafe(PIN_RADIO, s, repeat);
	}

	if (gestureState[GESTURE_RIGHT_HAND_CIRCLES] || gestureState[GESTURE_LEFT_HAND_CIRCLES])
	{
		//Stand Fan:
		int[] s = new int[]{4000, 2000};
		int repeat = 6;
		seq.addSequenceSafe(PIN_VENTILATOR, s, repeat);
	}


	if (gestureState[GESTURE_TWO_HANDS_GOING_UP])
	{
		//Vacuum:
		int[] s = new int[]{500, 500, 500, 500, 1500, 500};
		int repeat = 4;
		seq.addSequenceSafe(PIN_VACUUM, s, repeat);
	}

	if (gestureState[GESTURE_FULL_BODY_TWIST])
	{
		//Blender:
		int[] s = new int[]{500, 500, 500, 500, 1000, 500};
		int repeat = 4;
		seq.addSequenceSafe(PIN_BLENDER, s, repeat);
	}
}

int demoIndex = 0;
void runDemo()
{

  // 1 proj
  // 2 razor
  // 3 hair
  // 4 mixer
  // 5 radio
  // 6 stand fan
  // 7 vacuum
  // 8 blender

  if (demoIndex == 0) runDemo1();
  if (demoIndex == 1) runDemo2();
  if (demoIndex == 2) runDemo3();

  demoIndex++;
  demoIndex %= 3;

}

void runDemo1()
{
	println("rundemo1");

	demoLastReset = millis() + (35 + 10) * 1000; // demo length, total 35 + 15 timeout

	// [6 on]
	// 4 (0.5 on 0.2 off) ,4 (0.5 on 0.2 off),4 (0.5 on 0.2 off),7 (2 on)
	// 4 (0.5 on 0.2 off) ,4 (0.5 on 0.2 off),4 (0.5 on 0.2 off),7 (2 on)
	// 4 (0.5 on 0.2 off) ,4 (0.5 on 0.2 off),4 (0.5 on 0.2 off),7 (2 on)
	// [6 off]
	// (total 12300)

	{
		int[] s = new int[]{12000, 300};
		int repeat = 1;
		seq.addSequence(PIN_VENTILATOR, s, repeat);
	}
	{	
		int[] s = new int[]{500, 200, 500, 200, 500, 2200};
		int repeat = 3;
		seq.addSequence(PIN_HAND_MIXER, s, repeat, 0);
	}
	{	
		int[] s = new int[]{2000, 2100};
		int repeat = 3;
		seq.addSequence(PIN_VACUUM, s, repeat, 2100);
	}

	/*
	2 (0.2 on 0.2 off) ,4 (1 on),
	2 (0.2 on 0.2 off) ,4 (1 on),
	2 (0.2 on 0.2 off) ,4 (1 on), 
	2 (0.2 on 0.2 off) ,4 (1 on),
	(total 5600)
	*/

	{	
		int[] s = new int[]{200, 1200};
		int repeat = 4;
		seq.addSequence(PIN_RAZOR, s, repeat, 12300);
	}
	{	
		int[] s = new int[]{1000, 400};
		int repeat = 4;
		seq.addSequence(PIN_HAND_MIXER, s, repeat, 12300 + 400);
	}

	/*
	2 (0.2 on 0.2 off) , 
	2 (0.2 on 0.2 off) , 
	2 (0.2 on 0.2 off) , 
	2 (0.2 on 0.2 off) ,
	2 (0.2 on 0.2 off) ,
	3 (3 on)
	(total 5000)
	*/
	{	
		int[] s = new int[]{200, 200};
		int repeat = 5;
		seq.addSequence(PIN_RAZOR, s, repeat, 12300 + 5600);
	}
	{	
		int[] s = new int[]{3000, 100};
		int repeat = 4;
		seq.addSequence(PIN_HAIR_DRYER, s, repeat, 12300 + 5600 + 2000);
	}
	
	/*
	4 (0.5 on 0.2 off) ,4 (0.5 on 0.2 off),4 (0.5 on 0.2 off),7 (2 on)
	4 (0.5 on 0.2 off) ,4 (0.5 on 0.2 off),4 (0.5 on 0.2 off),7 (2 on)
	4 (0.5 on 0.2 off) ,4 (0.5 on 0.2 off),4 (0.5 on 0.2 off),7 (2 on)
	*/
	{	
		int[] s = new int[]{500, 200, 500, 200, 500, 2200};
		int repeat = 3;
		seq.addSequence(PIN_HAND_MIXER, s, repeat, 12300 + 5600 + 5000);
	}
	{	
		int[] s = new int[]{2000, 2100};
		int repeat = 3;
		seq.addSequence(PIN_VACUUM, s, repeat, 12300 + 5600 + 5000 + 2100);
	}


	/*
	2 (0.2 on 0.2 off) ,4 (1 on), 
	2 (0.2 on 0.2 off) ,4 (1 on), 
	2 (0.2 on 0.2 off) ,4 (1 on), 
	2 (0.2 on 0.2 off) ,4 (1 on),
	*/
	{	
		int[] s = new int[]{200, 200};
		int repeat = 4;
		seq.addSequence(PIN_RAZOR, s, repeat, 12300 + 5600 + 5000 + 12300);
	}
}

void runDemo2()
{
	println("rundemo2");

	demoLastReset = millis() + (22 + 10) * 1000; // demo length, total 35 + 15 timeout

	// 5 (5 on)
	// 2 (0.2 on, 0.7 off), 2 (0.2 on, 0.7 off), 2 (1 on)

	{
		int[] s = new int[]{5000, 1};
		int repeat = 1;
		seq.addSequence(PIN_RADIO, s, repeat);
	}
	{
		int[] s = new int[]{200, 700, 200, 700, 1000, 1};
		int repeat = 1;
		seq.addSequence(PIN_RAZOR, s, repeat, 5000);
	}

	// 4 ( 0.3 on), 2 (0.3 on), 8 (0.3 on), 7 ( 1.5 on)
	// 4 ( 0.3 on), 2 (0.3 on), 8 (0.3 on), 7 ( 1.5 on)
	// 4 ( 0.3 on), 2 (0.3 on), 8 (0.3 on), 7 ( 1.5 on)
	// 4 ( 0.3 on), 2 (0.3 on), 8 (0.3 on), 7 ( 1.5 on)
	{
		int[] s = new int[]{300, 2100};
		int repeat = 4;
		seq.addSequence(PIN_HAND_MIXER, s, repeat, 5000 + 2800);
	}
	{
		int[] s = new int[]{300, 2100};
		int repeat = 4;
		seq.addSequence(PIN_RAZOR, s, repeat, 5000 + 2800 + 300);
	}
	{
		int[] s = new int[]{300, 2100};
		int repeat = 4;
		seq.addSequence(PIN_BLENDER, s, repeat, 5000 + 2800 + 600);
	}
	{
		int[] s = new int[]{1500, 900};
		int repeat = 4;
		seq.addSequence(PIN_VACUUM, s, repeat, 5000 + 2800 + 900);
	}


	// 3 ( 1 on), 2 (0.2 on, 0.7 off), 2 (0.2 on, 0.7 off), 2 (1 on)
	{
		int[] s = new int[]{1000, 1};
		int repeat = 1;
		seq.addSequence(PIN_HAIR_DRYER, s, repeat, 5000 + 2800 + 9600);
	}
	{
		int[] s = new int[]{200, 700, 200, 700, 1000, 1};
		int repeat = 1;
		seq.addSequence(PIN_RAZOR, s, repeat, 5000 + 2800 + 9600 + 1000);
	}
}


void runDemo3()
{
	println("rundemo3");

	demoLastReset = millis() + (30 + 10) * 1000; // demo length, total 35 + 15 timeout

	// 6 (3 on 2 off), 6 (3 on 2 off), 6 (3 on 2 off),
  {
    int[] s = new int[]{3000, 2000};
    int repeat = 3;
    seq.addSequence(PIN_VENTILATOR, s, repeat);
  }

	// 5 [on]
	// 8 (0.3 on 0.2 off), 8 (0.3 on 0.2 off), 8 (0.3 on 0.2 off) ,8 (0.3 on 0.2 off), 8 (0.3 on 0.2 off)
	// 8 (0.3 on 0.2 off), 8 (0.3 on 0.2 off), 8 (0.3 on 0.2 off) ,8 (0.3 on 0.2 off), 8 (0.3 on 0.2 off)
	// 8 (0.3 on 0.2 off), 8 (0.3 on 0.2 off), 8 (0.3 on 0.2 off) ,8 (0.3 on 0.2 off), 8 (0.3 on 0.2 off)
	// 5[off]
	{
    int[] s = new int[]{300, 200};
    int repeat = 15;
    seq.addSequence(PIN_BLENDER, s, repeat, 15000);
  }
  {
    int[] s = new int[]{7500, 100};
    int repeat = 1;
    seq.addSequence(PIN_RADIO, s, repeat, 15000);
  }

  // 7 (3 on)
	// 
	// 2 ( 1 on), 4 (1 on), 3 (3 on)
  {
    int[] s = new int[]{3000, 1};
    int repeat = 1;
    seq.addSequence(PIN_VACUUM, s, repeat, 15000 + 7500);
  }
  {
    int[] s = new int[]{1000, 1};
    int repeat = 1;
    seq.addSequence(PIN_RAZOR, s, repeat, 15000 + 7500 + 3000);
  }
  {
    int[] s = new int[]{1000, 1};
    int repeat = 1;
    seq.addSequence(PIN_HAND_MIXER, s, repeat, 15000 + 7500 + 4000);
  }
  {
    int[] s = new int[]{3000, 1};
    int repeat = 1;
    seq.addSequence(PIN_HAIR_DRYER, s, repeat, 15000 + 7500 + 5000);
  }
}
void turnOffAll()
{
	for (int i = 0; i <= 13; i++)
	{
		arduinoWrapper.digitalWrite(i, off);
	}

	seq.clear();
}

void turnOffAllSafeAndSlow()
{	
	for (int i = 0; i <= 13; i++)
	{
		arduinoWrapper.digitalWrite(i, off);
		delay(100);
	}
}


void stop()
{
	context.close();
	movie1.stop();
	movie2.stop();
	movie3.stop();
	movie4.stop();
	movie5.stop();		

} 