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
