function isSurrounded = check_horizontal_surround(line, lines_array, tol, gap_max)
            y = mean([line(2), line(4)]);
            x_min = min(line(1), line(3));
            x_max = max(line(1), line(3));
            is_left = false; is_right = false;
            for i = 1:size(lines_array, 1)
                l = lines_array(i,:);
                l_y = mean([l(2), l(4)]);
                if abs(l_y - y) > tol
                    continue;
                end
                l_x_min = min(l(1), l(3));
                l_x_max = max(l(1), l(3));
        
                if l_x_max < x_min && (x_min - l_x_max) <= gap_max
                    is_left = true;
                elseif l_x_min > x_max && (l_x_min - x_max) <= gap_max
                    is_right = true;
                end
                if is_left && is_right
                    break;
                end
            end
            isSurrounded = is_left && is_right;
        end