function rec = region2rect(reg, reg_size, modgrad, reg_angle, prec, p)
    % Compute center
    sum_val = 0;
    x = 0;
    y = 0;
    
    for i = 1:reg_size
        weight = modgrad(reg(i,2), reg(i,1));
        x = x + reg(i,1) * weight;
        y = y + reg(i,2) * weight;
        sum_val = sum_val + weight;
    end
    
    x = x / sum_val;
    y = y / sum_val;
    
    % Compute theta
    theta = get_theta(reg, reg_size, x, y, modgrad, reg_angle, prec);
    
    % Compute length and width
    dx = cos(theta);
    dy = sin(theta);
    
    l_min = 0;
    l_max = 0;
    w_min = 0;
    w_max = 0;
    
    for i = 1:reg_size
        l = (reg(i,1) - x) * dx + (reg(i,2) - y) * dy;
        w = -(reg(i,1) - x) * dy + (reg(i,2) - y) * dx;
        
        l_max = max(l_max, l);
        l_min = min(l_min, l);
        w_max = max(w_max, w);
        w_min = min(w_min, w);
    end
    
    rec.x1 = x + l_min * dx;
    rec.y1 = y + l_min * dy;
    rec.x2 = x + l_max * dx;
    rec.y2 = y + l_max * dy;
    rec.width = max(w_max - w_min, 1.0);
    rec.x = x;
    rec.y = y;
    rec.theta = theta;
    rec.dx = dx;
    rec.dy = dy;
    rec.prec = prec;
    rec.p = p;
end