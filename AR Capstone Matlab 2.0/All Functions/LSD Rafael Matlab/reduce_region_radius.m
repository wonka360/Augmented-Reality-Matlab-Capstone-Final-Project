function [reg, reg_size, rec, valid] = reduce_region_radius(reg, reg_size, ...
    modgrad, reg_angle, prec, p, rec, used, angles, density_th, NOTUSED)
    
    xc = reg(1, 1);
    yc = reg(1, 2);
    
    rad1 = sqrt((xc - rec.x1)^2 + (yc - rec.y1)^2);
    rad2 = sqrt((xc - rec.x2)^2 + (yc - rec.y2)^2);
    rad = max(rad1, rad2);
    
    density = reg_size / (sqrt((rec.x2-rec.x1)^2 + (rec.y2-rec.y1)^2) * rec.width);
    
    while density < density_th
        rad = rad * 0.75;
        
        i = 1;
        while i <= reg_size
            if sqrt((reg(i,1) - xc)^2 + (reg(i,2) - yc)^2) > rad
                used(reg(i,2), reg(i,1)) = NOTUSED;
                reg(i, :) = reg(reg_size, :);
                reg_size = reg_size - 1;
            else
                i = i + 1;
            end
        end
        
        if reg_size < 2
            valid = false;
            return;
        end
        
        reg = reg(1:reg_size, :);
        rec = region2rect(reg, reg_size, modgrad, reg_angle, prec, p);
        density = reg_size / (sqrt((rec.x2-rec.x1)^2 + (rec.y2-rec.y1)^2) * rec.width);
    end
    
    valid = true;
end