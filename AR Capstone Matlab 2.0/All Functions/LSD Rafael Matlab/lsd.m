function [segments, n_out, reg_img] = lsd(img, varargin)
% LSD - Line Segment Detector on digital images
%
% This is a MATLAB version of the C implementation of the Line Segment Detector described in:
% "LSD: A Fast Line Segment Detector with a False Detection Control"
% by Rafael Grompone von Gioi, Jeremie Jakubowicz, Jean-Michel Morel,
% and Gregory Randall, IEEE TPAMI, vol. 32, no. 4, pp. 722-732, April 2010.
%
% USAGE:
%   [segments, n_out, reg_img] = lsd(img)
%   [segments, n_out, reg_img] = lsd(img, 'ParamName', ParamValue, ...)
%
% INPUT (all optional, use name-value pairs):
%   img         - Input image (grayscale, double array)
%   'scale'     - Scale factor for Gaussian subsampling (default: 0.8)
%                 Use 1.0 to disable scaling (better for detecting all lines)
%   'sigma_scale' - Sigma for Gaussian filter (default: 0.6)
%   'quant'     - Gradient quantization error bound (default: 2.0)
%                 Lower values (e.g., 1.0) detect weaker gradients
%   'ang_th'    - Angle tolerance in degrees (default: 22.5)
%                 Higher values (e.g., 30-45) better for slanted lines
%   'log_eps'   - Detection threshold -log10(NFA) (default: 0.0)
%                 Lower/negative values (e.g., -1.0) detect more lines
%   'density_th' - Minimal density of region points (default: 0.7)
%                 Lower values (e.g., 0.5) detect more fragmented lines
%   'n_bins'    - Number of bins for gradient ordering (default: 1024)
%
% EXAMPLES:
%   % Default detection
%   [segments, ~, ~] = lsd(img);
%
%   % Detect more lines (including weak and slanted)
%   [segments, ~, ~] = lsd(img, 'scale', 1.0, 'quant', 1.0, ...
%                          'ang_th', 30, 'log_eps', -1.0, 'density_th', 0.5);
%
%   % Very sensitive detection (may include noise)
%   [segments, ~, ~] = lsd(img, 'scale', 1.0, 'quant', 0.5, ...
%                          'ang_th', 45, 'log_eps', -2.0, 'density_th', 0.4);
%
% OUTPUT:
%   segments - Nx7 matrix with detected line segments:
%              [x1, y1, x2, y2, width, p, -log10(NFA)]
%   n_out    - Number of line segments detected
%   reg_img  - Region image (optional, same size as scaled image)

    % Parse input arguments
    p = inputParser;
    addRequired(p, 'img', @(x) isnumeric(x) && ismatrix(x));
    addParameter(p, 'scale', 0.8, @(x) x > 0);
    addParameter(p, 'sigma_scale', 0.6, @(x) x > 0);
    addParameter(p, 'quant', 2.0, @(x) x >= 0);
    addParameter(p, 'ang_th', 22.5, @(x) x > 0 && x < 180);
    addParameter(p, 'log_eps', 0.0, @isnumeric);
    addParameter(p, 'density_th', 0.7, @(x) x >= 0 && x <= 1);
    addParameter(p, 'n_bins', 1024, @(x) x > 0);
    
    parse(p, img, varargin{:});
    
    scale = p.Results.scale;
    sigma_scale = p.Results.sigma_scale;
    quant = p.Results.quant;
    ang_th = p.Results.ang_th;
    log_eps = p.Results.log_eps;
    density_th = p.Results.density_th;
    n_bins = p.Results.n_bins;
    
    % Convert image to double if needed
    img = double(img);
    
    % Call main detection function
    [segments, n_out, reg_img] = line_segment_detection(img, scale, ...
        sigma_scale, quant, ang_th, log_eps, density_th, n_bins);
end