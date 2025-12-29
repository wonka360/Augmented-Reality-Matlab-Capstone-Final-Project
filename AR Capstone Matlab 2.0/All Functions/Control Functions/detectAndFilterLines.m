function [lines_of_interest] = detectAndFilterLines(cropped_img, bbox, scale)
    
    % Detect and merge lines in ROI
    cropped_img_gray = rgb2gray(cropped_img);
    [line_segments, ~, ~] = lsd(cropped_img_gray, 'scale', 1.0, 'ang_th', 22.5, 'log_eps', 3.0, 'density_th', 0.85);
    % Extract line segment coordinates
    line_coordinates = line_segments(:, 1:4);
    merged_final = merge_groups(line_coordinates, 10, 5); % Nx4: [x1 y1 x2 y2]
    
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
    
    lines_of_interest = shifted_lines; % All lines in ROI are potential door lines
end
