//The MIT License (MIT) - See Licence.txt for details

//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies


Maxim maxim;
AudioPlayer sample1;
AudioPlayer sample2; 
AudioPlayer sample3; 
AudioPlayer sample4;
AudioPlayer main;
AudioPlayer beats;
AudioPlayer claps;
AudioPlayer drums;
WavetableSynth synth1;
WavetableSynth synth2;

Button reset1;
Button reset2;
Button pause1;
Button pause2;
Button beat;
Button clap;
Button drum;

boolean[] track1;
boolean[] track2;
boolean[] track3;
boolean[] track4;

int[] notes = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
int[] notes2 = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

int transpose = 0;
int transpose2 = 24;
float fc, res, attack, release, filterAttack;
float fc2, res2, attack2, release2, filterAttack2;
float threshold;
float spd;

int playhead;

int numBeats;
int currentBeat;
int buttonWidth;
int buttonHeight;
int count1;
int count2;

PImage backgroundImage; 
PImage flash;
PImage on;
PImage off;
boolean flashcheck;
boolean beatcheck;
boolean clapcheck;
boolean volumecheck;
Slider dt, dg, a, r, f, q, fa, o, v, dt2, dg2, a2, r2, f2, q2, fa2, o2, v2;
MultiSlider seq, seq2;

void setup() {
  size(1024, 768);
  numBeats = 16;
  currentBeat = 0;
  buttonWidth = width/numBeats;
  buttonHeight = height/12;
  
  reset1 = new Button("Reset", 350, 40, 50, 50);
  reset2 = new Button("Reset", 860, 40, 50, 50);
  pause1 = new Button("Pause", 350, 100, 50, 50);
  pause2 = new Button("Pause", 860, 100, 50, 50);
  beat =  new Button("Beat=off", 460, 170, 50, 50);
  clap = new Button("Clap=off", 460, 110, 50, 50);
  drum = new Button("Drum effect", 460, 50, 50, 50);

  maxim = new Maxim(this);
  sample1 = maxim.loadFile("bd1.wav");
  sample1.volume(1);
  sample1.setLooping(false);
  sample2 = maxim.loadFile("sn1.wav");
  sample2.setLooping(false);
  sample2.volume(2);
  sample3 = maxim.loadFile("hh1.wav");
  sample3.volume(1);
  sample3.setLooping(false);
  sample4 = maxim.loadFile("sn2.wav");
  sample4.setLooping(false);

  synth1 = maxim.createWavetableSynth(514);
  synth1.setAnalysing(true);
  synth1.play();
  synth1.volume(0.5);
  synth2 = maxim.createWavetableSynth(514);
  synth2.setAnalysing(true);
  synth2.play();
  synth2.volume(0.5);
  main = maxim.loadFile("beat.wav");
  main.setAnalysing(true);
  main.volume(1.0);
  main.setLooping(true);
  main.play();
  beats = maxim.loadFile("bd2.wav");
  beats.volume(1);
  beats.setLooping(false);
  claps = maxim.loadFile("clap.wav");
  claps.volume(1.5);
  claps.setLooping(false);
  drums = maxim.loadFile("final drum effect.wav");
  drums.volume(1.5);
  drums.setLooping(false);

  // set up the sequences
  track1 = new boolean[numBeats];
  track2 = new boolean[numBeats];
  track3 = new boolean[numBeats];
  track4 = new boolean[numBeats];
  backgroundImage = loadImage("brushedm.jpg");
  on=loadImage("volume_on.png");
  off=loadImage("volume_off.png");
  flashcheck=false;
  beatcheck=false;
  clapcheck=false;
  volumecheck=true;
  flash = loadImage("flash.jpg");
  frameRate(60);
  spd=1;
  count1=-1;
  count2=-1;
//1, 1, 1, 20, 20, 20, 20, 0, 0.5
  dt = new Slider("delay time", 1, 0, 100, 110, 10, 200, 20, HORIZONTAL);
  dg = new Slider("delay amnt", 1, 0, 100, 110, 30, 200, 20, HORIZONTAL);
  a = new Slider("attack", 1, 0, 100, 110, 50, 200, 20, HORIZONTAL);
  r = new Slider("release", 20, 0, 100, 110, 70, 200, 20, HORIZONTAL);
  f = new Slider("filter", 20, 0, 100, 110, 90, 200, 20, HORIZONTAL);
  q = new Slider("res", 20, 0, 100, 110, 110, 200, 20, HORIZONTAL);
  fa = new Slider("filterAmp", 20, 0, 100, 110, 130, 200, 20, HORIZONTAL);
  o = new Slider("transpose", 0, 1, 80, 110, 150, 200, 20, HORIZONTAL);
  v = new Slider("volume", 0.5, 0, 1, 110, 170, 200, 20, HORIZONTAL);
  // name,s min, max, pos.x, pos.y, width, height
  seq = new MultiSlider(notes.length, 0, 256, 0, 300, width/18/2, 150, UPWARDS);
  // name, value, min, max, pos.x, pos.y, width, height

  dt2 = new Slider("delay time", 1, 0, 100, 620, 10, 200, 20, HORIZONTAL);
  dg2 = new Slider("delay amnt", 1, 0, 100, 620, 30, 200, 20, HORIZONTAL);
  a2 = new Slider("attack", 1, 0, 100, 620, 50, 200, 20, HORIZONTAL);
  r2 = new Slider("release", 20, 0, 100, 620, 70, 200, 20, HORIZONTAL);
  f2 = new Slider("filter", 20, 0, 100, 620, 90, 200, 20, HORIZONTAL);
  q2 = new Slider("res", 20, 0, 100, 620, 110, 200, 20, HORIZONTAL);
  fa2 = new Slider("filterAmp", 20, 0, 100, 620, 130, 200, 20, HORIZONTAL);  
  o2 = new Slider("transpose", 0, 1, 80, 620, 150, 200, 20, HORIZONTAL);
  v2 = new Slider("volume", 0.5, 0, 1, 620, 170, 200, 20, HORIZONTAL);
  // name,s min, max, pos.x, pos.y, width, height
  seq2 = new MultiSlider(notes2.length, 0, 256, width/2, 300, width/18/2, 150, UPWARDS);
}

