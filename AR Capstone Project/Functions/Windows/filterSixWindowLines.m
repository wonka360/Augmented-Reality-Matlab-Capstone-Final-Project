function filtered = filterSixWindowLines(lines)
    % Compute lengths and orientations
    numLines = size(lines, 1);
    lengths = sqrt((lines(:,3) - lines(:,1)).^2 + (lines(:,4) - lines(:,2)).^2);
    isHorizontal = abs(lines(:,4) - lines(:,2)) < abs(lines(:,3) - lines(:,1));

    horizontal_lines = lines(isHorizontal, :);
    horizontal_lengths = lengths(isHorizontal);

    vertical_lines = lines(~isHorizontal, :);
    vertical_lengths = lengths(~isHorizontal);

    % Sort and pick top 3 longest horizontal lines
    [~, hIdx] = sort(horizontal_lengths, 'descend');
    h_pick = horizontal_lines(hIdx(1:min(3,end)), :);

    % Sort and pick top 3 longest vertical lines
    [~, vIdx] = sort(vertical_lengths, 'descend');
    v_pick = vertical_lines(vIdx(1:min(3,end)), :);

    % Combine
    filtered = [h_pick; v_pick];
end

