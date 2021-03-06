//The MIT License (MIT) - See Licence.txt for details

//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies


import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;

// audio stuff

Maxim maxim;
//AudioPlayer droidSound, wallSound;
AudioPlayer[] crateSounds;
AudioPlayer background;


Physics physics; // The physics handler: we'll see more of this later
// rigid bodies for the droid and two crates
Body droid;
Body [] crates;
// the start point of the catapult 
Vec2 startPoint;
// a handler that will detect collisions
CollisionDetector detector; 

int crateSize = 80;
int ballSize = 60;

PImage crateImage, ballImage, tip, replay;
PImage on, off;
PImage life, mushroom;

int score = 0;
float highscore = 0;
int tries = 0;
int no_of_lives = 3;
int previous_try;

float totalimpulse = 0;

boolean dragging = false;
boolean music = true;
boolean lives = false;
boolean check1, check2;

void setup() {
  size(1024,768);
  frameRate(60);


  tip = loadImage("interesting.gif");
  crateImage = loadImage("crate.jpeg");
  ballImage = loadImage("tux_droid.png");
  replay = loadImage("replay.png");
  on = loadImage("volume_on.png");
  off = loadImage("volume_off.png");
  life = loadImage("life.png");
  mushroom = loadImage("mushroom.png");
  imageMode(CENTER);

  //initScene();

  /**
   * Set up a physics world. This takes the following parameters:
   * 
   * parent The PApplet this physics world should use
   * gravX The x component of gravity, in meters/sec^2
   * gravY The y component of gravity, in meters/sec^2
   * screenAABBWidth The world's width, in pixels - should be significantly larger than the area you intend to use
   * screenAABBHeight The world's height, in pixels - should be significantly larger than the area you intend to use
   * borderBoxWidth The containing box's width - should be smaller than the world width, so that no object can escape
   * borderBoxHeight The containing box's height - should be smaller than the world height, so that no object can escape
   * pixelsPerMeter Pixels per physical meter
   */
  physics = new Physics(this, width, height, 0, -10, width*2, height*2, width, height, 100);
  // this overrides the debug render of the physics engine
  // with the method myCustomRenderer
  // comment out to use the debug renderer 
  // (currently broken in JS)
  physics.setCustomRenderingMethod(this, "myCustomRenderer");
  physics.setDensity(10.0);

  // set up the objects
  // Rect parameters are the top left 
  // and bottom right corners
  crates = new Body[7];
  crates[0] = physics.createRect(600, height-crateSize, 600+crateSize, height);
  crates[1] = physics.createRect(600, height-2*crateSize, 600+crateSize, height-crateSize);
  crates[2] = physics.createRect(600, height-3*crateSize, 600+crateSize, height-2*crateSize);
  crates[3] = physics.createRect(600+1.5*crateSize, height-crateSize, 600+2.5*crateSize, height);
  crates[4] = physics.createRect(600+1.5*crateSize, height-2*crateSize, 600+2.5*crateSize, height-crateSize);
  crates[5] = physics.createRect(600+1.5*crateSize, height-3*crateSize, 600+2.5*crateSize, height-2*crateSize);
  crates[6] = physics.createRect(600+0.75*crateSize, height-4*crateSize, 600+1.75*crateSize, height-3*crateSize);

  startPoint = new Vec2(200, height-150);
  // this converst from processing screen 
  // coordinates to the coordinates used in the
  // physics engine (10 pixels to a meter by default)
  startPoint = physics.screenToWorld(startPoint);

  // circle parameters are center x,y and radius
  droid = physics.createCircle(width/2, -100, ballSize/2);

  // sets up the collision callbacks
  detector = new CollisionDetector (physics, this);

  maxim = new Maxim(this);
  //droidSound = maxim.loadFile("droid.wav");
  //wallSound = maxim.loadFile("wall.wav");
  background = maxim.loadFile("background.wav");

  //droidSound.setLooping(false);
  //droidSound.volume(1.0);
  //wallSound.setLooping(false);
  //wallSound.volume(1.0);
  background.setLooping(true);
  background.volume(0.7);
  background.play();
  // now an array of crate sounds
  crateSounds = new AudioPlayer[crates.length];
  for (int i=0;i<crateSounds.length;i++){
    crateSounds[i] = maxim.loadFile("crate2.wav");
    crateSounds[i].setLooping(false);
    crateSounds[i].volume(1);
  }
  tries=0;
  no_of_lives=3;
}

