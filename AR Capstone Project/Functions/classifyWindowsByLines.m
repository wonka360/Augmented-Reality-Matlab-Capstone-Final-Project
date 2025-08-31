function mainBoxes = filterMainWindowBoxes(boundingBoxes)
% boundingBoxes: Nx4 matrix of [x, y, w, h]
% mainBoxes: Mx4 matrix containing only main window squares, filtered

    remaining = boundingBoxes;
    mainBoxes = [];

    while ~isempty(remaining)
        % Step 1: Find largest box by area
        areas = remaining(:,3) .* remaining(:,4);
        [~, idx] = max(areas);
        mainBox = remaining(idx, :);
        mainBoxes(end+1, :) = mainBox;

        % Step 2: Estimate quarter area
        quarter_area = (mainBox(3) * mainBox(4)) / 4;

        % Step 3: Remove 4 quarter-area boxes in specific positions
        keep = true(size(remaining,1), 1);
        for i = 1:size(remaining,1)
            box = remaining(i, :);
            box_area = box(3) * box(4);
            
            % If area is approximately 1/4th
            if abs(box_area - quarter_area) < 0.2 * quarter_area
                % Check for four expected positions
                tol = 10; % pixel tolerance
                corners = [
                    mainBox(1),         mainBox(2);           % top-left
                    mainBox(1)+mainBox(3), mainBox(2);       % top-right
                    mainBox(1),         mainBox(2)+mainBox(4); % bottom-left
                    mainBox(1)+mainBox(3), mainBox(2)+mainBox(4) % bottom-right
                ];
                
                for c = 1:4
                    if abs(box(1) - corners(c,1)) < tol && abs(box(2) - corners(c,2)) < tol
                        keep(i) = false;
                        break;
                    end
                end
            end
        end

        % Step 4: Remove the largest main box itself
        keep(idx) = false;

        % Step 5: Update remaining
        remaining = remaining(keep, :);
    end
end
