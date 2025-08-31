function merged_line = merge_line_segments(group)
    if size(group,1) == 1
        merged_line = group;
        return;
    end

    angle = get_orientation(group(1,:));
    points = [group(:,1:2); group(:,3:4)];

    if angle > 45 && angle <= 90
        points = sortrows(points,2);
    else
        points = sortrows(points,1);
    end

    merged_line = [points(1,:) points(end,:)];
end