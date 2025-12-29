function squares = detectDocument(B, imageSize)
    % Detect squares and rectangles from boundaries
    % B: Binary image generated from CORF detection
    
    squares = {};
    
    rejectionCount = 0;
    rejectionCategories = struct();
    
    for k = 1:length(B)
        cnt = B{k};
        
        % Approximate polygon
        tolerance = 0.08;
        approx = reducepoly(cnt, tolerance);
        
        % STEP 1: Remove duplicate/overlapping vertices
        approx_clean = removeDuplicateVertices(approx, 3.0);
        
        % STEP 2: Remove collinear points
        if size(approx_clean, 1) > 4
            approx_clean = removeCollinearPoints(approx_clean, 30);
        end
        if size(approx_clean, 1) == 4
            approx_clean = sortVertices(approx_clean);
        end
        
        % Check for 4 vertices
        if size(approx_clean, 1) ~= 4
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'WrongVertexCount');
            continue;
        end
        
        % Calculate area
        area = polyarea(approx_clean(:,2), approx_clean(:,1));
        
        if area <= 100
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'AreaTooSmall');
            continue;
        end
        
        % Check convexity
        if ~isConvex(approx_clean)
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'NotConvex');
            continue;
        end
        
        % Calculate dimensions
        rows = approx_clean(:, 1);
        cols = approx_clean(:, 2);
        width = max(cols) - min(cols);
        height = max(rows) - min(rows);
        
        % Calculate minimum width (perpendicular distance between parallel sides)
        min_width = calculateMinWidth(approx_clean);
        
        aspect_ratio = max(width, height) / min(width, height);
        
        % REJECT LINES: Minimum width must be reasonable
        if min_width < 10
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'MinWidthTooSmall');
            continue;
        end
        
        % Aspect ratio check with reasonable limit
        if aspect_ratio >= 10.0
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'AspectRatioTooHigh');
            continue;
        end
        
        % Check all 4 angles
        angles = zeros(4, 1);
        for i = 1:4
            p1 = approx_clean(i, :);
            p2 = approx_clean(mod(i, 4) + 1, :);
            p3 = approx_clean(mod(i+1, 4) + 1, :);
            v1 = p1 - p2;
            v2 = p3 - p2;
            cos_angle = dot(v1, v2) / (norm(v1) * norm(v2));
            angles(i) = acosd(cos_angle);
        end
        
        % Check opposite angles sum
        angle_sum1 = angles(1) + angles(3);
        angle_sum2 = angles(2) + angles(4);
        
        % Total angle sum
        total_angle = sum(angles);
        
        % Parallelogram validity checks
        if abs(angle_sum1 - 180) > 30 || abs(angle_sum2 - 180) > 30
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'InvalidParallelogram');
            continue;
        end
        
        if abs(total_angle - 360) > 20
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'InvalidAngleSum');
            continue;
        end
        
        % Determine if square or rectangle
        if aspect_ratio < 1.3
            shape_type = 'SQUARE';
        else
            shape_type = 'RECTANGLE';
        end
        
        squares{end+1} = approx_clean;
    end
end

function categories = incrementCategory(categories, categoryName)
    % Helper function to increment category count
    if isfield(categories, categoryName)
        categories.(categoryName) = categories.(categoryName) + 1;
    else
        categories.(categoryName) = 1;
    end
end

function sortedPoly = sortVertices(poly)
    % Sort 4 vertices in clockwise or counter-clockwise order
    if size(poly, 1) ~= 4
        sortedPoly = poly;
        return;
    end
    
    centroid = mean(poly, 1);
    
    angles = zeros(4, 1);
    for i = 1:4
        dx = poly(i, 2) - centroid(2);
        dy = poly(i, 1) - centroid(1);
        angles(i) = atan2(dy, dx);
    end
    
    [~, idx] = sort(angles);
    sortedPoly = poly(idx, :);
end
