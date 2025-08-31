function [shifted_lines, door_lines] = detectAndFilterLines(cropped_mat, bbox, merged, scale)
    % Convert to Python format
    cropped_py_img = py.numpy.array(permute(cropped_mat, [2 1 3]));
    
    % Detect and merge lines in ROI
    [lines_array, ~] = detectAndDisplayLines(cropped_py_img);
    merged_final = merge_groups(lines_array, 10, 5); % Nx4: [x1 y1 x2 y2]
    
    % Convert to original image coordinates
    x_box = double(bbox(1));
    y_box = double(bbox(2));
    w_box = double(bbox(3));
    h_box = double(bbox(4));
    x = max(x_box - scale * w_box / 2, 0);
    y = max(y_box - scale * h_box / 2, 0);
    
    shifted_lines = merged_final;
    shifted_lines(:, [1 3]) = shifted_lines(:, [1 3]) + x;
    shifted_lines(:, [2 4]) = shifted_lines(:, [2 4]) + y;
    
    door_lines = shifted_lines; % All lines in ROI are potential door lines
end
