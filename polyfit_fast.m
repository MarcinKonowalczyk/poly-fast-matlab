function [p,V] = polyfit_fast(x,y,n)
%% [p,V] = polyfit_fast(x,y,n)
% Fit n'th degree polynomial to x,y data without any condition checks
%
% Written by Marcin Konowalczyk
% Timmel Group @ Oxford University

y = y(:);

if isvector(x)
    x = x(:);
    V = zeros(length(x),n+1,'like',x);
    V(:,n+1) = 1;
    for j = n:-1:1
       V(:,j) = x.*V(:,j+1);
    end
else
    % Assume x *is* the Vandermode matrix
    V = x;
end

p = V\y; % Solve least squares problem
p = p.';
end