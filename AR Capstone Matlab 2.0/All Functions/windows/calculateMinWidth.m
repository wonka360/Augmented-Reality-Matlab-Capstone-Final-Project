function min_width = calculateMinWidth(points)
    % Calculate minimum perpendicular distance between opposite sides
    % This helps identify very thin rectangles/lines
    
    if size(points, 1) ~= 4
        min_width = 0;
        return;
    end
    
    % Calculate distances between opposite sides
    % Side 1-2 to point 4
    p1 = points(1, :);
    p2 = points(2, :);
    p3 = points(3, :);
    p4 = points(4, :);
    
    % Distance from point 3 to line 1-2
    dist1 = pointToLineDistance(p3, p1, p2);
    
    % Distance from point 4 to line 2-3
    dist2 = pointToLineDistance(p4, p2, p3);
    
    % Distance from point 1 to line 3-4
    dist3 = pointToLineDistance(p1, p3, p4);
    
    % Distance from point 2 to line 4-1
    dist4 = pointToLineDistance(p2, p4, p1);
    
    % Minimum of perpendicular distances
    min_width = min([dist1, dist2, dist3, dist4]);
end
