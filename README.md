# Augmented-Reality-Matlab-Capstone-Final-Project
This application does a 3d wireframe reconstruction of a building from a natural image of a  2D architectural floor plan, and augments the wireframe on a live video feed of the 2D architectural floor plan.


Click this You Tube Link for a walkthrough of the project: https://youtu.be/GNs2XaKe7Ug

# Disclaimer
The 2D architectural floor plans used in this project does not utilize standard architectural floor plan symbols (e.g quarter arcs for doors and parallel lines for windows) but simpler and still aesthetically significant geometric shapes to mark feautures such as doors, windows and walls. Lines are used to mark walls, gridded rectangles for windows and right angled triangles for doors. The symbols were chosen primary to make feauture extraction simplier which suits the theme of the overall goal of the project in developing a proof of concept augmented reality system in matlab. 

# Brief Outline of Workflow Augmented Reality System
The 2D architectural floor plan made available here is custom made and it incoporates simple gemotric shapes to mark features and an april tag for camera pose estimation.

- First step is to load a natural image of the floor plan into the workspace. This image will be used as a reference image, and feauture extraction will be performed on this image.
- Load the camera intrinsics and calculate the tag pose with the help of the april tag.
- Erase out the april tag, as it will be a source of interferance during feauture extraction.
- Isolate the document. That is eliminate any background in the natural image, such as a table surface and only the contents of the document should be in view. By doing this we move from a normal image coordinate sytem to a different coordinate system (we can call it the crooped image coordinate system).
- Once we have a document with no april tag and no background, we begin feauture extraction.
- We begin with the extraction of wall marker feautures that is line segments. This can be done with a line detection algorithm.
- The Window markers and door markers are also made up of lines so we erase them first. Window and door markers have to first be identified before they are erased.
- To identify window markers, run a rectangle detection algorithm, this identifies all window markers and encloses them in bounding boxes.
- With the bounding boxes localizing the window markers, the window markers can be erased.
- To identify door markers, run a right angled traingle detection algorithm, this identifies all door markers and encloses them in bounding boxes.
- The door markers are also erased after being localized with bounding boxes.
- With window and door markers removed, run a line detection algorithm, this detects all line segments in the image and hence the wall markers.
- With the wall features extracted, the next step is to determine the window placement position.
- Each window marker is a gridded rectangle basically 3 parallel long lines and 3 short lines perpendicular to the long lines. The floor plan was designed such that each window marker is between 2 wall markers(line segments) and the middle of the 3 long lines is colinear to the 2 surrounding wall markers.
- The closest endpoints to the window marker of the 2 surrounding wall markers, is most convenient to place the windows.
- Using the fact that one of the lines making up the window markers is colinear to the surrounding wall markers, this can be used to extract placement positions for the windows.
- Using the bounding boxes enclosing the window markers, run a localized line detection algorithm to detect the lines making up the window marker.
- Next filter out all 5 lines and preserve the middle of the 3 long lines making up the window marker.
- Using the middle line as a reference line, run a marking algorithm that identifies the closest endpoints of the 2 surrounding wall markers. Store these endpoints in a variable.
- Thesame logic is used to extract door placement positions. In this context however the base of the right angle triangle is colinear to the surrounding wall markers so it is used as a reference line, in extracting door placement coordinates.
- With wall feautures, window and door placement positions extracted, transpose all coordinates from the crooped image coordinate system to the real image coodinate system.
- Perform a 2D extrusion followed by a 3D extrusion to construct the 3d wireframe.
- Transpose all coordinates of the wireframe from image coordinates to real world coordinates.
- Next a life video feed of the 2D architectural floor plan is taken and the 3d wireframe is overlaid on the floor plan.
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
