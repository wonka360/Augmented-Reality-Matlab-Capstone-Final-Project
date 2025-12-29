function [xs, ys] = rect_iter(rec)
    % Build corner list
    vx = zeros(1, 4);
    vy = zeros(1, 4);
    
    vx(1) = rec.x1 - rec.dy * rec.width / 2;
    vy(1) = rec.y1 + rec.dx * rec.width / 2;
    vx(2) = rec.x2 - rec.dy * rec.width / 2;
    vy(2) = rec.y2 + rec.dx * rec.width / 2;
    vx(3) = rec.x2 + rec.dy * rec.width / 2;
    vy(3) = rec.y2 - rec.dx * rec.width / 2;
    vx(4) = rec.x1 + rec.dy * rec.width / 2;
    vy(4) = rec.y1 - rec.dx * rec.width / 2;
    
    % Rotate to start with min x
    if rec.x1 < rec.x2 && rec.y1 <= rec.y2
        offset = 0;
    elseif rec.x1 >= rec.x2 && rec.y1 < rec.y2
        offset = 1;
    elseif rec.x1 > rec.x2 && rec.y1 >= rec.y2
        offset = 2;
    else
        offset = 3;
    end
    
    vx_rot = circshift(vx, -offset);
    vy_rot = circshift(vy, -offset);
    
    xs = [];
    ys = [];
    
    x_min = ceil(vx_rot(1));
    x_max = floor(vx_rot(3));
    
    for x = x_min:x_max
        if x < vx_rot(4)
            y_min = inter_low(x, vx_rot(1), vy_rot(1), vx_rot(4), vy_rot(4));
        else
            y_min = inter_low(x, vx_rot(4), vy_rot(4), vx_rot(3), vy_rot(3));
        end
        
        if x < vx_rot(2)
            y_max = inter_hi(x, vx_rot(1), vy_rot(1), vx_rot(2), vy_rot(2));
        else
            y_max = inter_hi(x, vx_rot(2), vy_rot(2), vx_rot(3), vy_rot(3));
        end
        
        for y = ceil(y_min):floor(y_max)
            xs = [xs; x];
            ys = [ys; y];
        end
    end
end