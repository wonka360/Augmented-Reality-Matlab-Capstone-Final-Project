function coords_orig = translateCropCoorToOriginal(coords_cropped, cropBox)
    % cropBox = [x y w h]
    xOffset = cropBox(1);
    yOffset = cropBox(2);

    % Check if Nx4 or Nx2 matrix
    if size(coords_cropped,2) == 4
        % For lines: [x1 y1 x2 y2]
        coords_orig = coords_cropped;
        coords_orig(:,[1,3]) = coords_cropped(:,[1,3]) + xOffset - 1;
        coords_orig(:,[2,4]) = coords_cropped(:,[2,4]) + yOffset - 1;
    elseif size(coords_cropped,2) == 2
        % For markers: [x y]
        coords_orig = coords_cropped;
        coords_orig(:,1) = coords_cropped(:,1) + xOffset - 1;
        coords_orig(:,2) = coords_cropped(:,2) + yOffset - 1;
    else
        error('Input coordinates must be Nx2 or Nx4');
    end
end