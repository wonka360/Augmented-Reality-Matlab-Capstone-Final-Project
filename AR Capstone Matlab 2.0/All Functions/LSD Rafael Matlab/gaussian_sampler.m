function scaled = gaussian_sampler(img, scale, sigma_scale)
    [Y, X] = size(img);
    N = ceil(X * scale);
    M = ceil(Y * scale);
    
    sigma = sigma_scale / min(scale, 1.0);
    
    % Kernel size
    prec = 3.0;
    h = ceil(sigma * sqrt(2.0 * prec * log(10.0)));
    n = 1 + 2 * h;
    
    % Create Gaussian kernel
    kernel = zeros(1, n);
    for i = 1:n
        val = (i - 1 - h) / sigma;
        kernel(i) = exp(-0.5 * val * val);
    end
    kernel = kernel / sum(kernel);
    
    % First subsampling: x axis
    aux = zeros(M, N);
    for x = 1:N
        xx = (x - 1) / scale;
        xc = floor(xx + 0.5) + 1;
        
        offset = xx - (xc - 1);
        temp_kernel = zeros(1, n);
        for i = 1:n
            val = (i - 1 - h + offset) / sigma;
            temp_kernel(i) = exp(-0.5 * val * val);
        end
        temp_kernel = temp_kernel / sum(temp_kernel);
        
        for y = 1:M
            sum_val = 0;
            for i = 1:n
                j = xc - h + i - 2;
                j = mod(j, 2 * X);
                if j < 0
                    j = j + 2 * X;
                end
                if j >= X
                    j = 2 * X - 1 - j;
                end
                j = j + 1;
                j = max(1, min(X, j));
                
                sum_val = sum_val + img(y, j) * temp_kernel(i);
            end
            aux(y, x) = sum_val;
        end
    end
    
    % Second subsampling: y axis
    scaled = zeros(M, N);
    for y = 1:M
        yy = (y - 1) / scale;
        yc = floor(yy + 0.5) + 1;
        
        offset = yy - (yc - 1);
        temp_kernel = zeros(1, n);
        for i = 1:n
            val = (i - 1 - h + offset) / sigma;
            temp_kernel(i) = exp(-0.5 * val * val);
        end
        temp_kernel = temp_kernel / sum(temp_kernel);
        
        for x = 1:N
            sum_val = 0;
            for i = 1:n
                j = yc - h + i - 2;
                j = mod(j, 2 * M);
                if j < 0
                    j = j + 2 * M;
                end
                if j >= M
                    j = 2 * M - 1 - j;
                end
                j = j + 1;
                j = max(1, min(M, j));
                
                sum_val = sum_val + aux(j, x) * temp_kernel(i);
            end
            scaled(y, x) = sum_val;
        end
    end
end