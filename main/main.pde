/* processing code for ShitDonaldTrumpSays */

/// interface with browser
interface JavaScript {
  void reDoSearch();
  void saveCurFrame(int fncount, String tweet);
  void saveGifFromFrames(String tweet);
}
void bindJavascript(JavaScript js) {
  javascript = js;
}
JavaScript javascript;

PFont impactFont;

PImage curMouth;
PImage curFace;


// typewriting params
// boolean doLoop = true;
boolean isPaused = false;
boolean loadedTypewriter = false;

int sylbCount = 0; /// counter for current syllable
int letCount = 0; /// counter for which letter we're at
int tweetCount = 0; /// counter for which tweet we're at

boolean hasSylb = false;
boolean hasBreak = false; // has line break
int breakPoint = 0;
String sylb = "";
String curChar = "";
String startText; /// starting string
String spokenText; // text as spoken
String upTxt; // uppercase text

int poseStyle = 0;
String trumpPath = "data/trump_blank.png";
String trumpPath1 = "data/trump_lean.png";
String trumpPath2 = "data/trump_lean2.png";
String trumpPath3 = "data/trump_eff.png";
String trumpPath4 = "data/trump_thumbs.png";
String trumpPath5 = "data/trump_gah.png";
String trumpPath6 = "data/trump_flat.png";
String trumpPath7 = "data/trump_lick.png";
/// text data arrays
String mouthPath; // path to the current mouth
String facePath; // path to the current mouth
String mouthPathArray[] = new String[14]; // paths to mouth positions
String facePathArray[] = new String[8]; // paths to face positions
ArrayList <PImage> ImgMouthArray = new ArrayList(); /// array to hold all mouth images
ArrayList <PImage> ImgFaceArray = new ArrayList(); /// array to hold all face images
ArrayList <String> charArray = new ArrayList(); /// hold all the chars we cycle through
ArrayList <String> sylbArray = new ArrayList(); /// hold all the chars in a syllable
ArrayList <String> textArray = new ArrayList(); /// this holds the phrases taken from tweets

ArrayList <String> tweetArray = new ArrayList();
ArrayList <String> nameArray = new ArrayList();

/// positioning and data
float mouthPosX = 200;
float mouthPosY = 200;

float facePosX = 0;
float facePosY = 0;

int textBoxPosX = -10;
int textBoxPosY = -10;

float maskX = textBoxPosX;
float textBoxWidth = 380;
float textBoxHeight = 300;

int lastRecordedTime = 0;
float textPos = textBoxPosY;

Timer CharTimer;
Timer ResetTimer;

boolean resetTick = false;

int charSpeed = 6;
int sylbSpeed = 6;

int resetSpeed = 5000; /// 10000; // nice interval

boolean isFirst = false;

//// timer info
int interval = 2800000;// 1000 is one seconds, so 900000 redoes search every half hour

