function angle = get_orientation(line)
    dx = abs(line(3) - line(1));
    dy = abs(line(4) - line(2));
    angle = atan2d(dy, dx);
end