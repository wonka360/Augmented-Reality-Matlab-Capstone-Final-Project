function filteredLines = filterWindowLines1(lines_variable, boundingBoxes)
% lines_variable: Nx4 matrix of lines [x1, y1, x2, y2]
% boundingBoxes: Mx4 matrix of window bounding boxes [x, y, w, h]
% filteredLines: Kx4 matrix of lines after removing those inside window boxes

% Padding settings (can be tuned)
x_pad = 0;
y_pad = 0;
w_pad = 0;
h_pad = 0;

% Early return if no bounding boxes
if isempty(boundingBoxes)
    filteredLines = lines_variable;
    return;
end

% Pre-compute all padded bounding boxes
x1_bounds = boundingBoxes(:, 1) - x_pad;
y1_bounds = boundingBoxes(:, 2) + y_pad;
x2_bounds = boundingBoxes(:, 1) + boundingBoxes(:, 3) + w_pad;
y2_bounds = boundingBoxes(:, 2) - boundingBoxes(:, 4) - h_pad;

% Extract line coordinates for vectorized operations
x1_lines = lines_variable(:, 1);
y1_lines = lines_variable(:, 2);
x2_lines = lines_variable(:, 3);
y2_lines = lines_variable(:, 4);

% Initialize keep mask
keepMask = true(size(lines_variable, 1), 1);

% Vectorized approach: check each bounding box against all lines
for i = 1:size(boundingBoxes, 1)
    % Check if first point is inside bounding box
    inside1 = (x1_lines >= x1_bounds(i)) & (x1_lines <= x2_bounds(i)) & ...
              (y1_lines >= y2_bounds(i)) & (y1_lines <= y1_bounds(i));
    
    % Check if second point is inside bounding box
    inside2 = (x2_lines >= x1_bounds(i)) & (x2_lines <= x2_bounds(i)) & ...
              (y2_lines >= y2_bounds(i)) & (y2_lines <= y1_bounds(i));
    
    % Mark lines for removal if both points are inside
    keepMask = keepMask & ~(inside1 & inside2);
end

% Return filtered lines
filteredLines = lines_variable(keepMask, :);
end