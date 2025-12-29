function [rec, log_nfa] = rect_improve(rec, angles, logNT, log_eps)
    log_nfa = rect_nfa(rec, angles, logNT);
    
    if log_nfa > log_eps
        return;
    end
    
    delta = 0.5;
    delta_2 = delta / 2.0;
    
    % Try finer precisions
    r = rec;
    for n = 1:5
        r.p = r.p / 2.0;
        r.prec = r.p * pi;
        log_nfa_new = rect_nfa(r, angles, logNT);
        if log_nfa_new > log_nfa
            log_nfa = log_nfa_new;
            rec = r;
        end
    end
    
    if log_nfa > log_eps
        return;
    end
    
    % Try reducing width
    r = rec;
    for n = 1:5
        if r.width - delta >= 0.5
            r.width = r.width - delta;
            log_nfa_new = rect_nfa(r, angles, logNT);
            if log_nfa_new > log_nfa
                rec = r;
                log_nfa = log_nfa_new;
            end
        end
    end
end