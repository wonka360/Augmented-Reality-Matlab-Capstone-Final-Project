function [output binarizedContour] = CORF(I, sigma, t)
% CORF Contour detection based on a computational model of a simple cell.
%
% VERSION 22/04/2012
% CREATED BY: George Azzopardi and Nicolai Petkov, University of Groningen,
%             Johann Bernoulli Institute for Mathematics and Computer Science, Intelligent Systems
%
%If you use this script please cite the following paper:
%   George Azzopardi and Nicolai Petkov, "A CORF computational model of a
%     simple cell that relies on LGN input outperforms the Gabor function
%     model", 2012, DOI: 10.1007/s00422-012-0486-6
% 
%   CORF achieves orientation selectivity by combining the output - at certain 
%   positions with respect to the center of the CORF operator - of center-on 
%   and center-off difference of Gaussians (DoG) functions by a weighted geometric mean. 
%
%   CORF takes as input:
%      I -> intensity image
%      sigma -> the standard deviation of the outer Gaussian function of the 
%               DoG operator
%      t -> high threshold used for hysteresis thresholding
%
%   CORF returns:
%      output -> maximum superposition of CORF responses that correspond to 12 orientations
%      binarizedContour -> A contour map that is obtaiend by first thinning
%                          output and then performs hysteresis thresholding 
%                          with a high threshold t and a low threshold that 
%                          is a fraction 0.5 of the given t.
%
%   Example: [o bc] = CORF(imread('rino.pgm'),2.5,0.3);
%
%   The image rino.pgm is taken from the RuG data set of 40 images of
%   natural scenes, which can be downloaded from:
%   http://www.cs.rug.nl/~imaging/databases/contour_database/contour_database.html
% configure CORF operator
operator = configureCORF(sigma,0.5);
% Set number of orientations
noriens = 12;
orienslist = 0:180/noriens:359;
% Preprocessing
inputImage = double(I);
if ndims(inputImage) == 3
    inputImage = double(rgb2gray(inputImage));
end
if max(inputImage(:)) > 1
    inputImage = inputImage ./ 255;
end
% Apply difference of Gaussians function.
padwidth = ceil(max(operator.params.rho));
DoGresponse(:,:,1) = applyDoG(inputImage, 0, padwidth, operator.params.sigma, operator.params.sigmaRatio, 0);        
DoGresponse(:,:,2) = -DoGresponse(:,:,1);            
DoGresponse(:,:,1) = DoGresponse(:,:,1) .* (DoGresponse(:,:,1) > 0);
DoGresponse(:,:,2) = DoGresponse(:,:,2) .* (DoGresponse(:,:,2) > 0);
% Apply the CORF oeprator at different orientations
data = [];
output = zeros(size(DoGresponse,1),size(DoGresponse,2),noriens);
for rot = 1:length(orienslist)
    rotatedOperator = operator;
    rotatedOperator.tuple(4,:) = rotatedOperator.tuple(4,:) + orienslist(rot)*pi/180;    
    [output(:,:,rot) data] = getCORFresponse(DoGresponse,rotatedOperator,data);
end
output = output(padwidth+1:end-padwidth,padwidth+1:end-padwidth,:);
% Merge output of all orientations by using maximum superposition
[output, oriensMatrix] = calc_viewimage(output,1:size(output,3), orienslist*pi/180);   
% Perform thinning
thinningOutput = thinning(output, oriensMatrix, 2);     
%Perform hysteresis thresholding
t = t * max(thinningOutput(:));
binarizedContour = hysthresh(thinningOutput, t, 0.5*t);