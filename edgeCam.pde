import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
/**
 * Getting Started with Capture.
 * 
 * Reading and displaying an image from an attached Capture device. 
 */

import processing.video.*;

Capture cam;

int thresh;
boolean pencil;
boolean edge;
int timeTaken;
int picCount;
PImage currentPic;
boolean picTaken;
color filter;
boolean coloredEdges;

Minim minim;
AudioPlayer shutter;

void setup() {
  size(1200, 700);
  thresh = 25;
  edge = false;
  pencil = false;
  filter = color(255);
  coloredEdges = false;

  String[] cameras = Capture.list();
  
  minim = new Minim(this); 


  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, width, height);
  } if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[0]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);
    
    // Start capturing the images from the camera
    cam.start();
  }
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  if (picTaken) {
    if (millis() - timeTaken > 1000) {
      picTaken = false;
    }
    tint(255);
    //image(currentPic,0,0);
    image (cam, 0,0);
  }
  if (!picTaken) {
    if (!edge) {
    tint(filter);
    }
    image(cam, 0, 0);
    if (edge) { 
      color[] temp = new color[width*height];
     
      loadPixels();
      for (int x = 1; x<width-1; x++) {
        for (int y = 1; y <height-1; y++) {
          color here = pixels[y*width+x];
          color left = pixels[y*width+(x-1)];
          color right = pixels[y*width+(x+1)];
          color above = pixels[(y-1)*width+x];
          color below = pixels[(y+1)*width+x];
          int newR = int(sqrt(sq(red(left)-red(right)) + sq(red(above)-red(below))));
          int newG = int(sqrt(sq(green(left)-green(right)) + sq(green(above)-green(below))));
          int newB = int(sqrt(sq(blue(left)-blue(right)) + sq(blue(above)-blue(below))));
          int newC = (newR + newG + newB) / 3;
          color finalC;
          if(!pencil) {
            if (newC >= thresh) {
              if (coloredEdges) {
                finalC = here;
              } else {
                finalC = color(255);
              }
            } else {
              finalC = filter;
            }
          } else {
            if (newC < thresh) {
              if (coloredEdges) {
                finalC = here;
              } else {
                finalC = color(255);
              }
            } else {
              finalC = filter;
            }
          }
          temp[y*width+x] = finalC;
        }
      }
      for (int i = 0;i<temp.length;i++) {
        pixels[i] = temp[i];
      }
      updatePixels();
    }
  }
  // The following does the same as the above image() line, but 
  // is faster when just drawing the image without any additional 
  // resizing, transformations, or tint.
  //set(0, 0, cam);
}

void takePicture() {
  timeTaken = millis();
  picCount++;
  shutter = minim.loadFile("A.mp3");
  shutter.play();
  saveFrame(month()+"-"+day()+"-"+hour()+minute()+"-"+picCount+".jpg");
  //currentPic = loadImage(month()+"-"+day()+"-"+hour()+minute()+"-"+picCount+".jpg");
  picTaken = true;
}

void changeFilter() {
  if (filter == color(255) || filter == color(0)) {
    filter = color(200,158,62);//brown
  } else if (filter == color(200,158,62)) {
    filter = color(0,153,204);//blue
  } else if (filter == color(0,153,204)) {
    filter = color(215,34,71);//red
  } else if (filter == color(215,34,71)) {
    filter = color(106,180,110);//green
  } else if (filter == color(106,180,110)) {
    if (edge) {
      filter = color(0);
    } else {
      filter = color(255);//none
    }
  }
}

void keyPressed() {
  if (keyCode == 45) { //minus
    thresh+=3;
  } else if (keyCode == 61) { //plus
    thresh-=3;
  } else if(keyCode == 80) {
    if (edge) {
      pencil = !pencil;
    }
  } else if (keyCode == 69) {
    edge = !edge;
    if (edge) {
    filter = color(0);
    } else {
      filter = color(255);
    }
  } else if (keyCode == 32) {
    takePicture();
  } else if (keyCode == 70 && !coloredEdges) {
    changeFilter();
  } else if (keyCode == 67 && edge) {
    coloredEdges = !coloredEdges;
    filter = color(0);
  }
  println(keyCode);
}