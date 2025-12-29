function filtered_lines = filterTriangleLines(door_lines, angle_tolerance, length_ratio_thresh)
    % filterTriangleLines - Identify and keep only the 3 main triangle edges
    %
    % Inputs:
    %   door_lines - Nx4 matrix where each row is [x1, y1, x2, y2]
    %   angle_tolerance - Tolerance in degrees for grouping parallel lines (default: 10)
    %   length_ratio_thresh - Min length ratio to longest line in group (default: 0.5)
    %
    % Output:
    %   filtered_lines - 3x4 matrix containing the 3 main triangle edges
    
    if nargin < 2
        angle_tolerance = 10;  % degrees
    end
    if nargin < 3
        length_ratio_thresh = 0.5;  % keep lines that are at least 50% of longest in group
    end
    
    % Reshape if needed
    if size(door_lines, 2) == 2
        door_lines = reshape(door_lines', 4, [])';
    end
    
    num_lines = size(door_lines, 1);
    
    % Calculate angle and length for each line
    angles = zeros(num_lines, 1);
    lengths = zeros(num_lines, 1);
    midpoints = zeros(num_lines, 2);
    
    for i = 1:num_lines
        x1 = door_lines(i, 1);
        y1 = door_lines(i, 2);
        x2 = door_lines(i, 3);
        y2 = door_lines(i, 4);
        
        % Angle in degrees (0-180 range)
        angles(i) = mod(atan2d(y2 - y1, x2 - x1), 180);
        
        % Length of line segment
        lengths(i) = sqrt((x2 - x1)^2 + (y2 - y1)^2);
        
        % Midpoint
        midpoints(i, :) = [(x1 + x2)/2, (y1 + y2)/2];
    end
    
    % Group lines by angle similarity
    groups = cell(0);
    assigned = false(num_lines, 1);
    
    for i = 1:num_lines
        if assigned(i)
            continue;
        end
        
        % Find all lines with similar angles
        angle_diff = abs(angles - angles(i));
        % Handle wrap-around (0 and 180 are the same)
        angle_diff = min(angle_diff, 180 - angle_diff);
        
        similar_angles = find(angle_diff < angle_tolerance);
        
        % Within similar angles, keep only lines that are reasonably long
        % and potentially part of the same edge
        max_length_in_group = max(lengths(similar_angles));
        valid_lines = similar_angles(lengths(similar_angles) >= length_ratio_thresh * max_length_in_group);
        
        if ~isempty(valid_lines)
            groups{end+1} = valid_lines;
            assigned(valid_lines) = true;
        end
    end
    
    % For each group, select the longest line (most likely the true edge)
    if isempty(groups)
        filtered_lines = [];
        warning('No line groups found');
        return;
    end
    
    representative_lines = zeros(length(groups), 4);
    group_lengths = zeros(length(groups), 1);
    
    for i = 1:length(groups)
        group_idx = groups{i};
        group_line_lengths = lengths(group_idx);
        
        % Take the longest line in the group as the true edge
        [max_len, max_idx] = max(group_line_lengths);
        representative_lines(i, :) = door_lines(group_idx(max_idx), :);
        group_lengths(i) = max_len;
    end
    
    % Select the 3 longest groups (main triangle edges)
    % A triangle should have exactly 3 edges with different orientations
    if size(representative_lines, 1) < 3
        warning('Found only %d edge groups. Expected 3 for a triangle.', size(representative_lines, 1));
        filtered_lines = representative_lines;
    elseif size(representative_lines, 1) == 3
        filtered_lines = representative_lines;
    else
        % More than 3 groups - need to select the best 3
        % Strategy: Pick 3 groups with most different angles and longest lengths
        filtered_lines = selectBestThreeEdges(representative_lines, angles, groups, lengths);
    end
end

function best_three = selectBestThreeEdges(representative_lines, all_angles, groups, all_lengths)
    % Select 3 edges that are most likely to form a triangle
    % Criteria: Different orientations + longest lines
    
    num_groups = size(representative_lines, 1);
    
    % Calculate angles for representative lines
    rep_angles = zeros(num_groups, 1);
    rep_lengths = zeros(num_groups, 1);
    
    for i = 1:num_groups
        line = representative_lines(i, :);
        rep_angles(i) = mod(atan2d(line(4) - line(2), line(3) - line(1)), 180);
        rep_lengths(i) = sqrt((line(3) - line(1))^2 + (line(4) - line(2))^2);
    end
    
    % Find combination of 3 lines with maximum angular diversity and length
    best_score = -inf;
    best_combo = [1, 2, 3];
    
    % Try all combinations of 3 from available groups
    for i = 1:num_groups-2
        for j = i+1:num_groups-1
            for k = j+1:num_groups
                % Calculate angular diversity
                angles_combo = [rep_angles(i), rep_angles(j), rep_angles(k)];
                angle_diffs = [
                    min(abs(angles_combo(1) - angles_combo(2)), 180 - abs(angles_combo(1) - angles_combo(2)));
                    min(abs(angles_combo(2) - angles_combo(3)), 180 - abs(angles_combo(2) - angles_combo(3)));
                    min(abs(angles_combo(1) - angles_combo(3)), 180 - abs(angles_combo(1) - angles_combo(3)))
                ];
                
                % Score: favor different angles and longer lines
                angle_diversity = min(angle_diffs);  % Minimum separation between any two angles
                total_length = rep_lengths(i) + rep_lengths(j) + rep_lengths(k);
                
                % Combined score (weight both factors)
                score = angle_diversity * total_length;
                
                if score > best_score
                    best_score = score;
                    best_combo = [i, j, k];
                end
            end
        end
    end
    
    best_three = representative_lines(best_combo, :);
end

% Example usage:
% door_lines = [1.0970e+03, 0.5649e+03, 1.2401e+03, 0.6227e+03;
%               1.1419e+03, 0.5811e+03, 1.1679e+03, 0.5921e+03;
%               1.0951e+03, 0.6234e+03, 1.2321e+03, 0.6225e+03;
%               1.0973e+03, 0.5666e+03, 1.0941e+03, 0.6226e+03;
%               1.0955e+03, 0.6396e+03, 1.0953e+03, 0.6716e+03;
%               1.0983e+03, 0.5145e+03, 1.0979e+03, 0.5496e+03];
%
% filtered = filterTriangleLines(door_lines);
% disp('Filtered triangle lines:');
% disp(filtered);