function d = point_line_distance(p, l)
    x0 = p(1); y0 = p(2);
    x1 = l(1); y1 = l(2);
    x2 = l(3); y2 = l(4);

    A = x0 - x1;
    B = y0 - y1;
    C = x2 - x1;
    D = y2 - y1;

    dotp = A*C + B*D;
    len_sq = C*C + D*D;
    param = dotp / len_sq;

    if param < 0
        xx = x1; yy = y1;
    elseif param > 1
        xx = x2; yy = y2;
    else
        xx = x1 + param * C;
        yy = y1 + param * D;
    end

    dx = x0 - xx;
    dy = y0 - yy;
    d = sqrt(dx*dx + dy*dy);
end
