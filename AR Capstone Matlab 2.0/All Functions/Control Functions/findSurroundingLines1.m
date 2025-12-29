function marker = findSurroundingLines1(target_type, hor_line, vert_line, ...
                                       line_array, tolerance, gap_max)
    marker = zeros(1,4);
    min_left_dist = Inf; min_right_dist = Inf;
    min_top_dist = Inf; min_bottom_dist = Inf;
    
    % HORIZONTAL CASE
    if strcmp(target_type, 'horizontal')
        hor_x_min = min(hor_line(1), hor_line(3));
        hor_x_max = max(hor_line(1), hor_line(3));
        hor_y = mean([hor_line(2), hor_line(4)]);
        
        for i = 1:size(line_array, 1)
            line = line_array(i, :);
            line_y = mean([line(2), line(4)]);
            
            % Check if line is roughly at same height
            if abs(line_y - hor_y) > tolerance
                continue;
            end
            
            line_x_min = min(line(1), line(3));
            line_x_max = max(line(1), line(3));
            
            % Left candidate
            if line_x_max <= hor_x_min
                dist = hor_x_min - line_x_max;
                if dist < min_left_dist && dist <= gap_max
                    min_left_dist = dist;
                    % Take the endpoint closest to the window
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
        
    % VERTICAL CASE
    elseif strcmp(target_type, 'vertical')
        vert_y_min = min(vert_line(2), vert_line(4));
        vert_y_max = max(vert_line(2), vert_line(4));
        vert_x = mean([vert_line(1), vert_line(3)]);
        
        for i = 1:size(line_array, 1)
            line = line_array(i, :);
            line_x = mean([line(1), line(3)]);
            
            if abs(line_x - vert_x) > tolerance
                continue;
            end
            
            line_y_min = min(line(2), line(4));
            line_y_max = max(line(2), line(4));
            
            % Top candidate
            if line_y_max <= vert_y_min
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
            if line_y_min >= vert_y_max
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
end
