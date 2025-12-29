function y = inter_low(x, x1, y1, x2, y2)
    if abs(x1 - x2) < eps
        y = min(y1, y2);
    else
        y = y1 + (x - x1) * (y2 - y1) / (x2 - x1);
    end
end