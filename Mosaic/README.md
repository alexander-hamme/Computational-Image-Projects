### Mosaic

##### Given:
 - a large folder containing 5,882 images representing the video frames from the movie Willie Wonka (1 frame from each second of the movie).

##### Task:

Reconstruct a target image (or input from the webcam) with a mosaic built with the provided images as mosaic pixels, maintaining the correct color values for each sub region of the image. 

##### Approach:

I created a colorspace bucket data structure that grouped images into fixed size similar color-space buckets during the initial loading from file. With this design, my mosaic construction runs in ***O(n)*** linear time, which enabled me to run it in real-time on the webcam.
