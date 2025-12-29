function aligned = isaligned(x, y, angles, theta, prec)
    NOTDEF = -1024.0;
    
    a = angles(y, x);
    
    if a == NOTDEF
        aligned = false;
        return;
    end
    
    theta_diff = theta - a;
    if theta_diff < 0
        theta_diff = -theta_diff;
    end
    
    if theta_diff > 3*pi/2
        theta_diff = theta_diff - 2*pi;
        if theta_diff < 0
            theta_diff = -theta_diff;
        end
    end
    
    aligned = theta_diff <= prec;
end