void draw() {
  image(backgroundImage, 0, 0);
  //int sum = 0;
  //for (int i = 0; i<notes.length; i++)
  //  sum += notes[i];
  //for (int i = 0; i<notes2.length; i++)
  //  sum += notes2[i];
  //threshold = (float) (sum) / (notes.length * 2);
  //threshold = threshold/1000;
  //threshold += 0.3;
  //println("Threshold is " + threshold);
  //if (pause1.getName()=="Play" && pause2.getName()=="Pause")
  //{
  //  threshold = 0.29;
  //}
  //else if (pause1.getName()=="Pause" && pause2.getName()=="Play")
  //{
  //  threshold = 0.275;
  //}
  //else{
  //  threshold = 0.298;}
  //println("Threshold is " + threshold);
  //float power = (synth1.getAveragePower() + synth2.getAveragePower())/2;
  if (spd>=1)
    {threshold = 0.32;}
  else
  {
    threshold = map(spd, 0, 1, 0.27, 0.32);
  }
  float power = main.getAveragePower();
  flashcheck = power>=threshold;
  println("Power is " + power);
  
  if (flashcheck)
  {
    image(flash, 400, 400);
  }
  //background(0);

  stroke(255);
  line(width/2 - 50, 255, width/2 - 50, 295);
  for (int i = 0; i < 5; i++)
    line(0, 500+(i*height/12), width, 500+(i*height/12));
  for (int i = 0; i < numBeats + 1; i++)
    line(i*width/numBeats, 500, i*width/numBeats, 500+(4*height/12));


  // draw a moving square showing where the sequence is 
  fill(0, 0, 200, 120);
  rect(currentBeat*buttonWidth, 500, buttonWidth, height);
  
  if (volumecheck)
  {
    image(on, width-50, 5);
  }
  else
  {
    image(off, width-50, 5);
  }

  for (int i = 0; i < numBeats; i++)
  {
    noStroke();
    fill(200, 0, 0);

    if (track1[i])
      rect(i*buttonWidth, 500+(0*buttonHeight), buttonWidth, buttonHeight);
    if (track2[i])
      rect(i*buttonWidth, 500+(1*buttonHeight), buttonWidth, buttonHeight);
    if (track3[i])
      rect(i*buttonWidth, 500+(2*buttonHeight), buttonWidth, buttonHeight);
    if (track4[i])
      rect(i*buttonWidth, 500+(3*buttonHeight), buttonWidth, buttonHeight);
  }

  playhead ++;
  //if (frameCount%4==0) {// 4 frames have passed check if we need to play a beat
  if (playhead % 4 == 0) {
    if (track1[currentBeat]) // track1 wants to play on this beat
    {
      sample1.cue(0);
      sample1.play();
    }
    if (track2[currentBeat]) {
      sample2.cue(0);
      sample2.play();
    }
    if (track3[currentBeat]) {
      sample3.cue(0);  
      sample3.play();
    }
    if (track4[currentBeat]) {
      sample4.cue(0);
      sample4.play();
    }

    // now the synths
    //synth1.ramp(0.5, attack);
    synth1.setFrequency(mtof[notes[playhead/4%16]+30]);
    //waveform.filterRamp((fc/100)*(filterAttack*0.2), attack+release); 

    //synth2.ramp(0.5, attack2);
    synth2.setFrequency(mtof[notes2[playhead/4%16]+30]);
    //waveform2.filterRamp((fc2/100)*(filterAttack2*0.2), attack2+release2);


    // move to the next beat ready for next time
    currentBeat++;
    if (currentBeat >= numBeats)
      currentBeat = 0;
    }
  count1 += 1;
  if (count1%30==0)
  {
  
    if (beatcheck)
    {
      beats.play();
    }
    else
    {
      beats.stop();
      beats.cue(0);
    }
  }
  count2+=1;
  if (count2%30==0)
  {
    
    if (clapcheck)
    {
      claps.play();
    }
    else
    {
      claps.stop();
      claps.cue(0);
    }
  }

  if (mousePressed) {
    dt.mouseDragged();
    dg.mouseDragged();
    a.mouseDragged();
    r.mouseDragged();
    f.mouseDragged();
    q.mouseDragged();
    fa.mouseDragged();
    o.mouseDragged();
    seq.mouseDragged();
    v.mouseDragged();

    dt2.mouseDragged();
    dg2.mouseDragged();
    a2.mouseDragged();
    r2.mouseDragged();
    f2.mouseDragged();
    q2.mouseDragged();
    fa2.mouseDragged();
    o2.mouseDragged();
    seq2.mouseDragged();
    v2.mouseDragged();
  }

  // process gui events

  if (f.get() != 0) {
    fc=f.get()*100;
    synth1.setFilter(fc, res);
  }
  if (dt.get() != 0) {
    synth1.setDelayTime((float) dt.get()/50);
  }
  if (dg.get() != 0) {
    //waveform.setDelayAmount((int)dg.get()/100);
  }
  if (q.get() != 0) {
    res=q.get() / 50;
    synth1.setFilter(fc, res);
  }
  if (a.get() != 0) {
    attack=a.get()*10;
  }
  if (r.get() != 0) {
    release=r.get()*10;
  }
  if (fa.get() != 0) {
    filterAttack=fa.get()*10;
  }
  if (o.get() != 0) {
    transpose=(int) Math.floor(o.get());
  }
  if (v.get() != 0) {
    synth1.volume(v.get());
  }

  // synth 2:
  if (f2.get()!= 0) {
    fc2=f2.get()*100;
    synth2.setFilter(fc2, res2);
  }
  if (dt2.get() != 0) {
    synth2.setDelayTime((float) dt2.get()/50);
  }

  if (dg2.get() != 0) {
    //synth2.setDelayAmount((int)dg2.get()/100);
  }

  if (q2.get() != 0) {
    res2=q2.get() / 50;
    synth2.setFilter(fc2, res2);
  }

  if (a2.get() != 0) {
    attack2=a2.get()*10;
  }

  if (r2.get() != 0) {
    release2=r2.get()*10;
  }

  if (fa2.get() != 0) {
    filterAttack2=fa2.get()*10;
  }

  if (o2.get() != 0) {
    transpose2=(int) Math.floor(o2.get());
  }
  if (v2.get() != 0) {
    synth1.volume(v2.get());
  }

  // draw gui widgets
  //reset1.setImage(icon);
  //reset2.setImage(icon);
  reset1.display();
  reset2.display();
  pause1.display();
  pause2.display();
  beat.display();
  clap.display();
  drum.display();

  dt.display();
  dg.display();
  a.display();
  r.display();
  f.display();
  q.display();
  fa.display(); 
  o.display();
  seq.display();
  v.display();


  dt2.display();
  dg2.display();
  a2.display();
  r2.display();
  f2.display();
  q2.display();
  fa2.display();
  o2.display();
  seq2.display();
  v2.display();
}