void setup() {
  size(400,300);
  // size(window.innerWidth, window.innerHeight);
  /// size(800, 600);
  impactFont = createFont("impact", 30); // loadFont("Impact-all.vlw");
  textFont(impactFont);
  textAlign(CENTER);
  textLeading(28);

  textArray.add(""); /// set default 
  CharTimer = new Timer(charSpeed);
  CharTimer.start();
  
  ResetTimer = new Timer(resetSpeed);
  // ResetTimer.start();

  /// add paths to array. This is clumsy, but we'll be updating all the damn time
  //////// this is for compiling processingjs
  ///*
  mouthPathArray[0] = "data/clay_mouth_stop.png"; //stop b  p m
  mouthPathArray[1] = "data/clay_mouth_a.png"; // a i u
  mouthPathArray[2] = "data/clay_mouth_d.png"; //d
  mouthPathArray[3] = "data/clay_mouth_e.png"; // e y h
  mouthPathArray[4] = "data/clay_mouth_f.png"; //f v
  mouthPathArray[5] = "data/clay_mouth_l.png"; //l th
  mouthPathArray[6] = "data/clay_mouth_m.png"; // m
  mouthPathArray[7] = "data/clay_mouth_n.png"; // n
  mouthPathArray[8] = "data/clay_mouth_o.png"; // o w
  mouthPathArray[9] = "data/clay_mouth_r.png"; //  r
  mouthPathArray[10] = "data/clay_mouth_s.png"; //  s c z
  mouthPathArray[11] = "data/clay_mouth_t.png"; //  t
  mouthPathArray[12] = "data/clay_mouth_oo.png";
  mouthPathArray[13] = "data/clay_mouth_none.png"; //stop this looks nice for the poses

/*
  mouthPathArray[0] = "data/mouth_stop.png"; //stop b  p m
  mouthPathArray[1] = "data/mouth_a.png"; // a i u
  mouthPathArray[2] = "data/mouth_d.png"; //d
  mouthPathArray[3] = "data/mouth_e.png"; // e y h
  mouthPathArray[4] = "data/mouth_f.png"; //f v
  mouthPathArray[5] = "data/mouth_l.png"; //l th
  mouthPathArray[6] = "data/mouth_m.png"; // m
  mouthPathArray[7] = "data/mouth_n.png"; // n
  mouthPathArray[8] = "data/mouth_o.png"; // o w
  mouthPathArray[9] = "data/mouth_r.png"; //  r
  mouthPathArray[10] = "data/mouth_s.png"; //  s c z
  mouthPathArray[11] = "data/mouth_t.png"; //  t
  */
  for (int i=0; i < mouthPathArray.length; i++) {
    String mp = mouthPathArray[i];
    curMouth = loadImage(mp);
    ImgMouthArray.add(curMouth);
  }
  
 facePathArray[0] = trumpPath;
 facePathArray[1] = trumpPath1; 
 facePathArray[2] = trumpPath2; 
 facePathArray[3] = trumpPath3; 
 facePathArray[4] = trumpPath4; 
 facePathArray[5] = trumpPath5; 
 facePathArray[6] = trumpPath6; 
 facePathArray[7] = trumpPath7; 
 
 for (int j=0; j < facePathArray.length; j++) {
    String fp = facePathArray[j];
    curFace = loadImage(fp);
    ImgFaceArray.add(curFace);
  }
  

  curMouth = ImgMouthArray.get(0);
  curFace = ImgFaceArray.get(0);
  CharTimer.start();
  
  //// add default first tweet
  tweetArray.add("tweet stub");
  nameArray.add("user stub");
}

void draw() {
  noStroke();
  background(0,0,0,0);

   //did the interval' time pass?
  if(millis()-lastRecordedTime>interval){
    // display slide
   //and record time for next tick
   lastRecordedTime = millis();
   redoSearch();
  } 

  // draw face 
  curFace.resize(0,300);
  facePosX = width/2-curFace.width/2;
  facePosY = height - curFace.height;
  image(curFace,facePosX,facePosY);
  // draw mouth
  curMouth.resize(0,30);
  mouthPosX = width/2 + curMouth.width/2 - 15;
  mouthPosY = height/2 + curMouth.height/2 - 2;
  image(curMouth, mouthPosX, mouthPosY );
  
  /// check for resets and pauses
  /// disable for first time around
  
  if(isFirst == true){
    resetTick = ResetTimer.update();
    if(resetTick){
      println("RESET TIMER STOPPED");
      
      ResetTimer.stop();
      isPaused = false;
      CharTimer.start();

    }
  }

  //*/
  /// draw text
  drawText();
}

