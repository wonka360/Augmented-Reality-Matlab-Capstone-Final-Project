function convex = isConvex(points)
    n = size(points, 1);
    if n < 3
        convex = false;
        return;
    end
    
    sign = 0;
    for i = 1:n
        p1 = points(i, :);
        p2 = points(mod(i, n) + 1, :);
        p3 = points(mod(i+1, n) + 1, :);
        
        v1 = p2 - p1;
        v2 = p3 - p2;
        crossProd = v1(1)*v2(2) - v1(2)*v2(1);
        
        if i == 1
            sign = crossProd > 0;
        else
            if (crossProd > 0) ~= sign
                convex = false;
                return;
            end
        end
    end
    convex = true;
end