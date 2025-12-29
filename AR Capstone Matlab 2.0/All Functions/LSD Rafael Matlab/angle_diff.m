function diff = angle_diff(a, b)
    diff = a - b;
    while diff <= -pi
        diff = diff + 2*pi;
    end
    while diff > pi
        diff = diff - 2*pi;
    end
    if diff < 0
        diff = -diff;
    end
end