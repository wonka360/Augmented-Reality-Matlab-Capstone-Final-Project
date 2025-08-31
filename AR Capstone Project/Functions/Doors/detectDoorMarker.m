function bbox_list = detectDoorMarker(imagePath)
        % This function detects all door markers in the image and draws a
        % bounding box around them
        % The door markers in question are right angle triangles
        %imagePath: Image of our floor plan
        % bbox_list: [x y w h] bounding boxes encircleling the door markers
        % iou_check: Used to tighten tolerance when filtering
        img = imagePath;
        iou_check = 0.65; % control variable used to filter out duplicate bounding boxes
        
        if isempty(img)
            error("Image not found or unreadable. Check path: %s", imagePath);
        end
        
        img = py.cv2.GaussianBlur(img, py.tuple({int32(5), int32(5)}), 0);
        % --- Initialize ---
        triangles = {};
        bbox_list = [];
        seen_triangles = {};
        
        channels = py.cv2.split(img);
        
        for ch = 1:length(channels)
            gray = py.numpy.array(channels{ch});
            
            for thrs = 0:26:255
                if thrs == 0
                    bin = py.cv2.Canny(gray, int32(0), int32(50), pyargs('apertureSize', int32(5)));
                    bin = py.cv2.dilate(bin, []);
                else
                    thresh_result = py.cv2.threshold(gray, thrs, 255, py.cv2.THRESH_BINARY);
                    bin = thresh_result{2};
                end
        
                contourOutput = py.cv2.findContours(bin, py.cv2.RETR_LIST, py.cv2.CHAIN_APPROX_SIMPLE);
                contours = contourOutput{1};
        
                for k = 1:length(contours)
                    cnt = contours{k};
                    cnt_len = py.cv2.arcLength(cnt, true);
                    approx = py.cv2.approxPolyDP(cnt, 0.02 * double(cnt_len), true);
        
                    % --- Right-angled triangle check (3-point contour) ---
                    if int64(approx.shape{1}) == 3 && ...
                       py.cv2.contourArea(approx) > 500 && ...
                       py.cv2.isContourConvex(approx)
        
                        approx_np = py.numpy.array(approx).reshape(int32([-1, 2]));
                        pts = double(approx_np);  % 3x2
        
                        % Side vectors
                        v1 = pts(2,:) - pts(1,:);
                        v2 = pts(3,:) - pts(2,:);
                        v3 = pts(1,:) - pts(3,:);
        
                        % Cosines of internal angles
                        cos1 = abs(dot(v1, -v3) / (norm(v1) * norm(v3)));
                        cos2 = abs(dot(-v1, v2) / (norm(v1) * norm(v2)));
                        cos3 = abs(dot(-v2, v3) / (norm(v2) * norm(v3)));
        
                        cosines = [cos1, cos2, cos3];
                        [min_cos, idx] = min(cosines);  % right angle
        
                        if min_cos < 0.15
                            % Right angle at point idx
                            right_pt = pts(idx, :);
                            adj_pt1 = pts(mod(idx,3)+1, :);
                            adj_pt2 = pts(mod(idx+1,3)+1, :);
        
                            % Bounding box around triangle
                            x = min([right_pt(1), adj_pt1(1), adj_pt2(1)]);
                            y = min([right_pt(2), adj_pt1(2), adj_pt2(2)]);
                            w = max([right_pt(1), adj_pt1(1), adj_pt2(1)]) - x;
                            h = max([right_pt(2), adj_pt1(2), adj_pt2(2)]) - y;
                            current_bbox = [x, y, w, h];
        
                            % Triangle uniqueness key (sorted, rounded)
                            sorted_pts = sortrows(pts);
                            triangle_key = mat2str(round(sorted_pts, 1));  % rounded for robustness
        
                            % --- Deduplication: Key + IoU check ---
                            is_duplicate = false;
        
                            % 1. Key check
                            if ismember(triangle_key, seen_triangles)
                                is_duplicate = true;
                            else
                                % 2. IoU check
                                for i = 1:size(bbox_list, 1)
                                    existing_bbox = bbox_list(i, :);
                                    xi1 = max(current_bbox(1), existing_bbox(1));
                                    yi1 = max(current_bbox(2), existing_bbox(2));
                                    xi2 = min(current_bbox(1) + current_bbox(3), existing_bbox(1) + existing_bbox(3));
                                    yi2 = min(current_bbox(2) + current_bbox(4), existing_bbox(2) + existing_bbox(4));
        
                                    inter_w = max(0, xi2 - xi1);
                                    inter_h = max(0, yi2 - yi1);
                                    inter_area = inter_w * inter_h;
        
                                    union_area = current_bbox(3) * current_bbox(4) + ...
                                                 existing_bbox(3) * existing_bbox(4) - inter_area;
        
                                    iou = inter_area / union_area;
        
                                    if iou > iou_check
                                        is_duplicate = true;
                                        break;
                                    end
                                end
                            end
        
                            % Store if unique
                            if ~is_duplicate
                                seen_triangles{end+1} = triangle_key;
                                bbox_list(end+1, :) = current_bbox;
                                triangles{end+1} = pts;
                            end
                        end
                    end
                end
            end
        end


        
end
    