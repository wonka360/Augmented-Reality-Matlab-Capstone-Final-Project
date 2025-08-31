function mainBoxes = filterMainWindowBoxes(boundingBoxes)
    % Function filters the main box from the 4 sub boxes created by the
    % window marker
    % The window marker is a square with a cross within. Equal areas of
    % squares
    % should be maintained across all markers for optimum filtring results
    % boundingBoxes: Nx4 Matrix of [x,y,w,h]
    % Help: In case of filtering errors or limitations, tighten or loosen
    % tolerance values accordingly.
    %mainBoxes: Mx4 matrix containing only main window squares ie large
    %boxes. The number of mainBoxes must equal the no of window makers
    
    %originalImg = "sample_floor_plan5.jpeg";
    %img = py.cv2.imread(originalImg);

    % Initialization
    remaining = boundingBoxes;
    mainBoxes = [];
    


    % Tolerance for comparing current/previous largest boxes
    tol_l = 0.8;
    tol_r = 1.2;

    previousArea = -1;

    while ~isempty(remaining)
        % Compute areas of remaining boxes
        areas = remaining(:,3) .* remaining(:,4);
        [currentArea, idx] = max(areas);
        currentBox = remaining(idx, :);

        % Only accept current box if it passes the tolerance test
        if previousArea < 0 || ...
           (currentArea / previousArea >= tol_l && currentArea / previousArea <= tol_r)

            % Accept and store this box
            mainBoxes(end+1, :) = currentBox;
            previousArea = currentArea;

            % Remove current largest box
            remaining(idx, :) = [];

            % Handle sub-box cleanup
            quarterArea = currentArea / 4;
            tolArea = 0.25 * quarterArea;  % 25% tolerance for sub-box
            tolPos = 10;                   % 10 pixel tolerance in position
            toRemove = false(size(remaining,1), 1);

            % Coordinates of current main box
            x_main = currentBox(1);
            y_main = currentBox(2);
            w_main = currentBox(3);
            h_main = currentBox(4);

            % 4 expected sub-square positions (top-left, top-right, bottom-left, bottom-right)
            corners = [
                x_main,             y_main;
                x_main + w_main/2,  y_main;
                x_main,             y_main + h_main/2;
                x_main + w_main/2,  y_main + h_main/2
            ];

            % Check for and mark sub-boxes to remove
            for i = 1:size(remaining,1)
                box = remaining(i, :);
                area = box(3) * box(4);

                if abs(area - quarterArea) <= tolArea
                    for c = 1:4
                        dx = abs(box(1) - corners(c,1));
                        dy = abs(box(2) - corners(c,2));
                        if dx <= tolPos && dy <= tolPos
                            toRemove(i) = true;
                            break;
                        end
                    end
                end
            end

            % Remove identified sub-boxes
            remaining(toRemove, :) = [];

        else
            % Stop the loop if condition is not satisfied
            break;
        end
    end

    
     %Show result
    
    % --- Convert to MATLAB RGB for display ---
    %img_rgb = py.cv2.cvtColor(img, py.cv2.COLOR_BGR2RGB);
    %img_flat = img_rgb.flatten();
    %img_uint8 = uint8(py.array.array('B', img_flat));
    %h = int64(img_rgb.shape{1});  % height
    %w = int64(img_rgb.shape{2});  % width
    %c = int64(img_rgb.shape{3});  % channels

    %img_reshaped = reshape(img_uint8, [c, w, h]);
    %img_m = permute(img_reshaped, [3, 2, 1]);
    %outputImage = insertShape(img_m, 'Rectangle', mainBoxes, ...
                              %'Color', 'green', 'LineWidth', 3);

     %Show result
    %figure;
    %imshow(outputImage);
    %title('Main Window Bounding Boxes (Filtered and Drawn)');

end
