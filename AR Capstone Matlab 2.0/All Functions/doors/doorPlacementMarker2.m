function marker = doorPlacementMarker2(shortestLine, line_array, tolerance, gap_max)
    % Balanced version with reasonable tolerance
    marker = zeros(1, 4);
    min_left_dist = Inf; min_right_dist = Inf;
    min_top_dist = Inf; min_bottom_dist = Inf;
    
    % Use moderate tolerance - not too strict, not too loose
    tolerance = 20.0;
    gap_max = 100.0;
    
    % Determine orientation
    dx = abs(shortestLine(3) - shortestLine(1));
    dy = abs(shortestLine(4) - shortestLine(2));
    
    if dy < dx
        target_type = 'horizontal';
    else
        target_type = 'vertical';
    end
    
    % Find surrounding lines
    if strcmp(target_type, 'horizontal')
        hor_x_min = min(shortestLine(1), shortestLine(3));
        hor_x_max = max(shortestLine(1), shortestLine(3));
        hor_y = mean([shortestLine(2), shortestLine(4)]);
        
        for i = 1:size(line_array, 1)
            line = line_array(i, :);
            
            if isequal(line, shortestLine)
                continue;
            end
            
            line_y = mean([line(2), line(4)]);
            
            % Check if line is at same height
            if abs(line_y - hor_y) > tolerance
                continue;
            end
            
            line_x_min = min(line(1), line(3));
            line_x_max = max(line(1), line(3));
            
            % Left candidate
            if line_x_max <= hor_x_min
                dist = hor_x_min - line_x_max;
                if dist <= gap_max && dist < min_left_dist
                    min_left_dist = dist;
                    if line(1) > line(3)
                        marker(1:2) = line(1:2);
                    else
                        marker(1:2) = line(3:4);
                    end
                end
            end
            
            % Right candidate
            if line_x_min >= hor_x_max
                dist = line_x_min - hor_x_max;
                if dist <= gap_max && dist < min_right_dist
                    min_right_dist = dist;
                    if line(1) < line(3)
                        marker(3:4) = line(1:2);
                    else
                        marker(3:4) = line(3:4);
                    end
                end
            end
        end
        
    elseif strcmp(target_type, 'vertical')
        vert_y_min = min(shortestLine(2), shortestLine(4));
        vert_y_max = max(shortestLine(2), shortestLine(4));
        vert_x = mean([shortestLine(1), shortestLine(3)]);
        
        for i = 1:size(line_array, 1)
            line = line_array(i, :);
            
            if isequal(line, shortestLine)
                continue;
            end
            
            line_x = mean([line(1), line(3)]);
            
            if abs(line_x - vert_x) > tolerance
                continue;
            end
            
            line_y_min = min(line(2), line(4));
            line_y_max = max(line(2), line(4));
            
            % Top candidate
            if line_y_max <= vert_y_min
                dist = vert_y_min - line_y_max;
                if dist <= gap_max && dist < min_top_dist
                    min_top_dist = dist;
                    if line(2) > line(4)
                        marker(1:2) = line(1:2);
                    else
                        marker(1:2) = line(3:4);
                    end
                end
            end
            
            % Bottom candidate
            if line_y_min >= vert_y_max
                dist = line_y_min - vert_y_max;
                if dist <= gap_max && dist < min_bottom_dist
                    min_bottom_dist = dist;
                    if line(2) < line(4)
                        marker(3:4) = line(1:2);
                    else
                        marker(3:4) = line(3:4);
                    end
                end
            end
        end
    end
end
