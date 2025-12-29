function marker = doorPlacementMarker(shortestLine, line_array, tolerance, gap_max)
    marker = zeros(1, 4);
    min_left_dist = Inf; min_right_dist = Inf;
    min_top_dist = Inf; min_bottom_dist = Inf;
    
    % Determine orientation
    isHorizontal = abs(shortestLine(4) - shortestLine(2)) < abs(shortestLine(3) - shortestLine(1));
    isVertical = abs(shortestLine(3) - shortestLine(1)) < abs(shortestLine(4) - shortestLine(2));
    if isHorizontal
        target_type = 'horizontal';
    elseif isVertical
        target_type = 'vertical';
    else
        error('Neither hor_line nor vert_line is surrounded.');
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
            if abs(line_y - hor_y) > tolerance
                continue;
            end
            
            line_x_min = min(line(1), line(3));
            line_x_max = max(line(1), line(3));
            
            if line_x_max < hor_x_min && (hor_x_min - line_x_max) <= gap_max
                if (hor_x_min - line_x_max) < min_left_dist
                    min_left_dist = hor_x_min - line_x_max;
                    if line(1) > line(3)
                        marker(1:2) = line(1:2);
                    else
                        marker(1:2) = line(3:4);
                    end
                end
            end
            
            if line_x_min > hor_x_max && (line_x_min - hor_x_max) <= gap_max
                if (line_x_min - hor_x_max) < min_right_dist
                    min_right_dist = line_x_min - hor_x_max;
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
            
            if line_y_max < vert_y_min && (vert_y_min - line_y_max) <= gap_max
                if (vert_y_min - line_y_max) < min_top_dist
                    min_top_dist = vert_y_min - line_y_max;
                    if line(2) > line(4)
                        marker(1:2) = line(1:2);
                    else
                        marker(1:2) = line(3:4);
                    end
                end
            end
            
            if line_y_min > vert_y_max && (line_y_min - vert_y_max) <= gap_max
                if (line_y_min - vert_y_max) < min_bottom_dist
                    min_bottom_dist = line_y_min - vert_y_max;
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