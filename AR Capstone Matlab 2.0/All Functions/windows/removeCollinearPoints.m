function approx_clean = removeCollinearPoints(approx, min_angle_threshold)
    if nargin < 2
        min_angle_threshold = 30;
    end
    
    n = size(approx, 1);
    keep = true(n, 1);
    
    for i = 1:n
        p1 = approx(i, :);
        p2 = approx(mod(i, n) + 1, :);
        p3 = approx(mod(i+1, n) + 1, :);
        
        v1 = p1 - p2;
        v2 = p3 - p2;
        
        if norm(v1) > 0 && norm(v2) > 0
            cos_angle = dot(v1, v2) / (norm(v1) * norm(v2));
            angle = acosd(cos_angle);
            
            if angle < min_angle_threshold || angle > (180 - min_angle_threshold)
                keep(mod(i, n) + 1) = false;
            end
        end
    end
    
    approx_clean = approx(keep, :);
end