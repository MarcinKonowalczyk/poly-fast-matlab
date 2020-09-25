function test_suite = test_polyfit %#ok<STOUT>
% Initialisation of MOxUnit test framework
% See https://github.com/MOxUnit/MOxUnit for more detials
try test_functions = localfunctions(); catch, end %#ok<NASGU>
initTestSuite;
end

function test_basic_line
P = [2 7];
x = 1:10; y = P(1)*x + P(2);
A = polyfit_fast(x,y,1);
assertElementsAlmostEqual(A,P)
end

function test_basic_quadratic
P = [2 -1 1];
x = 1:10; y = P(1)*x.^2 + P(2)*x + P(3);
A = polyfit_fast(x,y,2);
assertElementsAlmostEqual(A,P);
end

function test_extreme_gradients
gradients = 10.^([-16:-5 5:16]);
gradients = [-gradients gradients];
for j = 1:numel(gradients)
    gradient = gradients(j);
    x = 0:10; y = x*gradients(j);
    A = polyfit_fast(x,y,1);
    
    tol = abs(gradients(j)*numel(x)*eps);
    %fprintf('delta gradient = %g (%g)\n',A(1)-gradient,tol)
    assertElementsAlmostEqual(A(1),gradient,'absolute',tol)
    assertElementsAlmostEqual(A(2),0,'absolute',tol)
end
end

function test_compare_extreme_gradients
gradients = 10.^([-16:-5 5:16]);
gradients = [-gradients gradients];
for j = 1:numel(gradients)
    x = 0:10; y = x*gradients(j);
    A = polyfit_fast(x,y,1);
    B = polyfit(x,y,1); % In-built polyfit
    
    % Gradients can slide away from one another by at most numel(x)*eps
    assertElementsAlmostEqual(A(1),B(1),'relative',numel(x)*eps)
end
end

function test_random_coefficients
x = linspace(-1,1,1e3);
yf = @(P,x) P(1)*x.^5 + P(2)*x.^4 + P(3)*x.^3 + P(4)*x.^2 + P(5)*x + P(6);
for j = 1:1e3
    P = randn(1,6); y = yf(P,x);
    A = polyfit_fast(x,y,5);
    assertElementsAlmostEqual(A,P)
end
end

function test_vandermode
x = linspace(-1,1,1e3);
yf = @(P,x) P(1)*x.^5 + P(2)*x.^4 + P(3)*x.^3 + P(4)*x.^2 + P(5)*x + P(6);
for j = 1:1e3
    P = randn(1,6); y = yf(P,x);
    
    [A,V] = polyfit_fast(x,y,5); % Fit and get vandermode matrix
    B = polyfit_fast(V,y,5);
    assertElementsAlmostEqual(A,P);
    assertElementsAlmostEqual(A,B);
end
end

