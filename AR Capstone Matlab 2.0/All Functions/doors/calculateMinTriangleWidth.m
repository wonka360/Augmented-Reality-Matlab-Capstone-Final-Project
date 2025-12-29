function min_width = calculateMinTriangleWidth(points)
    if size(points, 1) ~= 3
        min_width = 0;
        return;
    end
    
    p1 = points(1, :);
    p2 = points(2, :);
    p3 = points(3, :);
    
    dist1 = pointToLineDistance(p1, p2, p3);
    dist2 = pointToLineDistance(p2, p3, p1);
    dist3 = pointToLineDistance(p3, p1, p2);
    
    min_width = min([dist1, dist2, dist3]);
end