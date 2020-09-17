function [p,V,W] = polyfit_weighted(x,y,w,n)
%% [p,V,W] = polyfit_weighted(x,y,w,n)
% Fit n'th degree polynomial to x,y data without any condition checks
%
% Written by Marcin Konowalczyk
% Timmel Group @ Oxford University

y = y(:);

% Construct Vandermonde matrix
if isvector(x)
    x = x(:); nx = length(x);
    V = zeros(nx,n+1,'like',x);
    %V(:,n+1) = ones(length(x),1,class(x));
    V(:,n+1) = 1;
    for j = n:-1:1
       V(:,j) = x.*V(:,j+1);
    end
else
    % Assume x *is* a Vandermode matrix
    V = x;
    nx = size(V,1);
end

% Construct the weights matrix (if the input has not already been supplied
% as one such matrix);
if isvector(w)
    w = w(:);
    w = w/sum(w);
    if nx > 80 || nargin > 1
        W = spdiags(w,0,nx,nx);
    else
        W = diag(w);
    end
else
    % Assume w *is* a weights matrix
    W = w;
end

p = (W*V)\(W*y); % Solve weighted least squares problem
p = p.';
end