//// TYPEWRITING TEXT ANIMATIONS //////////////////////////
void drawText() {

  /// If we havent initialized the typewriter, then do it
  if (!loadedTypewriter) {
    String tString = textArray.get(0);
    initTypewriter(tString);
  }

  /// check the char timer and
  /// increment the current letter
  boolean charTick = CharTimer.update();
  /// speak char if we're updating chars
  if (charTick) {
    println("TICK");
    // check to see if we have said the whole phrase
    // if so, pause and get the next tweet
    if (letCount >= charArray.size()) {
      
      /// pause char timer
      CharTimer.stop();
      /// save gif
      String curTweet = "";
      // check to make sure we have tweets
      ///*
      try{
        /// if we do this it's sending all the **
        String twt = spokenText.substring(0,139);
        /// test to make sure we're not doing the tweet stub
        curTweet = tweetArray.get(tweetCount).substring(0,130);
        if(curTweet != "tweet stub"){
           doGifExport(twt);
        }

        /// start reset timer
        isPaused = true;
        ResetTimer.start();
        println("ALL STOPPED");
        println("RESET TIMER STARTED");
      } catch(Exception e){
        println("error doing gif export: " + e);
      }
      //*/
      
      tweetCount ++;
      
      // if we've read all the tweets then start over from the first tweet in the array
      if (tweetCount >= tweetArray.size()) {
        letCount = 0;
        tweetCount = 0;
        String tString = "default tweet";
        try{
          tString = tweetArray.get(tweetCount);
        } catch (Exception e){
          println("error finding tweet");
        }
        initTypewriter(tString);
        // addText(spokenText);
      } else {
        letCount = 0;
        String tString = tweetArray.get(tweetCount);
        initTypewriter(tString);
        
      }

      /// otherwise go to the next letter and read it
    } else {
      
      /// let's only do this the first time
      /*
       if(letCount >= charArray.size()-2){
         hasSaved = true;
       }
      if(hasSaved == false){
        
         doFrameExport();
          ////// export the current frame
      }
      */
      doFrameExport();
      curChar = charArray.get(letCount);
      /// kill the pose char
      if(curChar == "*"){
        spokenText = spokenText + " ";
      } else {
        spokenText = spokenText + curChar;
      }
      
      /// check to see if we have a legit syllable
      for (int i = 0; i<2; i++) {
        int tid = letCount + i;
        if (tid >= charArray.size()) {
          sylb = ""; /// sylb.append(i);
        } else {
          // sylb = charArray.get(letCount) + charArray.get(tid);
          sylb = charArray.get(letCount) + charArray.get(tid);
        }
      }

      /// increment
      letCount++;
      sylbCount ++;
      //// if we've said all the syllables, go back to speaking characters
      if (sylbCount >= sylbArray.size()) {
        hasSylb = false;
      }
    }
  }

  /// send our syllable and char to mouth position
  doMouthPosition(curChar, sylb);
  /// display the actual text text
  upTxt = spokenText.toUpperCase();
  // format

  // split the text up to header + footer
  // on the soonest space after 50 chars
  // and set the breakpoint
  if(upTxt.length() > 50 && curChar == " " && hasBreak == false ){
    breakPoint = upTxt.length();
    hasBreak = true;
  }
  if(!hasBreak){

    fill(0,0,0);
    int newX = textBoxPosX-1;
    for(newX = -1; newX < 2; newX++){
  
        text(upTxt, 20+newX,20, textBoxWidth, textBoxHeight);
        text(upTxt, 20,20+newX, textBoxWidth, textBoxHeight);
    }
    fill(255);
    text(upTxt, 20,20, textBoxWidth, textBoxHeight);
    
    
  } else {
    // do top box
    String tpTxt = upTxt.substring(0,breakPoint);
    
    fill(0,0,0);
    int newX = textBoxPosX-1;
    for(newX = -1; newX < 2; newX++){
  
        text(tpTxt, 20+newX,20, textBoxWidth, textBoxHeight);
        text(tpTxt, 20,20+newX, textBoxWidth, textBoxHeight);
    }
    fill(255);
    text(tpTxt, 20,20, textBoxWidth, textBoxHeight);
    
    // do bot box
    String btTxt = upTxt.substring(breakPoint);
    fill(0,0,0);
    int newBX = textBoxPosX-1;
    for(newBX = -1; newBX < 2; newBX++){
  
        text(btTxt, 20+newBX,220, textBoxWidth, textBoxHeight);
        text(btTxt, 20,220+newBX, textBoxWidth, textBoxHeight);
    }
    fill(255);
    text(btTxt, 20,220, textBoxWidth, textBoxHeight);
    
  }
  
  isFirst = true;
  // text(upTxt, textBoxPosX, textBoxPosY, textBoxWidth, textBoxHeight);
}