void draw() {
  image(tip, width/2, height/2, width, height);
  image(replay, 870, 30, 30, 30);
  
  if (music)
  {
    image(on, 835, 30, 30, 30);
  }
  else
  {
    image(off, 835, 30, 30, 30);
  }
  
  //image(life1, 800, 30, 30, 30);
  if (lives)
  {
    image(life, 800, 30, 30, 30);
    if (no_of_lives==1)
    {
      image(life, 200, 30, 30, 30);
    }
    if (no_of_lives==2)
    {
      image(life, 235, 30, 30, 30);
      image(life, 200, 30, 30, 30);
    }
    if (no_of_lives==3)
    {
      image(life, 235, 30, 30, 30);
      image(life, 270, 30, 30, 30);
      image(life, 200, 30, 30, 30);
    }
  }
  else
  {
    image(mushroom, 800, 30, 30, 30);
    if (tries==0)
    {
      image(mushroom, 200, 30, 30, 30);
      image(mushroom, 235, 30, 30, 30);
      image(mushroom, 270, 30, 30, 30);
    }
    if (tries==1)
    {
      image(mushroom, 200, 30, 30, 30);
      image(mushroom, 235, 30, 30, 30);
    }
    if (tries==2)
    {
      image(mushroom, 200, 30, 30, 30);
    }
  }
  
  if (score>5 && score<20)
  {
    float spd;
    spd = map(score, 5, 20, 1, 2);
    background.speed(spd);
  }

  // we can call the renderer here if we want 
  // to run both our renderer and the debug renderer
  //myCustomRenderer(physics.getWorld());

  fill(255, 0, 0);
  text("Score: " + score*totalimpulse, 20, 20);
  text("High Score: " + highscore, 900, 20);
  //text("Impulse Level: " + totalimpulse, 400, 20);
  if (lives)
  {
    if (no_of_lives==0)
    {
      text("Game Over", 100, 100);
    }
  }
  else
  {
    if (tries==3)
    {
      text("Game Over", 100, 100);
    }
  }
}

void mousePressed()
{
  if (mouseX>855 && mouseX<885 && mouseY>15 && mouseY<45)
  {
    tries=0;
    score=0;
    totalimpulse=0;
    background.stop();
    setup();
  }
  if (mouseX>820 && mouseX<850 && mouseY>15 && mouseY<45)
  {
    music = !music;
    if (music)
    {
      background.play();
    }
    else
    {
      background.stop();
    }
  }
  if (mouseX>785 && mouseX<815 && mouseY>15 && mouseY<45)
  {
    if (tries==3 && lives==false)
    {
      lives=true;
      no_of_lives=3;
      tries=0;
      highscore=0;
      score=0;
      background.speed(1);
      background.stop();
      setup();
    }
    else if (no_of_lives==0 && lives)
    {
      lives=false;
      tries=0;
      no_of_lives=3;
      highscore=0;
      score=0;
      background.speed(1);
      background.stop();
      setup();
    }
  }
}

//start point (200, 618)
void mouseDragged()
{
  // tie the droid to the mouse while we are dragging
  if (mouseX>855 && mouseX<885 && mouseY>15 && mouseY<45 || mouseX>820 && mouseX<850 && mouseY>15 && mouseY<45 || mouseX>785 && mouseX<815 && mouseY>15 && mouseY<45)
  {}
  else
  {
    if (lives)
    {
      if (no_of_lives>0 && mouseX>100 && mouseX<300 && mouseY>518 && mouseY<718)
      {
        dragging = true;
        droid.setPosition(physics.screenToWorld(new Vec2(mouseX, mouseY)));
      }
    }
    else
    {
      if (tries<3 && mouseX>100 && mouseX<300 && mouseY>518 && mouseY<718)
      {
        dragging = true;
        droid.setPosition(physics.screenToWorld(new Vec2(mouseX, mouseY)));
      }
    }
  }
}

