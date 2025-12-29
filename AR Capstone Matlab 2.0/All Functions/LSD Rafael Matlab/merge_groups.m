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

function merged = merge_lines(lines, min_distance, min_angle)
    if isempty(lines)
        merged = [];
        return;
    end

    groups = {lines(1,:)};
    for i = 2:size(lines,1)
        line_new = lines(i,:);
        added = false;
        for g = 1:length(groups)
            for j = 1:size(groups{g},1)
                line_existing = groups{g}(j,:);
                if get_distance(line_new, line_existing) < min_distance && ...
                   abs(get_orientation(line_new) - get_orientation(line_existing)) < min_angle
                    groups{g} = [groups{g}; line_new];
                    added = true;
                    break;
                end
            end
            if added
                break;
            end
        end
        if ~added
            groups{end+1} = line_new;
        end
    end

    merged = [];
    for k = 1:length(groups)
        merged = [merged; merge_line_segments(groups{k})];
    end
end

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

function angle = get_orientation(line)
    dx = abs(line(3) - line(1));
    dy = abs(line(4) - line(2));
    angle = atan2d(dy, dx);
end

function dist = get_distance(a, b)
    d1 = point_line_distance(a(1:2), b);
    d2 = point_line_distance(a(3:4), b);
    d3 = point_line_distance(b(1:2), a);
    d4 = point_line_distance(b(3:4), a);
    dist = min([d1 d2 d3 d4]);
end

function d = point_line_distance(p, l)
    x0 = p(1); y0 = p(2);
    x1 = l(1); y1 = l(2);
    x2 = l(3); y2 = l(4);

    A = x0 - x1;
    B = y0 - y1;
    C = x2 - x1;
    D = y2 - y1;

    dotp = A*C + B*D;
    len_sq = C*C + D*D;
    param = dotp / len_sq;

    if param < 0
        xx = x1; yy = y1;
    elseif param > 1
        xx = x2; yy = y2;
    else
        xx = x1 + param * C;
        yy = y1 + param * D;
    end

    dx = x0 - xx;
    dy = y0 - yy;
    d = sqrt(dx*dx + dy*dy);
end