function triangles = detectTriangles(B, imageSize)
    triangles = {};
    
    for k = 1:length(B)
        cnt = B{k};
        
        % Adaptive tolerance
        if size(cnt, 1) > 1500
            tolerances = [0.05, 0.08, 0.10, 0.12, 0.15];
        elseif size(cnt, 1) > 500
            tolerances = [0.03, 0.05, 0.08, 0.10, 0.12];
        else
            tolerances = [0.02, 0.03, 0.05, 0.08, 0.10];
        end
        
        best_result = struct('vertices', [], 'n_verts', 0);
        for tol = tolerances
            approx = reducepoly(cnt, tol);
            
            temp_clean = removeDuplicateVertices(approx, 3.0);
            
            if size(temp_clean, 1) >= 3 && size(temp_clean, 1) <= 5
                best_result = struct('vertices', temp_clean, 'n_verts', size(temp_clean, 1));
                if size(temp_clean, 1) == 3
                    break; 
                end
            end
        end
        
        if best_result.n_verts == 0
            continue;
        end
        
        approx_clean = best_result.vertices;
        
        if size(approx_clean, 1) >= 4 && size(approx_clean, 1) <= 5
            approx_clean = reduceToThreeVertices(approx_clean);
        end
        
        if size(approx_clean, 1) ~= 3
            continue;
        end
        
        % Calculate area
        area = polyarea(approx_clean(:,2), approx_clean(:,1));
        
        if area < 100 || area > 30000
            continue;
        end
        
        % Calculate dimensions
        rows = approx_clean(:, 1);
        cols = approx_clean(:, 2);
        width = max(cols) - min(cols);
        height = max(rows) - min(rows);
        max_dim = max(width, height);
        min_dim = min(width, height);
        min_width = calculateMinTriangleWidth(approx_clean);
        
        if min_width < 8
            continue;
        end
        
        aspect_ratio = max_dim / min_dim;
        if aspect_ratio > 8.0
            continue;
        end
        
        if ~isConvex(approx_clean)
            continue;
        end
        
        % Calculate angles
        angles = zeros(3, 1);
        cosines = zeros(3, 1);
        for i = 1:3
            p1 = approx_clean(i, :);
            p2 = approx_clean(mod(i, 3) + 1, :);
            p3 = approx_clean(mod(i+1, 3) + 1, :);
            v1 = p1 - p2;
            v2 = p3 - p2;
            cos_angle = dot(v1, v2) / (norm(v1) * norm(v2));
            cosines(i) = abs(cos_angle);
            angles(i) = acosd(cos_angle);
        end
        
        [min_cos, right_angle_idx] = min(cosines);
        
        if min_cos >= 0.12
            if abs(angles(right_angle_idx) - 90) > 10
                continue;
            end
        end
        
        if min(angles) < 18
            continue;
        end
        
        angle_sum = sum(angles);
        if abs(angle_sum - 180) > 40
            continue;
        end
        
        if max_dim >= imageSize(1) * 0.9
            continue;
        end
        
        % Determine orientation
        if width > height
            orientation_str = 'horizontal';
        else
            orientation_str = 'vertical';
        end
        
        triangle_data.vertices = approx_clean;
        triangle_data.right_angle_vertex = right_angle_idx;
        triangle_data.angles = angles;
        triangle_data.area = area;
        triangle_data.orientation = orientation_str;
        triangle_data.min_width = min_width;
        triangles{end+1} = triangle_data;
    end
end
