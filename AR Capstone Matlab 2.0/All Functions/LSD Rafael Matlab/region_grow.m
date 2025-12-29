function [reg, reg_size, reg_angle] = region_grow(x, y, angles, used, ...
    prec, NOTUSED, USED)
    
    [Y, X] = size(angles);
    reg = [x, y];
    reg_size = 1;
    reg_angle = angles(y, x);
    
    sumdx = cos(reg_angle);
    sumdy = sin(reg_angle);
    used(y, x) = USED;
    
    i = 1;
    while i <= reg_size
        for xx = max(1, reg(i,1)-1):min(X, reg(i,1)+1)
            for yy = max(1, reg(i,2)-1):min(Y, reg(i,2)+1)
                if used(yy, xx) == NOTUSED && ...
                   isaligned(xx, yy, angles, reg_angle, prec)
                    used(yy, xx) = USED;
                    reg = [reg; xx, yy];
                    reg_size = reg_size + 1;
                    
                    sumdx = sumdx + cos(angles(yy, xx));
                    sumdy = sumdy + sin(angles(yy, xx));
                    reg_angle = atan2(sumdy, sumdx);
                end
            end
        end
        i = i + 1;
    end
end