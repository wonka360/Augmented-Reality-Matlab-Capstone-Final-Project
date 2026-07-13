% Helper: draw cuboid edges on image
function augmentedImage = drawCuboid(I, projectedPoints, edges, color)
    linesToDraw = [projectedPoints(edges(:,1), :), projectedPoints(edges(:,2), :)];
    augmentedImage = insertShape(I, 'Line', linesToDraw, ...
                                 'Color', color, 'LineWidth', 3);
end