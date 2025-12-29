function d = pointToLineDistance(point, lineStart, lineEnd)
    % Calculate perpendicular distance from point to line
    if isequal(lineStart, lineEnd)
        d = norm(point - lineStart);
    else
        n = abs((lineEnd(1)-lineStart(1))*(lineStart(2)-point(2)) - ...
                (lineStart(1)-point(1))*(lineEnd(2)-lineStart(2)));
        d = n / norm(lineEnd - lineStart);
    end
end