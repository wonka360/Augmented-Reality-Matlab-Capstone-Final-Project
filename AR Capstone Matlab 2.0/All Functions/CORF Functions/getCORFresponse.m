function [output data] = getCORFresponse(DoGresponse,operator,data)
sz = [size(DoGresponse,1),size(DoGresponse,2)];
if isempty(data)
    data.params = [];   
    data.tupleOutput = cell(0);
    data.location = [];
    data.paramsindex = 1;
    data.current.tupleOutput = zeros(sz(1),sz(2),size(operator.tuple,2)); 
end
% The weight vector is requried for the computation of the weighted
% geometric mean at the bottom of the function.
weightVector = zeros(1,size(operator.tuple,2));
sgm = max(operator.tuple(3,:)) / 3;
for i = 1:size(operator.tuple,2)                                   
    polarity = operator.tuple(1,i);
    rho = operator.tuple(3,i);
    phi = operator.tuple(4,i);
    
    weightVector(i) = (exp(-rho^2/(2*sgm*sgm)));    
    
    if ~isempty(data.params)
    	mem = find(ismember(data.params,[polarity rho],'rows','legacy'),1);
    else
        mem = [];
    end
    if ~isempty(mem)
        % This tuple output is obtained by appropriate shifting of another
        % tuple output that was computed for the same values of polarity,
        % sigma and rho.
        [col row] = pol2cart(phi,rho);
        shiftrow = -(data.location{mem}(1)-fix(row));
        shiftcol = data.location{mem}(2)-fix(col);
        data.current.tupleOutput(:,:,i) = circshift(data.tupleOutput{mem},[shiftrow,shiftcol]);                                                        
    else
        DoG = DoGresponse(:,:,polarity+1);                    
        data.params(data.paramsindex,:) = [polarity rho];        
        [col row] = pol2cart(phi,rho);
        r = (operator.params.d0 + operator.params.alpha*rho)/2;
        if r > 0
            smoothfilter = fspecial('gaussian',round([2*r+1,2*r+1]),r/3);
            data.current.tupleOutput(:,:,i) = conv2(DoG,smoothfilter,'same');
            data.current.tupleOutput(:,:,i) = circshift(data.current.tupleOutput(:,:,i),[fix(row),fix(-col)]);
        else
            data.current.tupleOutput(:,:,i) = DoG;
        end
        data.current.tupleOutput(:,:,i) = data.current.tupleOutput(:,:,i) .^ weightVector(i);
        
        % We use the following variables to reuse the computations obtained
        % for the same values of parameters: polarity, sigma and rho.
        data.tupleOutput{data.paramsindex} = data.current.tupleOutput(:,:,i);
        data.location{data.paramsindex} = [round(row) round(col)];
        data.paramsindex = data.paramsindex + 1;
    end      
end
% compute the weighted geometric mean
output = prod(data.current.tupleOutput,3).^(1/sum(weightVector));