function [reg, reg_size, rec, valid] = refine(reg, reg_size, modgrad, ...
    reg_angle, prec, p, rec, used, angles, density_th, NOTUSED, USED, NOTDEF)
    
    density = reg_size / (sqrt((rec.x2-rec.x1)^2 + (rec.y2-rec.y1)^2) * rec.width);
    
    if density >= density_th
        valid = true;
        return;
    end
    
    % Compute new tolerance
    xc = reg(1, 1);
    yc = reg(1, 2);
    ang_c = angles(yc, xc);
    
    sum_val = 0;
    s_sum = 0;
    n = 0;
    
    for i = 1:reg_size
        used(reg(i,2), reg(i,1)) = NOTUSED;
        if sqrt((reg(i,1) - xc)^2 + (reg(i,2) - yc)^2) < rec.width
            angle = angles(reg(i,2), reg(i,1));
            ang_d = angle - ang_c;
            while ang_d <= -pi
                ang_d = ang_d + 2*pi;
            end
            while ang_d > pi
                ang_d = ang_d - 2*pi;
            end
            sum_val = sum_val + ang_d;
            s_sum = s_sum + ang_d^2;
            n = n + 1;
        end
    end
    
    mean_angle = sum_val / n;
    tau = 2 * sqrt((s_sum - 2 * mean_angle * sum_val) / n + mean_angle^2);
    
    [reg, reg_size, reg_angle] = region_grow(reg(1,1), reg(1,2), angles, ...
        used, tau, NOTUSED, USED);
    
    if reg_size < 2
        valid = false;
        return;
    end
    
    rec = region2rect(reg, reg_size, modgrad, reg_angle, prec, p);
    density = reg_size / (sqrt((rec.x2-rec.x1)^2 + (rec.y2-rec.y1)^2) * rec.width);
    
    if density < density_th
        [reg, reg_size, rec, valid] = reduce_region_radius(reg, reg_size, ...
            modgrad, reg_angle, prec, p, rec, used, angles, density_th, NOTUSED);
    else
        valid = true;
    end
end