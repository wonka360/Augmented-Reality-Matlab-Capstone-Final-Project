# Augmented-Reality-Matlab-Capstone-Final-Project
This application augments a 3d virtual image of a building on a live video feed of a floor plan

# How To Use This Application

Open Matlab Desktop or Matlab online

Once the matlab application opens, Navigate to the directory 'AR Capstone Matlab 2.0'.

Callibrate the the camera that will be use to take the video feed, in the camera Callibrator App and save the generated mat file in 'AR Capstone Matlab 2.0' directory. The current callibrationSession files stored in this folders are the camera parameters of the camera used in the development of this project so it shouldn't be used. 

# Things To Do Before Running The Application

1.) Navigate to the sub directory 'Floor Plan Prints' this folder contains, documents of simplified floor plans. Take a Printout of one of these documents.

2.) Take a photo of the printed floor plan in an illuminated room and store the photo in the sub-directory 'Pictures'. 

3.) The photo taken must show all edges of the paper. This is necessary for document detection. If this is not done the application may fail.

3.) Navigate back to the 'AR Capstone Matlab 2.0' main root directory and then open the file 'AR runtime script' and then in line 9 change the name of the image file to the corresponding name of the reference image.

4.) In line 16, change the cancel callibrationSession1.mat and put the name of the file containing callibration parameters of the callibrated camera.

5.) In line 501 change 'DroidCam Source' and instead put the name of the webcamera taking the video feed. Note that the webcamera taking the feed must be thesame camera that took the reference picture.

# Possible Errors To Be Encountered and Their Fixes

1.) Not all Lines on the Floor Plan Detected: The lsd function is very robust and so it's parameters can be tuned so as to improve line detection. For this application however the lsd function was throttled so as to reduce the number of line segments. The reason is the lsd function can detect more than 20,000 line  for a single floor plan, and merging the lines on matlab desktop could take considerable time (upwards of 10 minutes). If detection is unsatisfactory, tune the the different parameters of the lsd function. 

2.) Undersired Feature Extraction Quality: Expose the floor plan to more light and take a clear picture of the floor plan again. Avoid taking blurred photographs.
