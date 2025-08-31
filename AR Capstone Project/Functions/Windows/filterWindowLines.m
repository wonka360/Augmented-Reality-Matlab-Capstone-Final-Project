function filteredLines = filterWindowLines(lines_variable, boundingBoxes)
% lines_variable: Nx4 matrix of lines [x1, y1, x2, y2]
% boundingBoxes: Mx4 matrix of window bounding boxes [x, y, w, h]
% filteredLines: Kx4 matrix of lines after removing those inside window boxes

    % Padding settings (can be tuned)
    x_pad = 200;
    y_pad = 200;
    w_pad = 200;
    h_pad = 200;

    keepMask = true(size(lines_variable, 1), 1); % initially keep all lines

    for i = 1:size(boundingBoxes, 1)
        % Get the bounding box
        x = boundingBoxes(i, 1);
        y = boundingBoxes(i, 2);
        w = boundingBoxes(i, 3);
        h = boundingBoxes(i, 4);

        % Create padded bounding box (slightly bigger)
        x1_bound = x - x_pad;
        y1_bound = y + y_pad;
        x2_bound = x + w + w_pad;
        y2_bound = y - h - h_pad;

        % Loop through all lines
        for j = 1:size(lines_variable, 1)
            x1 = lines_variable(j, 1);
            y1 = lines_variable(j, 2);
            x2 = lines_variable(j, 3);
            y2 = lines_variable(j, 4);

            % Check if both points lie inside the bounding box
            inside1 = (x1 >= x1_bound && x1 <= x2_bound && y1 >= y2_bound && y1 <= y1_bound);
            inside2 = (x2 >= x1_bound && x2 <= x2_bound && y2 >= y2_bound && y2 <= y1_bound);

            if inside1 && inside2
                keepMask(j) = false; % mark line for removal
            end
        end
    end

    % Return only lines not inside window boxes
    filteredLines = lines_variable(keepMask, :);
end
