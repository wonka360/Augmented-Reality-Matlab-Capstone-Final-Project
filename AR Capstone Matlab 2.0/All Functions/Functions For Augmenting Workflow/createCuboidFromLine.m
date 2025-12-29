function cuboidVertices = createCuboidFromLine(line2D, wallHeight, wallThickness)
% line2D: [x1 y1 x2 y2]
% wallHeight: extrusion height in mm
% wallThickness: width of the wall in mm

x1 = line2D(1); y1 = line2D(2);
x2 = line2D(3); y2 = line2D(4);

% Direction vector of the line
dx = x2 - x1;
dy = y2 - y1;
lineLength = sqrt(dx^2 + dy^2);

% Normalize and get perpendicular vector for thickness
ux = -dy / lineLength;
uy = dx / lineLength;

% Scale by wallThickness/2
offsetX = (wallThickness / 2) * ux;
offsetY = (wallThickness / 2) * uy;

% Base vertices (Z=0)
v1 = [x1 + offsetX, y1 + offsetY, 0];
v2 = [x2 + offsetX, y2 + offsetY, 0];
v3 = [x2 - offsetX, y2 - offsetY, 0];
v4 = [x1 - offsetX, y1 - offsetY, 0];

% Top vertices (Z=wallHeight)
v5 = v1 + [0 0 wallHeight];
v6 = v2 + [0 0 wallHeight];
v7 = v3 + [0 0 wallHeight];
v8 = v4 + [0 0 wallHeight];

% Output 8x3 matrix of cuboid vertices
cuboidVertices = [v1; v2; v3; v4; v5; v6; v7; v8];
end