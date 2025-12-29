function operator = configureCORF(sigma, sigmaRatio)
% configureCORF: configure a CORF operator for the given parameters.
% The parameters alpha and d0 are set as reported in the above mentioned paper
operator.params.alpha = 0.9;
operator.params.d0 = 2;
operator.params.sigma = sigma;
operator.params.sigmaRatio = sigmaRatio;
% The following are the rho values that were used in the experiments
% reported in the above mentioned paper.
if sigma >= 1 && sigma < 2.5
    operator.params.rho = [14.38 6.9796 3.0310 1.4135];
elseif sigma >= 2.5 && sigma < 4
    operator.params.rho = [3.0515 6.1992 12.6488 24.62];
elseif sigma >= 4 && sigma <= 5
    operator.params.rho = [3.3021 4.7877 9.2467 18.08 34.43];
else
    error('The value of the parameter sigma is out of bounds');
end
maxRadius = ceil(max(operator.params.rho))+1;
stimulus = zeros((2*maxRadius));
stimulus(:,1:maxRadius) = 1;
center = [maxRadius maxRadius];
%Obtain the output of DoG function for the synthetic edge stimulus
DoGresponse(:,:,1) = applyDoG(stimulus, 0, maxRadius, sigma, sigmaRatio, 1);
DoGresponse(:,:,2) = -DoGresponse(:,:,1);
DoGresponse(:,:,1) = DoGresponse(:,:,1) .* (DoGresponse(:,:,1) > 0);
DoGresponse(:,:,2) = DoGresponse(:,:,2) .* (DoGresponse(:,:,2) > 0);
operator.tuple = [];
for r = 1:length(operator.params.rho)
    [polarity rho phi] = getTuple(DoGresponse,operator.params.rho(r),center);    
    operator.tuple = [operator.tuple [polarity; repmat(sigma,1,length(polarity)); rho; phi]];    
end