function cuboidVertices = createCuboidFromLineAtHeight(line2D, baseHeight, wallHeight, wallThickness)
        % line2D: [x1 y1 x2 y2]
        % baseHeight: Z-position from where the cuboid starts
        % wallHeight: extrusion height from baseHeight
        % wallThickness: width of the wall in mm
        
        x1 = line2D(1); y1 = line2D(2);
        x2 = line2D(3); y2 = line2D(4);
        
        % Direction vector
        dx = x2 - x1;
        dy = y2 - y1;
        lineLength = sqrt(dx^2 + dy^2);
        
        % Normalized perpendicular vector
        ux = -dy / lineLength;
        uy = dx / lineLength;
        
        % Offset for wall thickness
        offsetX = (wallThickness / 2) * ux;
        offsetY = (wallThickness / 2) * uy;
        
        % Bottom vertices (Z = baseHeight)
        v1 = [x1 + offsetX, y1 + offsetY, baseHeight];
        v2 = [x2 + offsetX, y2 + offsetY, baseHeight];
        v3 = [x2 - offsetX, y2 - offsetY, baseHeight];
        v4 = [x1 - offsetX, y1 - offsetY, baseHeight];
        
        % Top vertices (Z = baseHeight + cuboidHeight)
        v5 = v1 + [0 0 wallHeight];
        v6 = v2 + [0 0 wallHeight];
        v7 = v3 + [0 0 wallHeight];
        v8 = v4 + [0 0 wallHeight];
        
        % Return all 8 vertices
        cuboidVertices = [v1; v2; v3; v4; v5; v6; v7; v8];
end
