function window_marker = WindowPlacementMarker(window_lines, filtered_lines)
        % window_lines: Line segments representing the window marker
        % filtered_lines: All lines in the image minus window_lines
        % window_marker: Exact position of where windows will be placed
        
        marker = zeros(1,4);
        % --- PARAMETERS ---
        tolerance = 10;       % Tolerance for coordinate matching
        INF = 1e6;           % Large number for min tracking
        line_array = filtered_lines;
        gap_max = 50.0;  % Maximum allowable distance to be considered a neighbor
        
        % --- STEP 1: Classify lines in the window marker ---
        vertical_lines = [];
        horizontal_lines = [];
        
        for i = 1:size(window_lines, 1)
            line = window_lines(i,:);
            if abs(line(1) - line(3)) < abs(line(2) - line(4)) % vertical
                vertical_lines = [vertical_lines; line];
            else % horizontal
                horizontal_lines = [horizontal_lines; line];
            end
        end
        % --- STEP 2: Detect horizontal and vertical reference lines ---
        if ~isempty(horizontal_lines)
            y_centers = mean(horizontal_lines(:, [2,4]), 2); % avg y values
            [~, idx] = sort(y_centers);
            hor_line = horizontal_lines(idx(end-1), :); % second highest
        else
            hor_line = [];
        end
        
        if ~isempty(vertical_lines)
            x_centers = mean(vertical_lines(:, [1,3]), 2); % avg x values
            [~, idx] = sort(x_centers);
            vert_line = vertical_lines(idx(end-1), :); % second from right
        else
            vert_line = [];
        end
        % --- STEP 3: Check which line (horizontal or vertical) is surrounded ---
        surrounded_type = '';  % Can be 'horizontal', 'vertical', or ''
        
        lenght_of_vert_line = ((vert_line(1)-vert_line(3))^2 + (vert_line(2)-vert_line(4))^2)^(1/2);
        lenght_of_hor_line = ((hor_line(1)-hor_line(3))^2 + (hor_line(2)-hor_line(4))^2)^(1/2);
        if lenght_of_hor_line > lenght_of_vert_line
            surrounded_type = 'horizontal';
        else
            surrounded_type = 'vertical';
        end
        
        % --- STEP 4: Decide which type is surrounded ---
        %if ~isempty(hor_line) && check_horizontal_surround(hor_line, line_array, tolerance, gap_max)
            %surrounded_type = 'horizontal';
        %elseif ~isempty(vert_line) && check_vertical_surround(vert_line, line_array, tolerance, gap_max)
            %surrounded_type = 'vertical';
        %else
            %error('Neither hor_line nor vert_line is surrounded.');
        %end
        
        % --- STEP 5: Pass `surrounded_type` to marker detection logic ---
        if strcmp(surrounded_type, 'horizontal')
            target_type = 'horizontal';
            % Proceed with horizontal marker logic (from previous refined version)
        elseif strcmp(surrounded_type, 'vertical')
            target_type = 'vertical';
            % Proceed with vertical marker logic (from previous refined version)
        end
        % --- STEP 6: Find surrounding wall lines in lines_array ---
        % --- PARAMETERS ---
        tolerance = 10.0;     % How close in y (or x) to be considered same level
        
        
        % --- INITIALIZATION ---
        marker = zeros(1,4); % [x1, y1, x2, y2] for surrounding endpoints
        min_left_dist = Inf; min_right_dist = Inf;
        min_top_dist = Inf;  min_bottom_dist = Inf;
        
        % --- HORIZONTAL CASE ---
        if strcmp(target_type, 'horizontal')
            hor_x_min = min(hor_line(1), hor_line(3));
            hor_x_max = max(hor_line(1), hor_line(3));
            hor_y = mean([hor_line(2), hor_line(4)]);
        
            for i = 1:size(line_array, 1)
                line = line_array(i, :);
                if isequal(line, hor_line)
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
            vert_y_min = min(vert_line(2), vert_line(4));
            vert_y_max = max(vert_line(2), vert_line(4));
            vert_x = mean([vert_line(1), vert_line(3)]);
        
            for i = 1:size(line_array, 1)
                line = line_array(i, :);
                if isequal(line, vert_line)
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
        window_marker = marker;
end