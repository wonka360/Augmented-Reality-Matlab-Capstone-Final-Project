# Augmented-Reality-Matlab-Capstone-Final-Project
This application augments a 3d vitual image of a building on a live video feed of a floor plan

# How To Use This Application
This applications makes extensive use of Python's Open cv. Therefore inorder to run this application python's anaconda navigator must be intalled.

After Installing anaconda navigator, click on the start button in windows and type Anaconda Prompt. Run matlab from Anaconda Prompt by typing 'matlab' (type matlab without the quotes symbols '').

Once the matlab application opens, Navigate to the directory 'AR Capstone Project'.

Callibrate the the camera that will be use to take the video feed, in the camera Callibrator App and save the generated mat file in 'AR Capstone Project' directory. The current callibrationSession files stored in this folders are the camera parameters of the camera used in the development of this project so it shouldn't be used. 

# Things To Do Before Running The Application

1.) Navigate to the sub directory 'Floor Plan Prints' this folder contains, documents of simplified floor plans. Take a Printout of one of these documents.

2.) Take a photo of the printed floor plan in an illuminated room and store the photo in the sub-directory 'Pictures'. This application does not extract floor plan feautures from video frames because after numerous testing rounds, it was found that because video frames are generally of poorer quality as compared to actual photos, the algorithms performed poorly when trying to extract feautures from the floor plan. Hence a reference photogragh was used instead to extract all necessary feautures on the floor plan and then the virtual content augmented on the video feed.

3.) The photo taken must show all edges of the paper. This is necessary for document detection. If this is not done the application may fail.

3.) Navigate back to the 'AR Capstone Project' main root directory and then open the file 'AR runtime script' and then in line 8 change the name of the image file to the corresponding name of the reference image.

4.) In line 13, change the cancel callibrationSession1.mat and put the name of the file containing callibration parameters of the callibrated camera.

5.) In line 530 change 'DroidCam Source 3' and instead put the name of webcamera taking the video feed. Note that the webcamera taking the feed must be thesame camera that took the reference picture.

# Possible Errors To Be Encountered and Their Fixes

1.) 'Python Module Not Found libmbuffer Error': Whenever this error is encountered, simply close matlab and restart the application through anaconda prompt.

2.) Undersired Feature Extraction Quality: Expose the floor plan to more light and take a clear picture of the floor plan again. Avoid taking blurred photographs.
