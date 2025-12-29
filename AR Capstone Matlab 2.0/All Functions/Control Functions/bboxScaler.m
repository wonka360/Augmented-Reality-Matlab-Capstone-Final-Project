function scaled_bbox = bboxScaler(bboxes, scale)
    scaled_bbox = [];  % Initialize the scaled bounding box array
    for i = 1:size(bboxes, 1)
        % Extract coordinates and dimensions for the current door box
        x_box = bboxes(i, 1);
        y_box = bboxes(i, 2);
        w_box = bboxes(i, 3);
        h_box = bboxes(i, 4);
        x = max(x_box - scale * w_box / 2, 0);
        y = max(y_box - scale * h_box / 2, 0);
        w = w_box * (1 + scale);
        h = h_box * (1 + scale);
        scaled_bbox = [scaled_bbox; x, y, w, h];  % Store the adjusted window box dimensions
    end
end
