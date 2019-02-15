// CMSC317 assignment 2
// different binary thresholding functions
//
// (1) complete the two missing functions: 
//      - calcmean 
//      - calcotsu 
//
// (2) For the report (PDF):
//      - show results (binary images) for the different thresholds
//      - find an image where otsu fails; reflect on why it failed? 
//      - describe another way to pick the threshold 
//
// submit your sketch as a .zip file with the PDF and images included
//
// Keith O'Hara <kohara@bard.edu>
// Feb 2019

/**
 * Alex Hamme <ah2166@bard.edu>
 * Feb 13, 2019
 * CMSC 317
 * Histograms & Otsu Image Segmentation
 * No collaboration
 */

import processing.video.*;
import java.util.Arrays;

//Capture cam;
PImage cam;

int hist[];
float thresh = 128;

void setup() {
  size(1280, 960);   // 640 x 480
  
  // for the webcam
  //cam = new Capture(this, width/2, height/2);
  //cam.start();
  
  // to load image from file
  cam = loadImage("data/manuscript.jpg");
  //cam = loadImage("data/break_otsu.jpg");

  cam.filter(GRAY);  // to convert image to gray scale
  cam.resize(width/2, height/2);
  
  hist = new int[256];
}

void mousePressed() {
  println("thresh = " + thresh);
}

void drawhist(int [] h) {
  int sum = 0;
  noStroke();    
  for (int i = 0; i < h.length; i++) {
    //draw pdf
    fill(i);
    rect(i, height/2, 1, h[i]/10);

    //draw cdf
    sum += h[i];
    rect(width/2+i, height/2, 1, sum/300);
  }
}

void calchist(PImage img, int []h) {
  img.loadPixels();
  //clear the histogram
  for (int i = 0; i < h.length; i++) {
    h[i] = 0;
  }
  for (int i = 0; i < img.pixels.length; i++) {
    // to gamma correct or not?
    int value = (img.pixels[i] & 0xFF00) >> 8;
    h[value]++;
  }
}

// given a histogram, find the mean
int calcmean(int[] h) {
  int pixelSum = 0;
  int numbPixels = 0;
  for (int i=0; i < h.length; i++) {
    numbPixels += h[i];
    pixelSum += (h[i] * i);
  }
  return (int) Math.round(pixelSum / (double) numbPixels);
}

int calcPixelValSum(int[] h) {
  int pixelSum = 0;
  for (int i=0; i < h.length; i++) {
    pixelSum += (h[i] * i);
  }
  return pixelSum;
}

// given a histogram, find the otsu threshold with Between Class Variance
// Note: this runs in O(256) constant time, without any extra loops
int calcotsu(int[] h) {
    
  // N, total number of pixels. It's a double so I don't have to cast it to double later for division
  double numb_pixels = Arrays.stream(h).sum();  // add up all frequencies to get total numb pixels
  
  /* use cumulative sum and mean variables to avoid having to add up frequency values in h repeatedly */
  
  double cum_count_b = 0;                         // cumulative sum of pixel count, background
  double cum_count_f = (int) numb_pixels;         // same, but foreground. starts at full pixel count
  
  int cum_px_sum_b = 0;                           // cum sum of pixel values (h[i] * i), background
  int cum_px_sum_f = calcPixelValSum(h);          // same, but foreground (starts at the full sum)
  
  double weight_b, weight_f; 
  double mean_b, mean_f;
  
  // Between Class Variance
  double curr_btwn_cv;
  double max_btwn_cv = Double.MIN_VALUE;
  
  int threshold_val = 0;
  
  for (int i=0; i < h.length; i++) {
    
    if (i > 0) {
      cum_count_b += h[i-1];      // background weight uses sum up to h[i], *exclusive* 
      cum_count_f -= h[i-1];      // foreground weight uses sum from h[i] to end, *inclusive*
      cum_px_sum_b += (h[i-1] * (i-1));     // background pixel val sum is up to h[i], exclusive
      cum_px_sum_f -= (h[i-1] * (i-1));     // foreground is h[i] to end, inclusive
    }
    
    weight_b = cum_count_b / numb_pixels;
    mean_b = cum_px_sum_b / cum_count_b;

    weight_f = cum_count_f / numb_pixels;
    mean_f = cum_px_sum_f / cum_count_f;

    curr_btwn_cv = weight_b * weight_f * Math.pow(mean_b - mean_f, 2);

    if (curr_btwn_cv > max_btwn_cv) {
      max_btwn_cv = curr_btwn_cv;
      threshold_val = i;
    }
  }
  return threshold_val;  
}

// given a histogram, find the median
int calcmedian(int []h) {
  int tsum = 0;
  for (int i = 0; i < h.length; i++) {
    tsum += h[i];
  }
  int sum = 0;
  for (int i = 0; i < h.length; i++) {
    sum += h[i];
    if (sum >= tsum/2) return i;
  }
  return -1;
}


void draw() {
    PImage frame = cam.get(); // make a copy of the image
    frame.filter(GRAY);
   
    background(0, 0, 48);

    image(frame, 0, 0);
    thresh = mouseX % (width/2);
    frame.loadPixels();

    calchist(frame, hist);
    drawhist(hist);

    // calcuate median and draw it on the histogram
    stroke(0, 255, 0);
    int m = calcmedian(hist);
    line(m, height/2, m, height);
    line(m+width/2, height/2, m+width/2, height);

    // calcuate mean and draw it on the histogram
    stroke(0, 255, 255);
    int u = calcmean(hist);
    line(u, height/2, u, height);
    line(u+width/2, height/2, u+width/2, height);

    // calcuate otsu threshold and draw it on the histogram
    stroke(255, 255, 0);
    int o = calcotsu(hist);
    line(o, height/2, o, height);
    line(o+width/2, height/2, o+width/2, height);
    
    if (key == 'u') thresh = u;
    if (key == 'm') thresh = m;
    if (key == 'o') thresh = o;

    for (int i = 0; i < frame.pixels.length; i++) {
      // to gamma correct or not?
      int ivalue = frame.pixels[i] & 0xFF00 >> 8;
      //float value = pow(ivalue/255.0, 1/2.2)*255;
      int value = ivalue;
      frame.pixels[i] = value > thresh? 0xFFFFFF: 0x000000;
    }
    frame.updatePixels();
    //frame.filter(DILATE);
    //frame.filter(DILATE);
    //frame.filter(DILATE);
    image(frame, width/2, 0);

    stroke(0, 0, 255);
    fill(0, 0, 255);
    rect(thresh-3, height-100, 6, 45);
    rect(thresh+width/2-3, height-100, 6, 45);

}

void captureEvent(Capture c) {
  c.read();
}
