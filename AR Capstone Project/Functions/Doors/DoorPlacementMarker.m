function door_marker = DoorPlacementMarker(door_lines, filtered_lines)
        % door_marker: Nx4 vector of exact door placement positions
        % door_lines: Lines of door marker
        % filtered_lines: All lines in the image except door marker lines
        marker = zeros(1,4);
        % --- PARAMETERS ---
        tolerance = 10;       % Tolerance for coordinate matching
        INF = 1e6;           % Large number for min tracking
        line_array = filtered_lines;
        gap_max = 50.0;       % Maximum allowable distance to be considered a neighbor
        % Step 1 -- Select the line segment of the door marker which
        % is surrounded by the wall line segments
        
        % Identify the shortest line segment
        lineLengths = sqrt((door_lines(:,3) - door_lines(:,1)).^2 + (door_lines(:,4) - door_lines(:,2)).^2);
        [~, minIndex] = min(lineLengths);
        shortestLine = door_lines(minIndex, :);
        
        % Test to see if the line is horizontal or vertical
        % Determine the orientation of the shortest line segment
        isHorizontal = abs(shortestLine(4) - shortestLine(2)) < abs(shortestLine(3) - shortestLine(1));
        isVertical = abs(shortestLine(3) - shortestLine(1)) < abs(shortestLine(4) - shortestLine(2));
        if isHorizontal
            surrounded_type = 'horizontal';
        
        elseif isVertical
                surrounded_type = 'vertical';
        else
            error('Neither hor_line nor vert_line is surrounded.');
        end
        % --- STEP 2: Pass `surrounded_type` to marker detection logic ---
        if strcmp(surrounded_type, 'horizontal')
            target_type = 'horizontal';
            % Proceed with horizontal marker logic (from previous refined version)
        elseif strcmp(surrounded_type, 'vertical')
            target_type = 'vertical';
            % Proceed with vertical marker logic (from previous refined version)
        end
        
        % --- STEP 3: Find surrounding wall lines in lines_array ---
        % --- PARAMETERS ---
        tolerance = 10.0;     % How close in y (or x) to be considered same level
        
        
        % --- INITIALIZATION ---
        marker = zeros(1,4); % [x1, y1, x2, y2] for surrounding endpoints
        min_left_dist = Inf; min_right_dist = Inf;
        min_top_dist = Inf;  min_bottom_dist = Inf;
        
        % --- HORIZONTAL CASE ---
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
        
                % Left candidate
                if line_x_max < hor_x_min
                    dist = hor_x_min - line_x_max;
                    if dist < min_left_dist && dist <= gap_max
                        min_left_dist = dist;
                        if line(1) > line(3)
                            marker(1:2) = line(1:2);
                        else
                            marker(1:2) = line(3:4);
                        end
                    end
                end
        
                % Right candidate
                if line_x_min > hor_x_max
                    dist = line_x_min - hor_x_max;
                    if dist < min_right_dist && dist <= gap_max
                        min_right_dist = dist;
                        if line(1) < line(3)
                            marker(3:4) = line(1:2);
                        else
                            marker(3:4) = line(3:4);
                        end
                    end
                end
            end
        % --- VERTICAL CASE ---
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
                if line_y_max < vert_y_min
                    dist = vert_y_min - line_y_max;
                    if dist < min_top_dist && dist <= gap_max
                        min_top_dist = dist;
                        if line(2) > line(4)
                            marker(1:2) = line(1:2);
                        else
                            marker(1:2) = line(3:4);
                        end
                    end
                end
        
                % Bottom candidate
                if line_y_min > vert_y_max
                    dist = line_y_min - vert_y_max;
                    if dist < min_bottom_dist && dist <= gap_max
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
        door_marker = marker;

end