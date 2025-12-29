function [polarity, rho, phi] = getTuple(DoGresponse,radius,fp)              
% Determine the values of the polar coordinates (rho,phi)
if radius <= 0
    error('Parameter radius must be greater than 0');
end
phi = []; polarity = [];
x = 1:360;
for pol = 1:size(DoGresponse,3)       
    DoG = DoGresponse(:,:,pol);
    y = DoG(sub2ind(size(DoG),round(fp(1) + radius*cos(pi/2+x*pi/180)),round(fp(2) + radius*sin(pi/2+x*pi/180))));
       
    % Threshold low values
    y(y < 0.1*max(DoGresponse(:))) = 0;   
    y = round(y*1000)/1000;
    
    BW     = bwlabel(imregionalmax(y));
    npeaks = max(BW(:));    
    for i = 1:npeaks
        phi(end+1) = mean(x(BW == i)) * pi/180;
        polarity(end+1) = pol - 1;            
    end     
end
rho = repmat(radius,1,length(phi));