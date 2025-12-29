function output = applyDoG(inputImage,polarity,padwidth,sigma,sigmaRatio,crop)
% pad input image
paddedInputImage = padarray(inputImage,[padwidth padwidth],'both','symmetric');
% create DoG operator
sz = size(inputImage) + padwidth + padwidth;    
g1 = fspecial('gaussian',sz,sigma);
g2 = fspecial('gaussian',sz,sigma*sigmaRatio);
if polarity == 1
    DoG = g2 - g1;  
elseif polarity == 0
    DoG = g1 - g2;
else
    error('Polarity must be either 0 (on) or 1 (off)');
end
% compute DoG
output = fftshift(ifft2(fft2(DoG,sz(1),sz(2)) .* fft2(paddedInputImage)));
if crop == 1
    output = output(padwidth+1:end-padwidth,padwidth+1:end-padwidth);
end