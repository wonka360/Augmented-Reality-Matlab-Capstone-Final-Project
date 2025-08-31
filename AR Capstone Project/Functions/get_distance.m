function dist = get_distance(a, b)
    d1 = point_line_distance(a(1:2), b);
    d2 = point_line_distance(a(3:4), b);
    d3 = point_line_distance(b(1:2), a);
    d4 = point_line_distance(b(3:4), a);
    dist = min([d1 d2 d3 d4]);
end
