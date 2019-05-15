% Author: Niladri Das, Vedang Deshpande
% Date: 15th May 2019

% Input params: ni : number of inputs    : scalar
% Input params: Ln : List containing number of nodes in each layers from
% input to output.                       : vector : dim n1x1
% Ln(1,end) = no
% Dimension check: Ln should have a dimension of n1x1
% Internal params: W : weight cell array : W{i} is the connectivity matric
% between layers i and i-1: W{i}(k,l) is weight between k node of i layer
% to l node of i-1 layer. The layer

function NN = NNconstruct(ni,Ln)
    % Constructing the W cell array
    nl = length(Ln);
    for i = 1:nl
        if i == 1
            k = ni;
        else
            k = Ln(i-1,1);
        end
        W{i} = (2*rand(Ln(i,1),k)-1); % [-1 1]
        B{i} = (2*rand(Ln(i,1),1)-1);
    end
    NN.W = W;
    NN.B = B;
end