////////////////////////////////////////
/////// export frames and gif /////////////////////
////////////////////////////////////////
void doFrameExport(){
  if (javascript!=null) {
    /// display the actual text text
    upTxt = spokenText.toUpperCase();
  // split the text up to header + footer
  // on the soonest space after 50 chars
  // and set the breakpoint
  if(upTxt.length() > 50 && curChar == " " && hasBreak == false ){
    breakPoint = upTxt.length();
    hasBreak = true;
  }
  if(!hasBreak){

    fill(0,0,0);
    int newX = textBoxPosX-1;
    for(newX = -1; newX < 2; newX++){
  
        text(upTxt, 20+newX,20, textBoxWidth, textBoxHeight);
        text(upTxt, 20,20+newX, textBoxWidth, textBoxHeight);
    }
    fill(255);
    text(upTxt, 20,20, textBoxWidth, textBoxHeight);
    
    
  } else {
    // do top box
    String tpTxt = upTxt.substring(0,breakPoint);
    
    fill(0,0,0);
    int newX = textBoxPosX-1;
    for(newX = -1; newX < 2; newX++){
  
        text(tpTxt, 20+newX,20, textBoxWidth, textBoxHeight);
        text(tpTxt, 20,20+newX, textBoxWidth, textBoxHeight);
    }
    fill(255);
    text(tpTxt, 20,20, textBoxWidth, textBoxHeight);
    
    // do bot box
    String btTxt = upTxt.substring(breakPoint);
    fill(0,0,0);
    int newBX = textBoxPosX-1;
    for(newBX = -1; newBX < 2; newBX++){
  
        text(btTxt, 20+newBX,220, textBoxWidth, textBoxHeight);
        text(btTxt, 20,220+newBX, textBoxWidth, textBoxHeight);
    }
    fill(255);
    text(btTxt, 20,220, textBoxWidth, textBoxHeight);
    
  }
    javascript.saveCurFrame(letCount, upTxt);
  }
}
void doGifExport(String tweetcaption){
  
  if (javascript!=null) {
    javascript.saveGifFromFrames(tweetcaption);
  } 
}
 


///////////////////////////////////////
////// DO MOUTH POSITIONS //////////////
////////////////////////////////////////

void doMouthPosition(String tChar, String sylb) {

  switch (sylb) {

    case "ph":
      if (hasSylb == false) {
        prepSyllable("ff");
      }
      break;
  
    case "ce ":
      // println("Cur syllable: " +sylb);
      if (hasSylb == false) {
        prepSyllable("se");
      }
      break;
  
    case "ck":
      // println("Cur syllable: " +sylb);
      if (hasSylb == false) {
        prepSyllable("kk");
      }
      break;
  
    case "by":
      // println("Cur syllable: " +sylb);
      if (hasSylb == false) {
        prepSyllable("ba");
      }
      break;
  
    case "dj":
      // println("Cur syllable: " +sylb);
      if (hasSylb == false) {
        prepSyllable("da");
      }
      break;
  
    case "vj":
      // println("Cur syllable: " +sylb);
      if (hasSylb == false) {
        prepSyllable("va");
      }
      break;
  
    case "nt":
      // println("Cur syllable: " +sylb);
      if (hasSylb == false) {
        prepSyllable("tt");
      }
      break;
  
    case "ta":
      // println("Cur syllable: " +sylb);
      if (hasSylb == false) {
        prepSyllable("ta");
      }
      break;
  
    case "oy":
      // println("Cur syllable: " +sylb);
      if (hasSylb == false) {
        prepSyllable("oe");
      }
      break;
  
    case "ou":
      // println("Cur syllable: " +sylb);
      if (hasSylb == false) {
        prepSyllable("oo");
      }
     case "**":
      // println("Cur syllable: " +sylb);
      if (hasSylb == false) {
        prepSyllable("**");
      }
    
    break;

  default:

    /// if no match with syllables, just jump to a character
    try {
      if (tChar == " ") {
        // println("CUR LETTER is a SPACE");
      } else {
        // if we're speaking a syllable, pass the current syllable instead of the current character
        if (hasSylb) {
          String tSylb = sylbArray.get(sylbCount);
          sayLetter(tSylb);
        } else {
          sayLetter(tChar);
        }
      }
    } 
    catch(Exception e) {
      //// mouthPlayer.gotoAndStop("stop")
      println("letter doesn't exist in mouth:" + curChar + ":::" + e);
    }

    break;
  }
}

