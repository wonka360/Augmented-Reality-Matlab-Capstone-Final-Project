function merged_lines = merge_groups(lines_array, min_distance, min_angle)
    horizontals = [];
    verticals = [];

    for i = 1:size(lines_array,1)
        line = lines_array(i,:);
        angle = get_orientation(line);
        if angle > 45 && angle <= 90
            verticals = [verticals; line];
        else
            horizontals = [horizontals; line];
        end
    end

    horizontals = sortrows(horizontals, 2);
    verticals = sortrows(verticals, 1);

    merged_lines = [merge_lines(horizontals, min_distance, min_angle); merge_lines(verticals, min_distance, min_angle)];
end