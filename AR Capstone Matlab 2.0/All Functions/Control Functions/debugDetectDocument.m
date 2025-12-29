
function squares = debugDetectDocument(B, imageSize)
    % Detect squares and rectangles from boundaries with debug logging
    % B: Binary image generated from CORF detection
    
    squares = {};
    
    fprintf('\n=== SQUARE DETECTION DEBUG LOG ===\n');
    fprintf('Total contours to process: %d\n\n', length(B));
    
    rejectionCount = 0;
    rejectionCategories = struct();
    
    for k = 1:length(B)
        cnt = B{k};
        
        fprintf('--- Contour %d ---\n', k);
        fprintf('  Initial points: %d\n', size(cnt, 1));
        
        % Approximate polygon
        tolerance = 0.08;
        approx = reducepoly(cnt, tolerance);
        fprintf('  After reducepoly: %d points\n', size(approx, 1));
        
        % STEP 1: Remove duplicate/overlapping vertices
        approx_clean = removeDuplicateVertices(approx, 3.0);
        fprintf('  After removing duplicates: %d points\n', size(approx_clean, 1));
        
        % STEP 2: Remove collinear points
        if size(approx_clean, 1) > 4
            approx_clean = removeCollinearPoints(approx_clean, 30);
        end
        fprintf('  After removing collinear: %d points\n', size(approx_clean, 1));
        if size(approx_clean, 1) == 4
            approx_clean = sortVertices(approx_clean);
        end
        
        % Check for 4 vertices
        if size(approx_clean, 1) ~= 4
            fprintf('  ✗ REJECTED: Not 4 vertices (has %d)\n\n', size(approx_clean, 1));
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'WrongVertexCount');
            continue;
        end
        
        % Calculate area
        area = polyarea(approx_clean(:,2), approx_clean(:,1));
        fprintf('  Area: %.2f\n', area);
        
        if area <= 100
            fprintf('  ✗ REJECTED: Area too small (%.2f <= 100)\n\n', area);
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'AreaTooSmall');
            continue;
        end
        
        % Check convexity
        if ~isConvex(approx_clean)
            fprintf('  ✗ REJECTED: Not convex\n\n');
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'NotConvex');
            continue;
        end
        fprintf('  Convex: YES\n');
        
        % Calculate dimensions
        rows = approx_clean(:, 1);
        cols = approx_clean(:, 2);
        width = max(cols) - min(cols);
        height = max(rows) - min(rows);
        fprintf('  Width: %.2f, Height: %.2f\n', width, height);
        
        % Calculate minimum width (perpendicular distance between parallel sides)
        min_width = calculateMinWidth(approx_clean);
        fprintf('  Minimum width: %.2f\n', min_width);
        
        aspect_ratio = max(width, height) / min(width, height);
        fprintf('  Aspect ratio: %.3f\n', aspect_ratio);
        
        % REJECT LINES: Minimum width must be reasonable
        if min_width < 10
            fprintf('  ✗ REJECTED: Min width too small (%.2f < 10)\n\n', min_width);
            rejectionCount = rejectionCount + 1;
            rejectionCategories = incrementCategory(rejectionCategories, 'MinWidthTooSmall');
            continue;
        end
        
        % Aspect ratio check with reasonable limit
        if aspect_ratio >= 10.0
            fprintf('  ✗ REJECTED: Aspect ratio too high (%.3f >= 10.0)\n\n', aspect_ratio);
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
        
        fprintf('  Angles: [%.1f, %.1f, %.1f, %.1f]\n', angles(1), angles(2), angles(3), angles(4));
        
        % Check opposite angles sum
angle_sum1 = angles(1) + angles(3);
angle_sum2 = angles(2) + angles(4);
fprintf('  Opposite angle sums: %.1f, %.1f\n', angle_sum1, angle_sum2);

% Total angle sum
total_angle = sum(angles);
fprintf('  Total angle sum: %.1f (should be ~360)\n', total_angle);

% For perspective-distorted documents, parallelogram properties are most reliable
if abs(angle_sum1 - 180) > 30 || abs(angle_sum2 - 180) > 30
    fprintf('  ✗ REJECTED: Not a valid parallelogram\n\n');
    rejectionCount = rejectionCount + 1;
    rejectionCategories = incrementCategory(rejectionCategories, 'InvalidParallelogram');
    continue;
end

if abs(total_angle - 360) > 20
    fprintf('  ✗ REJECTED: Invalid total angle sum\n\n');
    rejectionCount = rejectionCount + 1;
    rejectionCategories = incrementCategory(rejectionCategories, 'InvalidAngleSum');
    continue;
end

fprintf('  ✓ Valid parallelogram properties\n');
        
        % Determine if square or rectangle
        if aspect_ratio < 1.3
            shape_type = 'SQUARE';
        else
            shape_type = 'RECTANGLE';
        end
        
        fprintf('  ✓✓✓ ACCEPTED as %s ✓✓✓\n\n', shape_type);
        squares{end+1} = approx_clean;
    end
    
    fprintf('=== SUMMARY ===\n');
    fprintf('Total contours processed: %d\n', length(B));
    fprintf('Total ACCEPTED: %d\n', length(squares));
    fprintf('Total REJECTED: %d\n', rejectionCount);
    fprintf('\nRejection breakdown:\n');
    
    % Display rejection counts by category
    fields = fieldnames(rejectionCategories);
    for i = 1:length(fields)
        category = fields{i};
        count = rejectionCategories.(category);
        % Convert camelCase to readable format
        readable = regexprep(category, '([A-Z])', ' $1');
        readable = strtrim(readable);
        fprintf('  %s: %d\n', readable, count);
    end
    
    fprintf('================\n\n');
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
    
    % Find centroid
    centroid = mean(poly, 1);
    
    % Calculate angles from centroid to each point
    angles = zeros(4, 1);
    for i = 1:4
        dx = poly(i, 2) - centroid(2);
        dy = poly(i, 1) - centroid(1);
        angles(i) = atan2(dy, dx);
    end
    
    % Sort by angle
    [~, idx] = sort(angles);
    sortedPoly = poly(idx, :);
end