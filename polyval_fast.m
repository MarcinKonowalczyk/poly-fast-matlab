function y = polyval_fast(p,x)
%% y = polyval_fast(p,x)
% Evaluate n'th degree polynomial to x,y data without any condition checks
%
% Written by Marcin Konowalczyk
% Timmel Group @ Oxford University

p = p(:);

if isvector(x)
    iscolumn_x = iscolumn(x);
    if ~iscolumn_x, x = x'; end % Make x a column vector

    n = numel(p)-1;

    % Construct Vandermonde matrix
    V = zeros(length(x),n+1,class(x));
    %V(:,n+1) = ones(length(x),1,class(x));
    V(:,n+1) = 1;
    for j = n:-1:1
       V(:,j) = x.*V(:,j+1);
    end

    y = V*p; % Evaluate polynomial
    if ~iscolumn_x, y = y'; end % Ensure the output is a column
else
    % Assume x *is* the Vandermode matrix
    y = x*p; % Evaluate polynomial
end
end