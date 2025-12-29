function approx_clean = removeDuplicateVertices(approx, distance_threshold)
    if nargin < 2
        distance_threshold = 3.0;
    end
    
    n = size(approx, 1);
    keep = true(n, 1);
    
    for i = 1:n
        p1 = approx(i, :);
        p2 = approx(mod(i, n) + 1, :);
        
        dist = norm(p1 - p2);
        
        if dist < distance_threshold
            keep(mod(i, n) + 1) = false;
        end
    end
    
    approx_clean = approx(keep, :);
end