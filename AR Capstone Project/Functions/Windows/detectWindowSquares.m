function bboxes = detectWindowSquares(imagePath)
% Detects square windows in a floor plan using OpenCV via MATLAB Python interface.

    % --- Load image using OpenCV ---
    img = imagePath;
    
    if isempty(img)
        error("Image not found or unreadable. Check path: %s", imagePath);
    end
    img = py.cv2.GaussianBlur(img, py.tuple({int32(5), int32(5)}), 0);

    % --- Initialize ---
    squares = {};
    bboxes = [];

    channels = py.cv2.split(img);

    for ch = 1:length(channels)
        gray = py.numpy.array(channels{ch});
        for thrs = 0:26:255
            if thrs == 0
                bin = py.cv2.Canny(gray, int32(0), int32(50), pyargs('apertureSize', int32(5)));
                bin = py.cv2.dilate(bin, []);
            else
                thresh_result = py.cv2.threshold(gray, thrs, 255, py.cv2.THRESH_BINARY);
                bin = thresh_result{2};

            end

            contourOutput = py.cv2.findContours(bin, py.cv2.RETR_LIST, py.cv2.CHAIN_APPROX_SIMPLE);
            contours = contourOutput{1};


            for k = 1:length(contours)
                cnt = contours{k};
                cnt_len = py.cv2.arcLength(cnt, true);
                approx = py.cv2.approxPolyDP(cnt, 0.02 * double(cnt_len), true);

                if int64(approx.shape{1}) == 4 && ...
                   py.cv2.contourArea(approx) > 1000 && ...
                   py.cv2.isContourConvex(approx)

                    % Convert to MATLAB 2D points
                    approx_np = py.numpy.array(approx).reshape(int32([-1, 2]));
                    cnt_mat = double(approx_np);

                    % --- Compute maximum cosine of angles ---
                    max_cos = 0;
                    for i = 1:4
                        p0 = cnt_mat(mod(i-2, 4)+1, :);
                        p1 = cnt_mat(mod(i-1, 4)+1, :);
                        p2 = cnt_mat(mod(i, 4)+1, :);
                        d1 = p0 - p1;
                        d2 = p2 - p1;
                        cos_angle = abs(dot(d1, d2) / (norm(d1) * norm(d2)));
                        max_cos = max(max_cos, cos_angle);
                    end

                    % --- Vertical height check ---
                    a = cnt_mat(2,2) - cnt_mat(1,2);
                    img_h = double(img.shape{1});  % height in Python shape

                    if max_cos < 0.1 && abs(a) < img_h * 0.8
                        rect = py.cv2.boundingRect(py.numpy.array(approx));
                        x = double(rect{1});
                        y = double(rect{2});
                        w = double(rect{3});
                        h = double(rect{4});

                        % Deduplication check
                        duplicate = false;
                        for i = 1:size(bboxes, 1)
                            if all(abs([x y w h] - bboxes(i,:)) < 10)
                                duplicate = true;
                                break;
                            end
                        end

                        if ~duplicate
                            bboxes(end+1, :) = [x y w h];
                            squares{end+1} = cnt_mat;
                        end
                    end
                end
            end
        end
    end

    % --- Draw bounding boxes ---
    for i = 1:size(bboxes, 1)
        x = int32(bboxes(i,1));
        y = int32(bboxes(i,2));
        w = int32(bboxes(i,3));
        h = int32(bboxes(i,4));
        py.cv2.rectangle(img, py.tuple([x, y]), py.tuple([x + w, y + h]), py.tuple([0, 255, 0]), int32(2));
    end

    % --- Convert to MATLAB RGB for display ---
    img_rgb = py.cv2.cvtColor(img, py.cv2.COLOR_BGR2RGB);
    img_flat = img_rgb.flatten();
    img_uint8 = uint8(py.array.array('B', img_flat));
    h = int64(img_rgb.shape{1});  % height
    w = int64(img_rgb.shape{2});  % width
    c = int64(img_rgb.shape{3});  % channels

    img_reshaped = reshape(img_uint8, [c, w, h]);
    img_m = permute(img_reshaped, [3, 2, 1]);

    % --- Display image ---
    figure;
    imshow(img_m);
    title('Detected Window Squares');

    % --- Print results ---
    %fprintf("\nDetected Unique Squares (Bounding Boxes):\n");
    %for i = 1:size(bboxes, 1)
        %fprintf("Window %d: x=%.0f, y=%.0f, w=%.0f, h=%.0f\n", ...
                %i, bboxes(i,1), bboxes(i,2), bboxes(i,3), bboxes(i,4));
    %end
   
end
