//The MIT License (MIT) - See Licence.txt for details

//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies


int tvx, tvy;
int animx, animy;
int deck1x, deck1y;
int deck2x, deck2y;
int deck3x, deck3y;

boolean deck1Playing = false;
boolean deck2Playing = false;
boolean deck3Playing = false;
float rotateDeck1 = 0;
float rotateDeck2 = 0;
float rotateDeck3 = 0;
float currentFrame = 0;
int margin = width/40;
PImage [] images;
PImage [] recordPlayer;
PImage TV;
PImage reseticon;
Maxim maxim;
AudioPlayer player1;
AudioPlayer player2;
AudioPlayer player3;
float speedAdjust=1.0;
int volumeLevel=110;
float volume = 0.5;


void setup()
{
  size(768,1024);
  imageMode(CENTER);
  images = loadImages("Animation Data/movie", ".jpg", 178);
  recordPlayer = loadImages("black-record_", ".png", 36);
  TV = loadImage("TV.png");
  reseticon = loadImage("reset.jpg");
  maxim = new Maxim(this);
  player1 = maxim.loadFile("04.wav");
  player1.setLooping(true);
  player2 = maxim.loadFile("01.wav");
  player2.setLooping(true);
  player3 = maxim.loadFile("02.wav");
  player3.setLooping(true);
  background(10);
}

void draw()
{
  background(10); 
  imageMode(CENTER);
  strokeWeight(1);
  stroke(255);
  line(384, 512, 384, 1024);
  image(images[(int)currentFrame], width/2, images[0].height/2+margin, images[0].width, images[0].height);
  image(TV, width/2, TV.height/2+margin, TV.width, TV.height);
  image(reseticon, width/2+TV.width/2+margin+reseticon.width/4, reseticon.height/2+margin, reseticon.width/2, reseticon.height/2);
  rect(50, 10, 30, 210);
  stroke(0);
  line(50, volumeLevel, 80, volumeLevel);
  deck1x = (width/2)-recordPlayer[0].width-(margin*10);
  deck1y = TV.height+recordPlayer[0].height/2+margin;
  image(recordPlayer[(int) rotateDeck1], deck1x, deck1y, recordPlayer[0].width, recordPlayer[0].height);
  deck2x = (width/2);
  deck2y = TV.height+recordPlayer[0].height/2+margin;
  image(recordPlayer[(int) rotateDeck2], deck2x, deck2y, recordPlayer[0].width, recordPlayer[0].height);
  deck3x = (width/2)+recordPlayer[0].width+(margin*10);
  deck3y = TV.height+recordPlayer[0].height/2+margin;
  image(recordPlayer[(int) rotateDeck3], deck3x, deck3y, recordPlayer[0].width, recordPlayer[0].height);

  if (deck1Playing || deck2Playing || deck3Playing) {
    
    player1.speed(speedAdjust);
    player2.speed((player2.getLengthMs()/player1.getLengthMs())*speedAdjust);
    player3.speed((player3.getLengthMs()/player1.getLengthMs())*speedAdjust);
    currentFrame= currentFrame+1*speedAdjust;
  }

  if (currentFrame >= images.length) {

    currentFrame = 0;
  }

  if (deck1Playing) {

    rotateDeck1 += 1*speedAdjust;

    if (rotateDeck1 >= recordPlayer.length) {

      rotateDeck1 = 0;
    }
  }

  if (deck2Playing) {

    rotateDeck2 += 1*speedAdjust;

    if (rotateDeck2 >= recordPlayer.length) {

      rotateDeck2 = 0;
    }
  }
  
  if (deck3Playing) {
  
    rotateDeck3 += 1*speedAdjust;
    
    if (rotateDeck3 >= recordPlayer.length) {
      
      rotateDeck3 = 0;
    }
  }
}


void mouseClicked()
{

  //if (mouseX > (width/2)-recordPlayer[0].width-(margin*10) && mouseX < recordPlayer[0].width+((width/2)-recordPlayer[0].width-(margin*10)) && mouseY>TV.height+margin && mouseY <TV.height+margin + recordPlayer[0].height) {
  if(dist(mouseX, mouseY, deck1x, deck1y) < recordPlayer[0].width/2){
    
    deck1Playing = !deck1Playing;
  }

  if (deck1Playing) {
    player1.play();
  } 
  else {

    player1.stop();
  }

  if(dist(mouseX, mouseY, deck2x, deck2y) < recordPlayer[0].width/2){
  
    deck2Playing = !deck2Playing;
  }

  if (deck2Playing) {
    player2.play();
  } 
  else {

    player2.stop();
  }
  
  if(dist(mouseX, mouseY, deck3x, deck3y) < recordPlayer[0].width/2){
    
    deck3Playing = !deck3Playing;
  }
  
  if (deck3Playing) {
    player3.play();
  }
  else {
    
    player3.stop();
  }

  if (mouseX>width/2+TV.width/2+margin && mouseX<width/2+TV.width/2+margin+reseticon.width/2 && mouseY>reseticon.height/4+margin && mouseY<reseticon.height/2+margin+reseticon.height/4) {
    
    player1.cue(0);
    player2.cue(0);
    player3.cue(0);
    if (deck1Playing) {
      player1.play();
    }
    if (deck2Playing) {
      player2.play();
    }
    if (deck3Playing) {
      player3.play();
    }
  }
  
  if (mouseX>50 && mouseX<80 && mouseY>10 && mouseY<210){
    volumeLevel=mouseY;
    volume=map(volumeLevel, 10, 210, 0, 1);
    player1.volume(volume);
    player2.volume(volume);
    player3.volume(volume);
  }
      
}

void mouseDragged() {
   
 if (mouseY>height/2) {
  
   speedAdjust=map(mouseX,0,width,0,2);
   
 } 
}
