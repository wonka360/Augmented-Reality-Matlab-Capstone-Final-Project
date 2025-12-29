% IMPROVED DOOR MARKER DETECTION
function marker = doorPlacementMarker1(shortestLine, line_array, tolerance, gap_max)
    % Improved version with better tolerance and adaptive gap handling
    marker = zeros(1, 4);
    min_left_dist = Inf; min_right_dist = Inf;
    min_top_dist = Inf; min_bottom_dist = Inf;
    
    % INCREASE TOLERANCE SIGNIFICANTLY - this is critical
    tolerance = 25.0; % Much more forgiving for coordinate matching
    gap_max = 150.0; % Increase maximum gap threshold
    
    % Determine orientation
    dx = abs(shortestLine(3) - shortestLine(1));
    dy = abs(shortestLine(4) - shortestLine(2));
    
    isHorizontal = dy < dx;
    isVertical = dx < dy;
    
    if isHorizontal
        target_type = 'horizontal';
    elseif isVertical
        target_type = 'vertical';
    else
        % If almost equal, choose based on which is slightly larger
        if dx >= dy
            target_type = 'horizontal';
        else
            target_type = 'vertical';
        end
    end
    
    % Find surrounding lines
    if strcmp(target_type, 'horizontal')
        hor_x_min = min(shortestLine(1), shortestLine(3));
        hor_x_max = max(shortestLine(1), shortestLine(3));
        hor_y = mean([shortestLine(2), shortestLine(4)]);
        
        for i = 1:size(line_array, 1)
            line = line_array(i, :);
            
            % Skip if it's the same line
            if isequal(line, shortestLine)
                continue;
            end
            
            line_y = mean([line(2), line(4)]);
            
            % Check if line is at same height (with increased tolerance)
            if abs(line_y - hor_y) > tolerance
                continue;
            end
            
            line_x_min = min(line(1), line(3));
            line_x_max = max(line(1), line(3));
            
            % Left candidate - line is to the left of door
            if line_x_max <= hor_x_min + 5  % Small overlap allowed
                dist = hor_x_min - line_x_max;
                if dist <= gap_max && dist < min_left_dist
                    min_left_dist = dist;
                    % Take rightmost endpoint (closest to door)
                    if line(1) > line(3)
                        marker(1:2) = line(1:2);
                    else
                        marker(1:2) = line(3:4);
                    end
                end
            end
            
            % Right candidate - line is to the right of door
            if line_x_min >= hor_x_max - 5  % Small overlap allowed
                dist = line_x_min - hor_x_max;
                if dist <= gap_max && dist < min_right_dist
                    min_right_dist = dist;
                    % Take leftmost endpoint (closest to door)
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
            
            % Skip if it's the same line
            if isequal(line, shortestLine)
                continue;
            end
            
            line_x = mean([line(1), line(3)]);
            
            % Check if line is at same x position (with increased tolerance)
            if abs(line_x - vert_x) > tolerance
                continue;
            end
            
            line_y_min = min(line(2), line(4));
            line_y_max = max(line(2), line(4));
            
            % Top candidate - line is above door
            if line_y_max <= vert_y_min + 5  % Small overlap allowed
                dist = vert_y_min - line_y_max;
                if dist <= gap_max && dist < min_top_dist
                    min_top_dist = dist;
                    % Take bottommost endpoint (closest to door)
                    if line(2) > line(4)
                        marker(1:2) = line(1:2);
                    else
                        marker(1:2) = line(3:4);
                    end
                end
            end
            
            % Bottom candidate - line is below door
            if line_y_min >= vert_y_max - 5  % Small overlap allowed
                dist = line_y_min - vert_y_max;
                if dist <= gap_max && dist < min_bottom_dist
                    min_bottom_dist = dist;
                    % Take topmost endpoint (closest to door)
                    if line(2) < line(4)
                        marker(3:4) = line(1:2);
                    else
                        marker(3:4) = line(3:4);
                    end
                end
            end
        end
    end
    
    % Debug output
    if all(marker == 0)
        fprintf('DEBUG: No surrounding lines found for door at [%.1f,%.1f,%.1f,%.1f]\n', ...
                shortestLine(1), shortestLine(2), shortestLine(3), shortestLine(4));
        fprintf('       Type: %s, Tolerance: %.1f, Gap_max: %.1f\n', ...
                target_type, tolerance, gap_max);
    end
end
