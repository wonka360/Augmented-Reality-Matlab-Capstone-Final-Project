function triangle = reduceToThreeVertices(points)
    while size(points, 1) > 3
        n = size(points, 1);
        max_collinearity = -inf;
        remove_idx = 1;
        
        for i = 1:n
            p1 = points(i, :);
            p2 = points(mod(i, n) + 1, :);
            p3 = points(mod(i+1, n) + 1, :);
            
            v1 = p1 - p2;
            v2 = p3 - p2;
            
            if norm(v1) > 0 && norm(v2) > 0
                cos_angle = abs(dot(v1, v2) / (norm(v1) * norm(v2)));
                if cos_angle > max_collinearity
                    max_collinearity = cos_angle;
                    remove_idx = mod(i, n) + 1;
                end
            end
        end
        
        keep_idx = setdiff(1:n, remove_idx);
        points = points(keep_idx, :);
    end
    triangle = points;
end