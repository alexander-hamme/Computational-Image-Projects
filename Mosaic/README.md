### Mosaic

#### Given:
A large folder containing 5,882 images representing the video frames from the movie Willie Wonka (1 frame from each second of the movie).

#### Task:

Reconstruct a target image (or input from the webcam) with a mosaic built with the provided images as mosaic pixels, maintaining the correct color values for each sub region of the image. 

#### Approach:

I created a color-space bucket data structure that grouped images into fixed size similar color-space buckets during the initial loading from file. Difference in color spaces was calculated using the euclidean distance between the average RGB value of each image (calculated just once during initial image loading). With this design, I kept my mosaic construction function to ***O(n)*** linear time, which enabled me to run it real-time on the webcam.
