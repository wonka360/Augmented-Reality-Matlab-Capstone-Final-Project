function theta = get_theta(reg, reg_size, x, y, modgrad, reg_angle, prec)
    Ixx = 0;
    Iyy = 0;
    Ixy = 0;
    
    for i = 1:reg_size
        weight = modgrad(reg(i,2), reg(i,1));
        Ixx = Ixx + (reg(i,2) - y)^2 * weight;
        Iyy = Iyy + (reg(i,1) - x)^2 * weight;
        Ixy = Ixy - (reg(i,1) - x) * (reg(i,2) - y) * weight;
    end
    
    lambda = 0.5 * (Ixx + Iyy - sqrt((Ixx - Iyy)^2 + 4*Ixy^2));
    
    if abs(Ixx) > abs(Iyy)
        theta = atan2(lambda - Ixx, Ixy);
    else
        theta = atan2(Ixy, lambda - Iyy);
    end
    
    if angle_diff(theta, reg_angle) > prec
        theta = theta + pi;
    end
end