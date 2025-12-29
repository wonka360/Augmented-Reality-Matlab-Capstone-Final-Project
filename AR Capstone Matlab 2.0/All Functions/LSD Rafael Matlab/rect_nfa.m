function log_nfa = rect_nfa(rec, angles, logNT)
    NOTDEF = -1024.0;
    pts = 0;
    alg = 0;
    
    [ri_x, ri_y] = rect_iter(rec);
    
    [Y, X] = size(angles);
    for i = 1:length(ri_x)
        x = ri_x(i);
        y = ri_y(i);
        if x >= 1 && y >= 1 && x <= X && y <= Y
            pts = pts + 1;
            if isaligned(x, y, angles, rec.theta, rec.prec)
                alg = alg + 1;
            end
        end
    end
    
    log_nfa = nfa(pts, alg, rec.p, logNT);
end