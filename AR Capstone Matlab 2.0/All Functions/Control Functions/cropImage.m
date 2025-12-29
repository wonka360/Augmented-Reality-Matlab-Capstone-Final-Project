function  I = cropImage(img, boundingBox, scale)
       
    x = max(boundingBox(1,1) - scale * boundingBox(1,3) / 2, 1);
    y = max(boundingBox(1,2) - scale * boundingBox(1,4) / 2, 1);
    w = boundingBox(1,3) * (1 + scale);
    h = boundingBox(1,4) * (1 + scale);
    scaled_bbox = [x, y, w, h];
    
    I = imcrop(img, scaled_bbox);
    
end