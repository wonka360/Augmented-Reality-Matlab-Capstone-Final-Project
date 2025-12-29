function bbox_list = extractSquareBoundingBoxes(squares)
% Extract bounding boxes from detected squares

% squares      : Cell array where each cell contains a 4x2 matrix [row, col]
% bbox_list    : Original bounding boxes [x, y, w, h]
% scaled_bbox  : Scaled bounding boxes (19% expansion)


    % Step 1: Convert square vertices to bounding boxes
    bbox_list = zeros(length(squares), 4);

    for i = 1:length(squares)
        vertices = squares{i};   % 4x2 matrix: [row, col]

        % Extract rows and columns
        rows = vertices(:, 1);
        cols = vertices(:, 2);

        % Calculate bounding box [x, y, width, height]
        x_min = floor(min(cols));
        y_min = floor(min(rows));
        x_max = ceil(max(cols));
        y_max = ceil(max(rows));

        width  = x_max - x_min;
        height = y_max - y_min;

        bbox_list(i, :) = [x_min, y_min, width, height];
    end

end