void mousePressed() {

  dt.mousePressed();
  dg.mousePressed();
  a.mousePressed();
  r.mousePressed();
  f.mousePressed();
  q.mousePressed();
  o.mousePressed();
  fa.mousePressed();
  seq.mousePressed();
  v.mousePressed();

  dt2.mousePressed();
  dg2.mousePressed();
  a2.mousePressed();
  r2.mousePressed();
  f2.mousePressed();
  q2.mousePressed();
  fa2.mousePressed();
  o2.mousePressed();
  seq2.mousePressed();
  v2.mousePressed();
  
  reset1.mousePressed();
  reset2.mousePressed();
  pause1.mousePressed();
  pause2.mousePressed();
  beat.mousePressed();
  clap.mousePressed();
  drum.mousePressed();

  int index = (int) Math.floor(mouseX*numBeats/width);   
  int track = (int) Math.floor((mouseY-500)*(12/(float)height));


  if (track == 0)
    track1[index] = !track1[index];
  if (track == 1)
    track2[index] = !track2[index];
  if (track == 2)
    track3[index] = !track3[index];
  if (track == 3)
    track4[index] = !track4[index];
}

void mouseReleased()
{
  for (int i=0;i<notes.length;i++) {

    notes[i]=(int) (Math.floor((seq.get(i)/256)*12+transpose)); 
    notes2[i]=(int) (Math.floor((seq2.get(i)/256)*12+transpose2));
  }
 //1, 1, 1, 20, 20, 20, 20, 0, 0.5 
  if (reset1.mouseReleased())
  {
    dt.set(1);
    dg.set(1);
    a.set(1);
    r.set(20);
    f.set(20);
    q.set(20);
    fa.set(20);
    o.set(0);
    v.set(0.5);
  }
  
  if (reset2.mouseReleased())
  {
    dt2.set(1);
    dg2.set(1);
    a2.set(1);
    r2.set(20);
    f2.set(20);
    q2.set(20);
    fa2.set(20);
    o2.set(0);
    v2.set(0.5);
  }
  
  if (pause1.mouseReleased())
  {
    if (pause1.getName()=="Pause")
    {
      synth1.stop();
      pause1.setName("Play");
    }
    else
    {
      synth1.play();
      pause1.setName("Pause");
    }
  }
  
  if (pause2.mouseReleased())
  {
    if (pause2.getName()=="Pause")
    {
      synth2.stop();
      pause2.setName("Play");
    }
    else
    {
      synth2.play();
      pause2.setName("Pause");
    }
  }
  
  if (beat.mouseReleased())
  {
    beatcheck=!beatcheck;
    if (beatcheck)
    {
      beat.setName("Beat=on");
      count1=-1;
    }
    else
    {
      beat.setName("Beat=off");
    }
  }
  
  if (clap.mouseReleased())
  {
    clapcheck=!clapcheck;
    if (clapcheck)
    {
      clap.setName("Clap=on");
      count2=-1;
    }
    else
    {
      clap.setName("Clap=off");
    }
  }
  
  if (drum.mouseReleased())
  {
    drums.cue(0);
    drums.play();
  }
  //width-50, 5, 32, 32
  if (mouseX>=width-50 && mouseX<=width-12 && mouseY>=5 && mouseY<=37)
  {
    if (volumecheck)
    {
      volumecheck=false;
      main.stop();
    }
    else
    {
      volumecheck=true;
      main.cue(0);
      main.play();
    }
  }
}

void mouseDragged()
{
  if (mouseY>=255 && mouseY<=295)
  {
    spd = map(mouseX, 0, width, 0, 2);
    main.speed(spd);
  }
}
