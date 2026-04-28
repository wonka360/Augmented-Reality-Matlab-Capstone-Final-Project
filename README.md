# Augmented-Reality-Matlab-Capstone-Final-Project
This application does a 3D wireframe reconstruction of a building from a natural image of a  2D architectural floor plan, and augments the wireframe on a live video feed of the 2D architectural floor plan.


Click this You Tube Link for a walkthrough of the project: https://youtu.be/GNs2XaKe7Ug

# Disclaimer
The 2D architectural floor plans used in this project does not utilize standard architectural floor plan symbols (e.g quarter arcs for doors and parallel lines for windows) but simpler and still aesthetically significant geometric shapes to mark feautures such as doors, windows and walls. Lines are used to mark walls, gridded rectangles for windows and right angled triangles for doors. The symbols were chosen primary to make feauture extraction simplier which suits the theme of the overall goal of the project in developing a proof of concept augmented reality system in matlab. 

# Brief Outline of Workflow Augmented Reality System
The 2D architectural floor plan made available here is custom made and it incoporates simple gemotric shapes to mark features and an april tag for camera pose estimation.

- First step is to load a natural image of the floor plan into the workspace. This image will be used as a reference image, and feauture extraction will be performed on this image.
- Load the camera intrinsics and calculate the tag pose with the help of the april tag.
- Erase out the april tag, as it will be a source of interferance during feauture extraction.
- Isolate the document. That is eliminate any background in the natural image, such as a table surface and only the contents of the document should be in view. By doing this we move from a normal image coordinate sytem to a different coordinate system (we can call it the crooped image coordinate system).
- Once with document with no april tag and no background, feauture extraction begins.
- We begin with the extraction of wall marker feautures that is line segments. This can be done with a line detection algorithm.
- The Window markers and door markers are also made up of lines so they are erased first. Window and door markers have first to be identified before they are erased.
- To identify window markers, run a rectangle detection algorithm, this detects all window markers and encloses them in bounding boxes.
- With the bounding boxes localizing the window markers, the window markers can be erased.
- To identify door markers, run a right angled traingle detection algorithm, this detects all door markers and encloses them in bounding boxes.
- The door markers are also erased after being localized with bounding boxes.
- With window and door markers erased, run a line detection algorithm, this detects all line segments in the image and hence the wall markers.
- With the wall features extracted, the next step is to determine the window placement position.
- Each window marker is a gridded rectangle, basically 3 parallel long lines of equal length and 3 short lines also of equal length perpendicular to the long lines. The floor plan was designed such that each window marker is between 2 wall markers(line segments) and the middle of the 3 long lines is colinear to the 2 surrounding wall markers.
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

# Preliminary Setup Before Running the Application

Before running the code in this project it is very important that the camera being used to take the photo or the live video feed be calibrated.

Visit https://in.mathworks.com/help/vision/ug/using-the-single-camera-calibrator-app.html for detailed instructions on how to calibrate a camera.

Save the .mat file generated i.e calibrationSession.mat in the root directory 'AR Capstone Matlab 2.0/'


# Things To Do Before Running The Application
Download the folder 'AR Capstone Matlab 2.0' open in either matlab online or matlab desktop and do the following.

1.) Navigate to the sub directory 'Floor Plan Prints' this folder contains, documents of simplified floor plans. Take a Printout of one of these documents.

2.) Take a photo of the printed floor plan in an illuminated room and store the photo in the root directory 'AR Capstone Matlab 2.0/'. 

3.) The photo taken must show all edges of the paper. This is necessary for document isolation. If this is not done the application may fail.

3.) Open the file 'AR_runtime_file.mlx' in the root directory and then in line 16 change the name of the image file to the corresponding name of the reference image.

4.) In line 22 and 27, if a different name was given to the .mat file generated containing camara parameters then change calibrationSession.mat to the new name of the file given.

5.) An input is expected from the user at line 33 for the tagSize (that is width of the tag). The input prompt is at the command terminal which is not very conspicous so the user should take note.

6.) In line 551 change 'DroidCam Source' and instead put the name of the webcamera taking the video feed. Note that the webcamera taking the feed must be thesame camera that took the reference picture.

# Possible Errors To Be Encountered and Their Fixes

Undersired Feature Extraction Quality: Expose the floor plan to a more illuminated environment and take a clear picture of the floor plan again. Avoid taking blurry photographs.

# Snapshot of Results

<img width="699" height="594" alt="Floor_plan_demo1" src="https://github.com/user-attachments/assets/b825aae8-5fae-4d94-a74b-6923a56a8ec3" />

3D reconstructruction of 2D architectural floor plan

<img width="954" height="735" alt="Floor_plan_demo" src="https://github.com/user-attachments/assets/9c733085-84fc-44fc-8073-287003679cd0" />

Overlay of 3D wireframe on 2D architectural floor plan


