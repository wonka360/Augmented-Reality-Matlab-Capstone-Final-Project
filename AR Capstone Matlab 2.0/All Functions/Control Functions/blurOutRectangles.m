function [blurred_img, bbox_list] = blurOutRectangles(img, squares, scale)
    % Blur out detected rectangles/squares from the image using regionfill
    % img: Original image (grayscale or RGB)
    % squares: Cell array where each cell contains a 4x2 matrix of vertices [row, col]
    % blurred_img: Image with rectangles blurred out using regionfill
    % bbox_list: List of bounding boxes [x, y, w, h]
    
    fprintf('Processing %d rectangles/squares...\n', length(squares));
    
    % Step 1: Convert squares vertices to bounding boxes
    bbox_list = zeros(length(squares), 4);
    
    for i = 1:length(squares)
        vertices = squares{i};  % 4x2 matrix: [row, col]
        
        % Extract rows and columns
        rows = vertices(:, 1);
        cols = vertices(:, 2);
        
        % Calculate bounding box [x, y, width, height]
        x_min = floor(min(cols));
        y_min = floor(min(rows));
        x_max = ceil(max(cols));
        y_max = ceil(max(rows));
        
        width = x_max - x_min;
        height = y_max - y_min;
        
        bbox_list(i, :) = [x_min, y_min, width, height];
    end
    
    % Step 2: Initialize masked image with original
    blurred_img = img;
    
    % Step 3: Scale bounding boxes by 10 percent
    
    
    scaled_bbox = zeros(size(bbox_list));
    
    for i = 1:size(bbox_list, 1)
        x = max(bbox_list(i,1) - scale * bbox_list(i,3) / 2, 1);
        y = max(bbox_list(i,2) - scale * bbox_list(i,4) / 2, 1);
        w = bbox_list(i,3) * (1 + scale);
        h = bbox_list(i,4) * (1 + scale);
        scaled_bbox(i, :) = [x, y, w, h];
        
        %fprintf('Rectangle %d: original bbox = [%.1f, %.1f, %.1f, %.1f]\n', ...
                %i, bbox_list(i,1), bbox_list(i,2), bbox_list(i,3), bbox_list(i,4));
        %fprintf('           scaled bbox = [%.1f, %.1f, %.1f, %.1f]\n', ...
                %x, y, w, h);
    end
    
    % Step 4: Apply regionfill to each scaled bounding box
    for i = 1:size(scaled_bbox, 1)
        box = round(scaled_bbox(i, :));  % [x y w h]
        
        % Calculate region boundaries
        x1 = max(1, box(1));
        y1 = max(1, box(2));
        x2 = min(size(img, 2), x1 + box(3) - 1);
        y2 = min(size(img, 1), y1 + box(4) - 1);
        
        % Create mask for region
        mask = false(size(img, 1), size(img, 2));
        mask(y1:y2, x1:x2) = true;
        
        %fprintf('Filling region %d: [%d:%d, %d:%d]\n', i, y1, y2, x1, x2);
        
        % Region fill (works on grayscale or per channel)
        if size(img, 3) == 3
            % RGB image - process each channel
            for c = 1:3
                channel = uint8(blurred_img(:,:,c));
                filled = regionfill(channel, mask);
                blurred_img(:,:,c) = filled;
            end
        else
            % Grayscale image
            blurred_img = regionfill(blurred_img, mask);
        end
    end
    
    fprintf('Region filling complete!\n');
end