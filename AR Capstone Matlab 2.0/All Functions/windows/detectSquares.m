function squares = detectSquares(B, imageSize)
    % Detect squares and rectangles from boundaries
    % B: Binary image generared from CORF detection
    
    squares = {};
    
    for k = 1:length(B)
        cnt = B{k};
        
        % Approximate polygon
        tolerance = 0.08;
        approx = reducepoly(cnt, tolerance);
        
        % STEP 1: Remove duplicate/overlapping vertices
        approx_clean = removeDuplicateVertices(approx, 3.0);
        
        % STEP 2: Remove collinear points
        approx_clean = removeCollinearPoints(approx_clean, 30);
        
        % Check for 4 vertices
        if size(approx_clean, 1) == 4
            
            % Calculate area
            area = polyarea(approx_clean(:,2), approx_clean(:,1));
            
            if area > 100
                if isConvex(approx_clean)
                    
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
                        continue;
                    end
                    
                    % Aspect ratio check with reasonable limit
                    if aspect_ratio < 10.0
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
                        
                        % Count good angles (70-110°)
                        good_angles = sum(angles > 70 & angles < 110);
                        
                        % Check opposite angles sum
                        angle_sum1 = angles(1) + angles(3);
                        angle_sum2 = angles(2) + angles(4);
                        is_parallelogram = abs(angle_sum1 - 180) < 20 && abs(angle_sum2 - 180) < 20;
                        
                        % Total angle sum
                        total_angle = sum(angles);
                        
                        % STRICTER CRITERIA: Need at least 3 good angles
                        if good_angles >= 3
                            
                            % Determine if square or rectangle
                            if aspect_ratio < 1.3
                                % square
                            else
                                % rectangle
                            end
                            
                            squares{end+1} = approx_clean;
                        end
                    end
                end
            end
        end
    end
end