void prepSyllable(String tSylb) {

  // println("PREP SYLLB: " + tSylb);
  // load syllable array with the sylb
  hasSylb = true;
  // get a random pose
  poseStyle = (int)random(facePathArray.length-1);
  sylbCount = 0;
  sylbArray = new ArrayList(); 
  // add the phonemes we want to the syllable array
  char[] allSylbs = new char[tSylb.length()];
  for (int i = 0; i < tSylb.length(); i++) {
    allSylbs[i] = tSylb.charAt(i);

    sylbArray.add(str(tSylb.charAt(i)));
  }
  /// say the first letter in the syllable array
  sayLetter(sylbArray.get(sylbCount));
}


void sayLetter(String tChar) {

  /*
  if (hasSylb) {
    println("Cur sylb letter: " +tChar);
  } else {
    println("Cur char: " + tChar);
  }
  */
  //// load image corresponding with the char

  switch(tChar) {

  case "a": ///
    curMouth = ImgMouthArray.get(1);
    curFace = ImgFaceArray.get(0);
    break;

  case "b"://
    curMouth = ImgMouthArray.get(0);
    curFace = ImgFaceArray.get(0);
    break;

  case "c"://
    curMouth = ImgMouthArray.get(9);
    curFace = ImgFaceArray.get(0);
    break;

  case "d"://
    curMouth = ImgMouthArray.get(2);
    curFace = ImgFaceArray.get(0);
    break;
  case "e"://
    curMouth = ImgMouthArray.get(3);
    curFace = ImgFaceArray.get(0);
    break;

  case "f"://
    curMouth = ImgMouthArray.get(4);
    curFace = ImgFaceArray.get(0);
    break;

  case "g":
    curMouth = ImgMouthArray.get(0);
    curFace = ImgFaceArray.get(0);
    break;

  case "h"://
    curMouth = ImgMouthArray.get(3);
    curFace = ImgFaceArray.get(0);
    break;
  case "i"://
    curMouth = ImgMouthArray.get(1);
    curFace = ImgFaceArray.get(0);
    break;

  case "j":
    curMouth = ImgMouthArray.get(0);
    curFace = ImgFaceArray.get(0);
    break;

  case "k":
    curMouth = ImgMouthArray.get(0);
    curFace = ImgFaceArray.get(0);
    break;

  case "l"://
    curMouth = ImgMouthArray.get(5);
    curFace = ImgFaceArray.get(0);
    break;

  case "m"://
    curMouth = ImgMouthArray.get(6);
    curFace = ImgFaceArray.get(0);
    break;

  case "n"://
    curMouth = ImgMouthArray.get(7);
    curFace = ImgFaceArray.get(0);
    break;

  case "o"://
    curMouth = ImgMouthArray.get(8);
    curFace = ImgFaceArray.get(0);
    break;

  case "p"://
    curMouth = ImgMouthArray.get(0);
    curFace = ImgFaceArray.get(0);
    break;

  case "q"://
    curMouth = ImgMouthArray.get(0);
    curFace = ImgFaceArray.get(0);
    break;

  case "r"://
    curMouth = ImgMouthArray.get(9);
    curFace = ImgFaceArray.get(0);
    break;

  case "s"://
    curMouth = ImgMouthArray.get(10);
    curFace = ImgFaceArray.get(0);
    break;

  case "t"://
    curMouth = ImgMouthArray.get(11);
    curFace = ImgFaceArray.get(0);
    break;

  case "u"://
    curMouth = ImgMouthArray.get(1);
    curFace = ImgFaceArray.get(0);
    break;

  case "v"://
    curMouth = ImgMouthArray.get(4);
    curFace = ImgFaceArray.get(0);
    break;

  case "w"://
    curMouth = ImgMouthArray.get(8);
    curFace = ImgFaceArray.get(0);
    break;

  case "x"://
    curMouth = ImgMouthArray.get(0);
    curFace = ImgFaceArray.get(0);
    break;

  case "y"://
    curMouth = ImgMouthArray.get(3);
    curFace = ImgFaceArray.get(0);
    break;

  case "z":
    curMouth = ImgMouthArray.get(10);
    curFace = ImgFaceArray.get(0);
    // mouthPath = mouthPathArray[10];
    break;

///// SPECIAL CHARACTERS


    case "*":
    curMouth = ImgMouthArray.get(13);
    curFace = ImgFaceArray.get(poseStyle);
    // mouthPath = mouthPathArray[10];
    break;
    
    case "#":
    curMouth = ImgMouthArray.get(13);
    curFace = ImgFaceArray.get(poseStyle);
    // mouthPath = mouthPathArray[10];
    break;
    
    default:
    /// mouthPath = mouthPathArray[0];
    curMouth = ImgMouthArray.get(0);
    curFace = ImgFaceArray.get(0);

    break;
  }
  // println("current mouth: " + mouthPath);

  /// curMouth = loadImage(mouthPath);
}


