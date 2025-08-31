function augmentedImage = projectExtrudedPlan(I, lines, doors, windows, intrinsics, tagPose, wallHeight, wallThickness)
    augmentedImage = I;
    doorBase = (2/3)*wallHeight;
    windowLowerHeight = (1/3)*wallHeight;
    windowUpperBase = (2/3)*wallHeight;

    % Common cuboid edge definition
    edges = [
        1 2; 2 3; 3 4; 4 1;    % bottom rectangle
        5 6; 6 7; 7 8; 8 5;    % top rectangle
        1 5; 2 6; 3 7; 4 8     % vertical edges
    ];

    % --- Walls ---
    for i = 1:size(lines,1)
        vertices = createCuboidFromLine(lines(i,:), wallHeight, wallThickness);
        projectedPoints = worldToImage(intrinsics, tagPose, vertices);
        augmentedImage = drawCuboid(augmentedImage, projectedPoints, edges, 'green');
    end

    % --- Doors ---
    for i = 1:size(doors,1)
        vertices = createCuboidFromLineAtHeight(doors(i,:), doorBase, wallHeight-doorBase, wallThickness);
        projectedPoints = worldToImage(intrinsics, tagPose, vertices);
        augmentedImage = drawCuboid(augmentedImage, projectedPoints, edges, 'green');
    end

    % --- Windows (bottom + top parts) ---
    for i = 1:size(windows,1)
        v1 = createCuboidFromLineAtHeight(windows(i,:), 0, windowLowerHeight, wallThickness);
        v2 = createCuboidFromLineAtHeight(windows(i,:), windowUpperBase, windowLowerHeight, wallThickness);

        for v = {v1, v2}
            projectedPoints = worldToImage(intrinsics, tagPose, v{1});
            augmentedImage = drawCuboid(augmentedImage, projectedPoints, edges, 'green');
        end
    end
end


