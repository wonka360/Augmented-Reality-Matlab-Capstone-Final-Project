function [angles, modgrad, list_p] = ll_angle(img, threshold, n_bins)
    NOTDEF = -1024.0;
    [Y, X] = size(img);
    
    angles = ones(Y, X) * NOTDEF;
    modgrad = zeros(Y, X);
    
    max_grad = 0;
    
    % Compute gradient
    for x = 1:X-1
        for y = 1:Y-1
            com1 = img(y+1, x+1) - img(y, x);
            com2 = img(y, x+1) - img(y+1, x);
            
            gx = com1 + com2;
            gy = com1 - com2;
            
            norm = sqrt((gx*gx + gy*gy) / 4.0);
            modgrad(y, x) = norm;
            
            if norm <= threshold
                angles(y, x) = NOTDEF;
            else
                angles(y, x) = atan2(gx, -gy);
                max_grad = max(max_grad, norm);
            end
        end
    end
    
    % Pseudo-ordering by gradient magnitude
    bins = cell(n_bins, 1);
    for x = 1:X-1
        for y = 1:Y-1
            norm = modgrad(y, x);
            if norm > 0
                bin = min(floor(norm * n_bins / max_grad) + 1, n_bins);
                bins{bin} = [bins{bin}; x, y];
            end
        end
    end
    
    % Create ordered list
    list_p = [];
    for i = n_bins:-1:1
        if ~isempty(bins{i})
            list_p = [list_p; bins{i}];
        end
    end
end