//////// add text string to tweet array and letters to char array ///////////////
void addText(String txt) {
  loadedTypewriter = false;
  try {
    
    textArray.set(0, "");
    spokenText = "";
    textArray.set(0, txt);
    spokenText = txt;

  } 
  catch(Exception e) {
    println("error adding text");
  }
  initTypewriter(textArray.get(0) + "**");
  CharTimer.start();
}

//// this rebuilds the character array for typing
void initTypewriter(String txt) {
  // stop the timer if it's already going
  loadedTypewriter = true;
  // reset the breakpoint
  hasBreak = false;
  breakPoint = 0;
  /// create a new meme name
  /// get the char array, empty it and put characters into it
  letCount = 0;
  spokenText = "";
  charArray = new ArrayList();
  try{
    
    char[] allChars = new char[txt.length()];
    for (int i = 0; i < txt.length(); i++) {
      allChars[i] = txt.charAt(i);
  
      charArray.add(str(txt.charAt(i)));
    }
  } catch (Exception e){
    println("exception parsing tweet: " + e);
  }
  
}


//////// add tweets to array //////////////

void addTweet(String tweet, String date, String user) {
  // text(tweet, 200,200);
  try {
    
    /// check current tweet array for tweet
    
    /// if it's not there, add it and send to twitter bot
    String nu = trim(user);
    /// maybe purge if we're over a certain limit?
    tweetArray.add(nu + " " + tweet + "********");
    nameArray.add("" + user);

  } 
  catch(Exception e) {
    println("error adding tweet");
  }
}

////////////////////////////////


////////////// INTERACTIVITY ///////////////////
void mouseClicked() {
  /// empty arrays
  redoSearch();
}
void redoSearch() {
  tweetArray = new ArrayList();
  nameArray = new ArrayList();
  if (javascript!=null) {
    javascript.reDoSearch();
  }
}


/********************************************************
 ///////// have to put external classes in same tab
 *********************************************************
 ********************************************************/

/////////////////////////////////////////////////////////
///////// TIMER CLASSES ///////////////////////////////////
///////////////////////////////////////////////////////////
class Timer {
  int clickTime = 0; // how often we send a tick
  boolean isTick = false;
  boolean isRunning = false;
  int curFrames;
  int totalTime; // How long Timer should last

  Timer(int tc) {
    clickTime = tc;
  }

  // Starting the timer
  void start() {
    isRunning = true;
  }

  // Starting the timer
  void stop() {
    isRunning = false;
  }
  boolean update() {
    // curFrames
    if (frameCount % clickTime == 0 && isRunning) {
      return true;
    } else {
      return false;
    }
  }
}

///// countdown timer
class CountDownTimer {

  int savedTime; // When Timer started
  int totalTime; // How long Timer should last

  CountDownTimer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }

  // Starting the timer
  void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
  }

  // Starting the timer
  void stop() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = totalTime = 0; //  millis();
  }

  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}


//////////////////////////////////////////////////
// Class for animating a sequence of GIFs
//////////////////////////////////////////////////
class Animation {
  PImage[] images;
  int imageCount;
  int frame;

  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = imagePrefix + nf(i, 4) + ".gif";
      images[i] = loadImage(filename);
    }
  }

  void display(float xpos, float ypos) {
    frame = (frame+1) % imageCount;
    image(images[frame], xpos, ypos);
  }

  int getWidth() {
    return images[0].width;
  }
}