function isSurrounded = check_vertical_surround(line, lines_array, tol, gap_max)
            x = mean([line(1), line(3)]);
            y_min = min(line(2), line(4));
            y_max = max(line(2), line(4));
            is_top = false; is_bottom = false;
            for i = 1:size(lines_array, 1)
                l = lines_array(i,:);
                l_x = mean([l(1), l(3)]);
                if abs(l_x - x) > tol
                    continue;
                end
                l_y_min = min(l(2), l(4));
                l_y_max = max(l(2), l(4));
        
                if l_y_max < y_min && (y_min - l_y_max) <= gap_max
                    is_top = true;
                elseif l_y_min > y_max && (l_y_min - y_max) <= gap_max
                    is_bottom = true;
                end
                if is_top && is_bottom
                    break;
                end
            end
            isSurrounded = is_top && is_bottom;
        end