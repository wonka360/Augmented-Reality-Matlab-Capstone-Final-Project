% Helper: draw cuboid edges on image
function augmentedImage = drawCuboid(I, projectedPoints, edges, color)
    linesToDraw = [];
    for j = 1:size(edges,1)
        pt1 = projectedPoints(edges(j,1), :);
        pt2 = projectedPoints(edges(j,2), :);
        linesToDraw = [linesToDraw; pt1 pt2];
    end
    augmentedImage = insertShape(I, 'Line', linesToDraw, ...
                                 'Color', color, 'LineWidth', 3);
end