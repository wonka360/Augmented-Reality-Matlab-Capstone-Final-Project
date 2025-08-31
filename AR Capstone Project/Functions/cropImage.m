function cropped_mat = cropImage(img, bbox, scale)
    x_box = int32(bbox(1));
    y_box = int32(bbox(2));
    w_box = int32(bbox(3));
    h_box = int32(bbox(4));
    
    x = max(x_box - scale * w_box / 2, 0);
    y = max(y_box - scale * h_box / 2, 0);
    w = w_box * (1 + scale);
    h = h_box * (1 + scale);
    
    cropped_py = py.eval('img[y:y+h, x:x+w, :]', struct('img', img, 'y', y, 'x', x, 'h', h, 'w', w));
    cropped_mat = uint8(py.numpy.array(cropped_py));
    cropped_mat = permute(cropped_mat, [2, 1, 3]); % Swap axes for MATLAB
end