function window_marker = WindowPlacementMarker2(window_lines, filtered_lines)
    % Balanced version that detects all windows correctly
    
    marker = zeros(1,4);
    
    % Moderate parameters - balanced approach
    tolerance = 20.0;
    gap_max = 100.0;
    
    if isempty(window_lines)
        warning('No window lines detected');
        return;
    end
    
    % STEP 1: Classify lines
    vertical_lines = [];
    horizontal_lines = [];
    
    for i = 1:size(window_lines, 1)
        line = window_lines(i,:);
        dx = abs(line(1) - line(3));
        dy = abs(line(2) - line(4));
        
        if dx < dy
            vertical_lines = [vertical_lines; line];
        else
            horizontal_lines = [horizontal_lines; line];
        end
    end
    
    % STEP 2: Select reference lines - use the OUTER frame lines
    % These are the lines that actually touch the walls
    hor_line = [];
    vert_line = [];
    
    if size(horizontal_lines, 1) >= 3
        % For windows with 3 horizontal lines, pick the middle one (frame)
        y_centers = mean(horizontal_lines(:, [2,4]), 2);
        [~, idx] = sort(y_centers);
        mid_idx = idx(2); % Second one (middle)
        hor_line = horizontal_lines(mid_idx, :);
    elseif size(horizontal_lines, 1) == 2
        % For 2 lines, pick the one closer to walls (longer or outer one)
        h_lengths = sqrt((horizontal_lines(:,3) - horizontal_lines(:,1)).^2 + ...
                         (horizontal_lines(:,4) - horizontal_lines(:,2)).^2);
        [~, max_idx] = max(h_lengths);
        hor_line = horizontal_lines(max_idx, :);
    elseif size(horizontal_lines, 1) == 1
        hor_line = horizontal_lines(1, :);
    end
    
    if size(vertical_lines, 1) >= 3
        % For windows with 3 vertical lines, pick the middle one (frame)
        x_centers = mean(vertical_lines(:, [1,3]), 2);
        [~, idx] = sort(x_centers);
        mid_idx = idx(2); % Second one (middle)
        vert_line = vertical_lines(mid_idx, :);
    elseif size(vertical_lines, 1) == 2
        % For 2 lines, pick the one closer to walls (longer or outer one)
        v_lengths = sqrt((vertical_lines(:,3) - vertical_lines(:,1)).^2 + ...
                         (vertical_lines(:,4) - vertical_lines(:,2)).^2);
        [~, max_idx] = max(v_lengths);
        vert_line = vertical_lines(max_idx, :);
    elseif size(vertical_lines, 1) == 1
        vert_line = vertical_lines(1, :);
    end
    
    % STEP 3: Determine orientation
    surrounded_type = '';
    
    if ~isempty(hor_line) && ~isempty(vert_line)
        length_hor = sqrt((hor_line(3)-hor_line(1))^2 + (hor_line(4)-hor_line(2))^2);
        length_vert = sqrt((vert_line(3)-vert_line(1))^2 + (vert_line(4)-vert_line(2))^2);
        
        if length_hor > length_vert
            surrounded_type = 'horizontal';
        else
            surrounded_type = 'vertical';
        end
    elseif ~isempty(hor_line)
        surrounded_type = 'horizontal';
    elseif ~isempty(vert_line)
        surrounded_type = 'vertical';
    else
        warning('No reference lines found for window marker');
        return;
    end
    
    % STEP 4: Find surrounding wall lines with strict matching
    marker = zeros(1,4);
    min_left_dist = Inf; min_right_dist = Inf;
    min_top_dist = Inf; min_bottom_dist = Inf;
    
    % Track candidates for debugging
    left_candidates = [];
    right_candidates = [];
    top_candidates = [];
    bottom_candidates = [];
    
    % HORIZONTAL CASE
    if strcmp(surrounded_type, 'horizontal')
        hor_x_min = min(hor_line(1), hor_line(3));
        hor_x_max = max(hor_line(1), hor_line(3));
        hor_y = mean([hor_line(2), hor_line(4)]);
        
        for i = 1:size(filtered_lines, 1)
            line = filtered_lines(i, :);
            line_y = mean([line(2), line(4)]);
            
            % Must be at approximately same height
            if abs(line_y - hor_y) > tolerance
                continue;
            end
            
            line_x_min = min(line(1), line(3));
            line_x_max = max(line(1), line(3));
            
            % Left candidate - strictly to the left (no overlap)
            if line_x_max <= hor_x_min
                dist = hor_x_min - line_x_max;
                if dist <= gap_max
                    left_candidates = [left_candidates; line, dist];
                    if dist < min_left_dist
                        min_left_dist = dist;
                        if line(1) > line(3)
                            marker(1:2) = line(1:2);
                        else
                            marker(1:2) = line(3:4);
                        end
                    end
                end
            end
            
            % Right candidate - strictly to the right (no overlap)
            if line_x_min >= hor_x_max
                dist = line_x_min - hor_x_max;
                if dist <= gap_max
                    right_candidates = [right_candidates; line, dist];
                    if dist < min_right_dist
                        min_right_dist = dist;
                        if line(1) < line(3)
                            marker(3:4) = line(1:2);
                        else
                            marker(3:4) = line(3:4);
                        end
                    end
                end
            end
        end
        
    % VERTICAL CASE
    elseif strcmp(surrounded_type, 'vertical')
        vert_y_min = min(vert_line(2), vert_line(4));
        vert_y_max = max(vert_line(2), vert_line(4));
        vert_x = mean([vert_line(1), vert_line(3)]);
        
        for i = 1:size(filtered_lines, 1)
            line = filtered_lines(i, :);
            line_x = mean([line(1), line(3)]);
            
            % Must be at approximately same x position
            if abs(line_x - vert_x) > tolerance
                continue;
            end
            
            line_y_min = min(line(2), line(4));
            line_y_max = max(line(2), line(4));
            
            % Top candidate - strictly above (no overlap)
            if line_y_max <= vert_y_min
                dist = vert_y_min - line_y_max;
                if dist <= gap_max
                    top_candidates = [top_candidates; line, dist];
                    if dist < min_top_dist
                        min_top_dist = dist;
                        if line(2) > line(4)
                            marker(1:2) = line(1:2);
                        else
                            marker(1:2) = line(3:4);
                        end
                    end
                end
            end
            
            % Bottom candidate - strictly below (no overlap)
            if line_y_min >= vert_y_max
                dist = line_y_min - vert_y_max;
                if dist <= gap_max
                    bottom_candidates = [bottom_candidates; line, dist];
                    if dist < min_bottom_dist
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
    
    % Debug output if no complete marker found
    if any(marker(1:2) == 0) || any(marker(3:4) == 0)
        fprintf('DEBUG: Incomplete window marker detected\n');
        fprintf('       Type: %s, Tolerance: %.1f, Gap_max: %.1f\n', ...
                surrounded_type, tolerance, gap_max);
        if strcmp(surrounded_type, 'horizontal')
            fprintf('       Window: x=[%.1f, %.1f], y=%.1f\n', hor_x_min, hor_x_max, hor_y);
            fprintf('       Left candidates: %d, Right candidates: %d\n', ...
                    size(left_candidates,1), size(right_candidates,1));
            if ~isempty(left_candidates)
                fprintf('       Closest left dist: %.1f\n', min(left_candidates(:,end)));
            end
            if ~isempty(right_candidates)
                fprintf('       Closest right dist: %.1f\n', min(right_candidates(:,end)));
            end
        else
            fprintf('       Window: y=[%.1f, %.1f], x=%.1f\n', vert_y_min, vert_y_max, vert_x);
            fprintf('       Top candidates: %d, Bottom candidates: %d\n', ...
                    size(top_candidates,1), size(bottom_candidates,1));
            if ~isempty(top_candidates)
                fprintf('       Closest top dist: %.1f\n', min(top_candidates(:,end)));
            end
            if ~isempty(bottom_candidates)
                fprintf('       Closest bottom dist: %.1f\n', min(bottom_candidates(:,end)));
            end
        end
    end
    
    window_marker = marker;
end