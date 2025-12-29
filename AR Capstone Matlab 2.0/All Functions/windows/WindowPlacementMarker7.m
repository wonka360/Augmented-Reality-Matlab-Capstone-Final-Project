function window_marker = WindowPlacementMarker7(window_lines, filtered_lines)
    % Version based on proper understanding: 3 long lines + 3 short lines
    % Reference line is the MIDDLE of the 3 LONG lines
    
    marker = zeros(1,4);
    
    % Parameters
    tolerance = 20.0;
    gap_max = 100.0;
    
    if isempty(window_lines)
        warning('No window lines detected');
        return;
    end
    
    % STEP 1: Calculate all line lengths and classify by orientation
    line_lengths = sqrt((window_lines(:,3) - window_lines(:,1)).^2 + ...
                        (window_lines(:,4) - window_lines(:,2)).^2);
    
    vertical_lines = [];
    horizontal_lines = [];
    vertical_lengths = [];
    horizontal_lengths = [];
    
    for i = 1:size(window_lines, 1)
        line = window_lines(i,:);
        dx = abs(line(1) - line(3));
        dy = abs(line(2) - line(4));
        
        if dx < dy % vertical
            vertical_lines = [vertical_lines; line];
            vertical_lengths = [vertical_lengths; line_lengths(i)];
        else % horizontal
            horizontal_lines = [horizontal_lines; line];
            horizontal_lengths = [horizontal_lengths; line_lengths(i)];
        end
    end
    
    % STEP 2: Determine which orientation has the 3 LONG lines
    % The 3 long lines should all be in the same orientation
    
    % Sort each group by length and identify the 3 longest in each
    if size(vertical_lines, 1) >= 3
        [sorted_v_lengths, v_idx] = sort(vertical_lengths, 'descend');
        top3_v_avg = mean(sorted_v_lengths(1:3));
    elseif ~isempty(vertical_lines)
        top3_v_avg = mean(vertical_lengths);
    else
        top3_v_avg = 0;
    end
    
    if size(horizontal_lines, 1) >= 3
        [sorted_h_lengths, h_idx] = sort(horizontal_lengths, 'descend');
        top3_h_avg = mean(sorted_h_lengths(1:3));
    elseif ~isempty(horizontal_lines)
        top3_h_avg = mean(horizontal_lengths);
    else
        top3_h_avg = 0;
    end
    
    % Choose orientation based on which has longer top-3 lines
    if top3_h_avg > top3_v_avg
        surrounded_type = 'horizontal';
        % Use only the 3 longest horizontal lines
        if size(horizontal_lines, 1) >= 3
            reference_lines = horizontal_lines(h_idx(1:3), :);
        else
            reference_lines = horizontal_lines;
        end
    else
        surrounded_type = 'vertical';
        % Use only the 3 longest vertical lines
        if size(vertical_lines, 1) >= 3
            reference_lines = vertical_lines(v_idx(1:3), :);
        else
            reference_lines = vertical_lines;
        end
    end
    
    % STEP 3: Find the MIDDLE line among the reference lines
    % The middle line is the one between the two outer frame lines
    if strcmp(surrounded_type, 'horizontal')
        % For horizontal: sort by y-coordinate to find top and bottom
        y_centers = mean(reference_lines(:, [2,4]), 2);
        [sorted_y, idx] = sort(y_centers);
        
        if length(idx) >= 3
            % Take the outer two lines (top and bottom frame)
            % The reference should be between them
            % Use the line closest to the middle position
            middle_y = (sorted_y(1) + sorted_y(end)) / 2;
            [~, mid_idx] = min(abs(sorted_y - middle_y));
            hor_line = reference_lines(idx(mid_idx), :);
        elseif length(idx) == 2
            % With only 2 lines, use the first one
            hor_line = reference_lines(idx(1), :);
        else
            hor_line = reference_lines(1, :);
        end
        vert_line = [];
        
    else % vertical
        % For vertical: sort by x-coordinate to find left and right
        x_centers = mean(reference_lines(:, [1,3]), 2);
        [sorted_x, idx] = sort(x_centers);
        
        if length(idx) >= 3
            % Take the line closest to middle position
            middle_x = (sorted_x(1) + sorted_x(end)) / 2;
            [~, mid_idx] = min(abs(sorted_x - middle_x));
            vert_line = reference_lines(idx(mid_idx), :);
        elseif length(idx) == 2
            vert_line = reference_lines(idx(1), :);
        else
            vert_line = reference_lines(1, :);
        end
        hor_line = [];
    end
    
    % STEP 4: Find surrounding wall lines
    marker = zeros(1,4);
    min_left_dist = Inf; min_right_dist = Inf;
    min_top_dist = Inf; min_bottom_dist = Inf;
    
    % HORIZONTAL CASE
    if strcmp(surrounded_type, 'horizontal')
        hor_x_min = min(hor_line(1), hor_line(3));
        hor_x_max = max(hor_line(1), hor_line(3));
        hor_y = mean([hor_line(2), hor_line(4)]);
        
        for i = 1:size(filtered_lines, 1)
            line = filtered_lines(i, :);
            line_y = mean([line(2), line(4)]);
            
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
        
    % VERTICAL CASE
    elseif strcmp(surrounded_type, 'vertical')
        vert_y_min = min(vert_line(2), vert_line(4));
        vert_y_max = max(vert_line(2), vert_line(4));
        vert_x = mean([vert_line(1), vert_line(3)]);
        
        for i = 1:size(filtered_lines, 1)
            line = filtered_lines(i, :);
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
    
    % Debug output
    if all(marker == 0) || any(marker(1:2) == 0) || any(marker(3:4) == 0)
        fprintf('DEBUG: Incomplete window marker\n');
        fprintf('       H lines: %d (top3 avg: %.1f), V lines: %d (top3 avg: %.1f)\n', ...
                size(horizontal_lines,1), top3_h_avg, ...
                size(vertical_lines,1), top3_v_avg);
        fprintf('       Chosen type: %s, using %d reference lines\n', ...
                surrounded_type, size(reference_lines, 1));
        if strcmp(surrounded_type, 'horizontal')
            fprintf('       Reference line: [%.1f,%.1f,%.1f,%.1f] at y=%.1f\n', ...
                    hor_line(1), hor_line(2), hor_line(3), hor_line(4), hor_y);
            fprintf('       Window x range: [%.1f, %.1f]\n', hor_x_min, hor_x_max);
        else
            fprintf('       Reference line: [%.1f,%.1f,%.1f,%.1f] at x=%.1f\n', ...
                    vert_line(1), vert_line(2), vert_line(3), vert_line(4), vert_x);
            fprintf('       Window y range: [%.1f, %.1f]\n', vert_y_min, vert_y_max);
        end
    end
    
    window_marker = marker;
end