// when we release the mouse, apply an impulse based 
// on the distance from the droid to the catapult
void mouseReleased()
{
  if (mouseX>855 && mouseX<885 && mouseY>15 && mouseY<45 || mouseX>820 && mouseX<850 && mouseY>15 && mouseY<45 || mouseX>785 && mouseX<815 && mouseY>15 && mouseY<45)
  {}
  else
  {
    if (lives==false)
    {
      if (tries<3)
      {
        dragging = false;
        Vec2 impulse = new Vec2();
        impulse.set(startPoint);
        impulse = impulse.sub(droid.getWorldCenter());
        impulse = impulse.mul(50);
        droid.applyImpulse(impulse, droid.getWorldCenter());
        tries += 1;
        check1=false;
        check2=false;
      } 
    }
    else
    {
      if (no_of_lives>0)
      {
        dragging = false;
        Vec2 impulse = new Vec2();
        impulse.set(startPoint);
        impulse = impulse.sub(droid.getWorldCenter());
        impulse = impulse.mul(50);
        droid.applyImpulse(impulse, droid.getWorldCenter());
        check1=false;
        check2=false;
      }
    }
  }
}

// this function renders the physics scene.
// this can either be called automatically from the physics
// engine if we enable it as a custom renderer or 
// we can call it from draw
void myCustomRenderer(World world) {
  stroke(0);
  Vec2 screenStartPoint = physics.worldToScreen(startPoint);
  strokeWeight(8);
  line(screenStartPoint.x, screenStartPoint.y, screenStartPoint.x, height);

  // get the droids position and rotation from
  // the physics engine and then apply a translate 
  // and rotate to the image using those values
  // (then do the same for the crates)
  Vec2 screenDroidPos = physics.worldToScreen(droid.getWorldCenter());
  float droidAngle = physics.getAngle(droid);
  pushMatrix();
  translate(screenDroidPos.x, screenDroidPos.y);
  rotate(-radians(droidAngle));
  image(ballImage, 0, 0, ballSize, ballSize);
  popMatrix();


  for (int i = 0; i < crates.length; i++)
  {
    Vec2 worldCenter = crates[i].getWorldCenter();
    Vec2 cratePos = physics.worldToScreen(worldCenter);
    float crateAngle = physics.getAngle(crates[i]);
    pushMatrix();
    translate(cratePos.x, cratePos.y);
    rotate(-crateAngle);
    image(crateImage, 0, 0, crateSize, crateSize);
    popMatrix();
  }

  if (dragging)
  {
    strokeWeight(2);
    line(screenDroidPos.x, screenDroidPos.y, screenStartPoint.x, screenStartPoint.y);
  }
}

// This method gets called automatically when 
// there is a collision
void collision(Body b1, Body b2, float impulse)
{
  if ((b1 == droid && b2.getMass() > 0)
    || (b2 == droid && b1.getMass() > 0))
  {
    if (impulse > 1.0)
    {
      score += 1;
      totalimpulse += impulse;
      if (highscore<score*totalimpulse)
      {
        highscore=score*totalimpulse;
      }
    }
  }

  // test for droid
  if (b1.getMass() == 0 || b2.getMass() == 0) {// b1 or b2 are walls
    // wall sound
    //println("wall speed "+(impulse/100));
    //wallSound.cue(0);
    //wallSound.speed(impulse / 100);// 
    //wallSound.play();
    if (!check1)
    {
      if (no_of_lives>0)
      {
        no_of_lives -= 1;
      }
    }
  }
  if (b1 == droid || b2 == droid) { // b1 or b2 are the droid
    // droid sound
    //println("droid "+(impulse/10));
    //droidSound.cue(0);
    //droidSound.speed(impulse / 10);
    //droidSound.play();
    check1=true;
  }
   for (int i=0;i<crates.length;i++){
     if (b1 == crates[i] || b2 == crates[i]){// its a crate
         crateSounds[i].cue(0);
         crateSounds[i].speed(0.5 + (impulse / 10000));// 10000 as the crates move slower??
         crateSounds[i].play();
     }
   }
  //
}
