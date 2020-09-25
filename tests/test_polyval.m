function test_suite = test_polyval %#ok<STOUT>
% Initialisation of MOxUnit test framework
% See https://github.com/MOxUnit/MOxUnit for more detials
try test_functions = localfunctions(); catch, end %#ok<NASGU>
initTestSuite;
end

function test_basic_line
P = [2 7]; x = 1:10;
y1 = P(1)*x + P(2);
y2 = polyval_fast(P,x);
assertElementsAlmostEqual(y1,y2)
% Repeat with transposed x
x = x';
y1 = P(1)*x + P(2);
y2 = polyval_fast(P,x);
assertElementsAlmostEqual(y1,y2)
end

function test_random_coefficients
x = linspace(-1,1,1e3);
yf = @(P,x) P(1)*x.^5 + P(2)*x.^4 + P(3)*x.^3 + P(4)*x.^2 + P(5)*x + P(6);
for j = 1:1e3
    P = randn(1,6);
    y1 = yf(P,x);
    y2 = polyval_fast(P,x);
    assertElementsAlmostEqual(y1,y2)
end
end

function test_vandermode
x = linspace(-1,1,1e3);
yf = @(P,x) P(1)*x.^5 + P(2)*x.^4 + P(3)*x.^3 + P(4)*x.^2 + P(5)*x + P(6);
for j = 1:1e3
    P = randn(1,6); y = yf(P,x);
    [A,V] = polyfit_fast(x,y,5); % Fit and get the Vandermode matrix
    assertElementsAlmostEqual(A,P); % Make sure the fit was actually fine
    y1 = polyval_fast(A,x);
    y2 = polyval_fast(A,V);
    assertElementsAlmostEqual(y1(:),y2(:))
end
end