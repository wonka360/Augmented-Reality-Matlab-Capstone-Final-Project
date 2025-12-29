function [segments, n_out, reg_img] = line_segment_detection(img, scale, ...
    sigma_scale, quant, ang_th, log_eps, density_th, n_bins)
    
    % Constants
    NOTDEF = -1024.0;
    NOTUSED = 0;
    USED = 1;
    
    [Y, X] = size(img);
    
    % Angle tolerance
    prec = pi * ang_th / 180.0;
    p = ang_th / 180.0;
    rho = quant / sin(prec);
    
    % Scale image if necessary
    if scale ~= 1.0
        scaled_image = gaussian_sampler(img, scale, sigma_scale);
        [angles, modgrad, list_p] = ll_angle(scaled_image, rho, n_bins);
    else
        [angles, modgrad, list_p] = ll_angle(img, rho, n_bins);
    end
    
    [ysize, xsize] = size(angles);
    
    % Number of tests
    logNT = 5.0 * (log10(xsize) + log10(ysize)) / 2.0 + log10(11.0);
    min_reg_size = floor(-logNT / log10(p));
    
    % Initialize structures
    used = zeros(ysize, xsize, 'uint8');
    reg_img = zeros(ysize, xsize, 'int32');
    segments = [];
    ls_count = 0;
    
    % Search for line segments
    for i = 1:size(list_p, 1)
        x = list_p(i, 1);
        y = list_p(i, 2);
        
        if used(y, x) == NOTUSED && angles(y, x) ~= NOTDEF
            % Grow region
            [reg, reg_size, reg_angle] = region_grow(x, y, angles, ...
                used, prec, NOTUSED, USED);
            
            % Reject small regions
            if reg_size < min_reg_size
                continue;
            end
            
            % Construct rectangle
            rec = region2rect(reg, reg_size, modgrad, reg_angle, prec, p);
            
            % Refine region
            [reg, reg_size, rec, valid] = refine(reg, reg_size, modgrad, ...
                reg_angle, prec, p, rec, used, angles, density_th, ...
                NOTUSED, USED, NOTDEF);
            
            if ~valid
                continue;
            end
            
            % Improve rectangle
            [rec, log_nfa] = rect_improve(rec, angles, logNT, log_eps);
            
            if log_nfa <= log_eps
                continue;
            end
            
            % Line segment found
            ls_count = ls_count + 1;
            
            % Add offset for gradient computation
            rec.x1 = rec.x1 + 0.5;
            rec.y1 = rec.y1 + 0.5;
            rec.x2 = rec.x2 + 0.5;
            rec.y2 = rec.y2 + 0.5;
            
            % Scale back if subsampling was used
            if scale ~= 1.0
                rec.x1 = rec.x1 / scale;
                rec.y1 = rec.y1 / scale;
                rec.x2 = rec.x2 / scale;
                rec.y2 = rec.y2 / scale;
                rec.width = rec.width / scale;
            end
            
            % Add to output
            segments = [segments; rec.x1, rec.y1, rec.x2, rec.y2, ...
                rec.width, rec.p, log_nfa];
            
            % Mark region in output image
            for j = 1:reg_size
                reg_img(reg(j, 2), reg(j, 1)) = ls_count;
            end
        end
    end
    
    n_out = ls_count;
end