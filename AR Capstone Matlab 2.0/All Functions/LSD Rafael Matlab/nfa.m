function log_nfa_val = nfa(n, k, p, logNT)
    if n == 0 || k == 0
        log_nfa_val = -logNT;
        return;
    end
    if n == k
        log_nfa_val = -logNT - n * log10(p);
        return;
    end
    
    p_term = p / (1 - p);
    
    log1term = gammaln(n + 1) - gammaln(k + 1) - gammaln(n - k + 1) + ...
               k * log(p) + (n - k) * log(1 - p);
    
    term = exp(log1term);
    
    if term == 0
        if k > n * p
            log_nfa_val = -log1term / log(10) - logNT;
        else
            log_nfa_val = -logNT;
        end
        return;
    end
    
    bin_tail = term;
    for i = k+1:n
        bin_term = (n - i + 1) / i;
        mult_term = bin_term * p_term;
        term = term * mult_term;
        bin_tail = bin_tail + term;
    end
    
    log_nfa_val = -log10(bin_tail) - logNT;
end