function [lines_array, img_rgb] = detectAndDisplayLines(imagePath)
% detectAndDisplayLines Detects and displays line segments using OpenCV LSD
%   lines_array = detectAndDisplayLines(imagePath) detects lines in the image
%   specified by imagePath and displays them. It returns the Nx4 array of
%   lines in the format [x1 y1 x2 y2].

    % --- Step 1: Read and preprocess ---
    %input_img = py.cv2.imread(imagePath);
    input_img = imagePath;
    gray = py.cv2.cvtColor(input_img, py.cv2.COLOR_BGR2GRAY);
    detector = py.cv2.createLineSegmentDetector();

    % --- Step 2: Detect lines ---
    lines_tuple = detector.detect(gray);  % returns (lines, width, prec, nfa)
    lines_raw = lines_tuple{1};           % N x 1 x 4

    % --- Step 3: Reshape lines if needed ---
    if int64(lines_raw.ndim) == 2 && int64(py.operator.getitem(lines_raw.shape, int32(1))) == 4
        lines_fixed = lines_raw.reshape(int32(-1), int32(1), int32(4));
    else
        lines_fixed = lines_raw;
    end

    % --- Step 4: Draw segments on original image using OpenCV ---
    input_img_drawn = detector.drawSegments(input_img.copy(), lines_fixed);

    % --- Step 5: Convert to RGB for MATLAB display ---
    img_rgb_py = py.cv2.cvtColor(input_img_drawn, py.cv2.COLOR_BGR2RGB);
    h = int64(py.operator.getitem(img_rgb_py.shape, int32(0)));
    w = int64(py.operator.getitem(img_rgb_py.shape, int32(1)));
    c = int64(py.operator.getitem(img_rgb_py.shape, int32(2)));

    img_flat = img_rgb_py.flatten();
    img_uint8 = uint8(py.array.array('B', img_flat));

    img_rgb = reshape(img_uint8, [c, w, h]);
    img_rgb = permute(img_rgb, [3, 2, 1]);

    % --- Step 6: Display the result ---
    %figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.6, 0.7]);
    %imshow(img_rgb);
    %axis off;
    %title('Detected Line Segments (OpenCV LSD)');

    % --- Step 7: Extract lines to MATLAB array ---
    lines_list = cell(lines_fixed.tolist());  % Convert to MATLAB cell array
    num_lines = length(lines_list);
    lines_array = zeros(num_lines, 4);

    for i = 1:num_lines
        inner_line = lines_list{i}{1};  % Extract [x1, y1, x2, y2]
        for j = 1:4
            lines_array(i, j) = double(py.operator.getitem(inner_line, int32(j-1)));
        end
    end
end
