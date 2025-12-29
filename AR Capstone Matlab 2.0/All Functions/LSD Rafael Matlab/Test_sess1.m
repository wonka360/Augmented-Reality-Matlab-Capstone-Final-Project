addpath("Test Images LSD")
image_path = 'sample_floor_plan9.jpeg';
img = imread(image_path);


% Check if the image is color (3D) and convert to grayscale (2D)
if size(img, 3) == 3
    img = rgb2gray(img);
end


%[line_segments, ~, ~] = lsd(img, 'scale', 1.0, 'ang_th', 30, 'log_eps', 1.0, 'density_th', 0.8);
[line_segments, ~, ~] = lsd(img, 'scale', 1.0, 'ang_th', 22.5, 'log_eps', 3.0, 'density_th', 0.85);
    

line_coordinates = line_segments(:, 1:4);
%% Session 2
% Quick visualization
figure;
imshow(img);
hold on;
for i = 1:size(line_coordinates, 1)
    plot([line_coordinates(i,1) line_coordinates(i,3)], ...
         [line_coordinates(i,2) line_coordinates(i,4)], 'r-', 'LineWidth', 2);
end

%% Merging and Visualization
min_distance = 10;
min_angle = 5;
lines_array = merge_groups(line_coordinates, min_distance, min_angle);

%% Process the lines_array for further analysis or visualization
imshow(img);
hold on;
title('Merged Lines using HoughBundler');
for i = 1:size(lines_array,1)
    x = [lines_array(i,1) lines_array(i,3)];
    y = [lines_array(i,2) lines_array(i,4)];
    plot(x, y, 'g-', 'LineWidth', 2);
end
hold off;