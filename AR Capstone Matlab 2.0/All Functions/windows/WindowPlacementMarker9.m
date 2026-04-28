function window_marker = WindowPlacementMarker9(window_lines, filtered_lines)
    
    
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
    
    % STEP 2: Determine which orientation has the main window lines
    
    if ~isempty(horizontal_lines)
        [sorted_h_lengths, h_idx] = sort(horizontal_lengths, 'descend');
        num_h_to_avg = min(3, length(sorted_h_lengths));
        top3_h_avg = mean(sorted_h_lengths(1:num_h_to_avg));
    else
        top3_h_avg = 0;
    end
    
    if ~isempty(vertical_lines)
        [sorted_v_lengths, v_idx] = sort(vertical_lengths, 'descend');
        num_v_to_avg = min(3, length(sorted_v_lengths));
        top3_v_avg = mean(sorted_v_lengths(1:num_v_to_avg));
    else
        top3_v_avg = 0;
    end
    
    % Choose orientation based purely on which has longer top lines
    if top3_h_avg == 0 && top3_v_avg == 0
        warning('No lines to determine window type.');
        window_marker = marker;
        return;
    end
    
    use_horizontal = top3_h_avg > top3_v_avg;
    
    if use_horizontal
        surrounded_type = 'horizontal';
        num_h = size(horizontal_lines, 1);
        reference_lines = horizontal_lines(h_idx(1:min(3, num_h)), :);
    else
        surrounded_type = 'vertical';
        num_v = size(vertical_lines, 1);
        reference_lines = vertical_lines(v_idx(1:min(3, num_v)), :);
    end
    
    % STEP 3: Find the MIDDLE line among the reference lines (Kept for debug output tracking)
    if strcmp(surrounded_type, 'horizontal')
        y_centers = mean(reference_lines(:, [2,4]), 2);
        [sorted_y, idx] = sort(y_centers);
        
        if length(idx) >= 3
            middle_y = (sorted_y(1) + sorted_y(end)) / 2;
            [~, mid_idx] = min(abs(sorted_y - middle_y));
            hor_line = reference_lines(idx(mid_idx), :);
        elseif length(idx) == 2
            hor_line = reference_lines(idx(1), :);
        else
            hor_line = reference_lines(1, :);
        end
        vert_line = [];
        
    else % vertical
        x_centers = mean(reference_lines(:, [1,3]), 2);
        [sorted_x, idx] = sort(x_centers);
        
        if length(idx) >= 3
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
        hor_y = mean([hor_line(2), hor_line(4)]);
        hor_x_min = min(min(reference_lines(:,1)), min(reference_lines(:,3)));
        hor_x_max = max(max(reference_lines(:,1)), max(reference_lines(:,3)));
        hor_y_lo = min(min(reference_lines(:,2)), min(reference_lines(:,4))) - tolerance;
        hor_y_hi = max(max(reference_lines(:,2)), max(reference_lines(:,4))) + tolerance;
        
        % Extract individual left/right edges for precision overlap distance checking
        ref_lefts = min(reference_lines(:, [1, 3]), [], 2);
        ref_rights = max(reference_lines(:, [1, 3]), [], 2);
        
        for i = 1:size(filtered_lines, 1)
            line = filtered_lines(i, :);
            line_y = mean([line(2), line(4)]);
            
            % Accept wall lines anywhere within the window's full y-band
            if line_y < hor_y_lo || line_y > hor_y_hi
                continue;
            end
            
            line_x_min = min(line(1), line(3));
            line_x_max = max(line(1), line(3));
            
            % Left candidate: Must start primarily to the left, but right end can overlap slightly
            if line_x_min < hor_x_min + tolerance
                dist = min(abs(ref_lefts - line_x_max)); % Distance to closest window left-edge
                if dist <= gap_max && dist < min_left_dist
                    min_left_dist = dist;
                    if line(1) > line(3)
                        marker(1:2) = line(1:2);
                    else
                        marker(1:2) = line(3:4);
                    end
                end
            end
            
            % Right candidate: Must end primarily to the right, but left end can overlap slightly
            if line_x_max > hor_x_max - tolerance
                dist = min(abs(ref_rights - line_x_min)); % Distance to closest window right-edge
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
        vert_x = mean([vert_line(1), vert_line(3)]);
        vert_y_min = min(min(reference_lines(:,2)), min(reference_lines(:,4)));
        vert_y_max = max(max(reference_lines(:,2)), max(reference_lines(:,4)));
        vert_x_lo = min(min(reference_lines(:,1)), min(reference_lines(:,3))) - tolerance;
        vert_x_hi = max(max(reference_lines(:,1)), max(reference_lines(:,3))) + tolerance;
        
        % Extract individual top/bottom edges for precision overlap distance checking
        ref_tops = min(reference_lines(:, [2, 4]), [], 2);
        ref_bottoms = max(reference_lines(:, [2, 4]), [], 2);
        
        for i = 1:size(filtered_lines, 1)
            line = filtered_lines(i, :);
            line_x = mean([line(1), line(3)]);
            
            % Accept wall lines anywhere within the window's full x-band
            if line_x < vert_x_lo || line_x > vert_x_hi
                continue;
            end
            
            line_y_min = min(line(2), line(4));
            line_y_max = max(line(2), line(4));
            
            % Top candidate: Must sit primarily above, but bottom end can overlap slightly
            if line_y_min < vert_y_min + tolerance
                dist = min(abs(ref_tops - line_y_max)); % Distance to closest window top-edge
                if dist <= gap_max && dist < min_top_dist
                    min_top_dist = dist;
                    if line(2) > line(4)
                        marker(1:2) = line(1:2);
                    else
                        marker(1:2) = line(3:4);
                    end
                end
            end
            
            % Bottom candidate: Must sit primarily below, but top end can overlap slightly
            if line_y_max > vert_y_max - tolerance
                dist = min(abs(ref_bottoms - line_y_min)); % Distance to closest window bottom-edge
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
            fprintf('       Window x range (union): [%.1f, %.1f]\n', hor_x_min, hor_x_max);
            fprintf('       Position filter y band: [%.1f, %.1f]\n', hor_y_lo, hor_y_hi);
        else
            fprintf('       Reference line: [%.1f,%.1f,%.1f,%.1f] at x=%.1f\n', ...
                    vert_line(1), vert_line(2), vert_line(3), vert_line(4), vert_x);
            fprintf('       Window y range (union): [%.1f, %.1f]\n', vert_y_min, vert_y_max);
            fprintf('       Position filter x band: [%.1f, %.1f]\n', vert_x_lo, vert_x_hi);
        end
    end
    
    window_marker = marker;
end