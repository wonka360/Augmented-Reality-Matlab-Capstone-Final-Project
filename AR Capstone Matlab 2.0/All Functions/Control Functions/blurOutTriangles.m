function [blurred_img, bbox_list] = blurOutTriangles(img, triangles, scale)


        bbox_list = [];
        for i = 1:length(triangles)
            tri = triangles{i};
            vertices = tri.vertices; % [rows, cols]
            right_idx = tri.right_angle_vertex;
    
            % --- Calculate Bounding Box ---
            % vertices(:,2) are Columns (X), vertices(:,1) are Rows (Y)
            minX = min(vertices(:,2));
            maxX = max(vertices(:,2));
            minY = min(vertices(:,1));
            maxY = max(vertices(:,1));
    
            boxWidth = maxX - minX;
            boxHeight = maxY - minY;
    
            % --- Store bounding box ---
            bbox_list = [bbox_list; minX, minY, boxWidth, boxHeight]; % Append bounding box to list
    
        end

        % Step 2: Initialize masked image with original
    blurred_img = img;
    
    % Step 3: Scale bounding boxes by 19 percent
    
    
    scaled_bbox = zeros(size(bbox_list));
    
    for i = 1:size(bbox_list, 1)
        x = max(bbox_list(i,1) - scale * bbox_list(i,3) / 2, 1);
        y = max(bbox_list(i,2) - scale * bbox_list(i,4) / 2, 1);
        w = bbox_list(i,3) * (1 + scale);
        h = bbox_list(i,4) * (1 + scale);
        scaled_bbox(i, :) = [x, y, w, h];
        
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
        
        fprintf('Filling region %d: [%d:%d, %d:%d]\n', i, y1, y2, x1, x2);
        
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
end