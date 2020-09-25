function test_suite = test_polyfit_weighted %#ok<STOUT>
% Initialisation of MOxUnit test framework
% See https://github.com/MOxUnit/MOxUnit for more detials
try test_functions = localfunctions(); catch, end %#ok<NASGU>
initTestSuite;
end

function test_unweighted_line
P = [2 7];
x = 1:10; y = P(1)*x + P(2);
w = ones(size(x)); % No weights
A = polyfit_weighted(x,y,w,1);
assertElementsAlmostEqual(A,P)
end

function test_unweighted_quadratic
P = [2 -1 1];
x = 1:10; y = P(1)*x.^2 + P(2)*x + P(3);
w = ones(size(x)); % No weights
A = polyfit_weighted(x,y,w,2);
assertElementsAlmostEqual(A,P);
end

function test_weighted_line
P = [2 7];
x = 1:10; y = P(1)*x + P(2);
y(1) = 1e7; w = ones(size(x)); w(1) = 0; % Skew the 1st point and exclude it
A = polyfit_weighted(x,y,w,1);
assertElementsAlmostEqual(A,P);
end

function test_weighted_quadratic
P = [2 -1 1];
x = 1:10; y = P(1)*x.^2 + P(2)*x + P(3);
y(1) = 1e7; w = ones(size(x)); w(1) = 0; % Skew the 1st point and exclude it
A = polyfit_weighted(x,y,w,2);
assertElementsAlmostEqual(A,P);
end

function test_random_coefficients_and_outliers
x = linspace(-1,1,1e3);
yf = @(P,x) P(1)*x.^5 + P(2)*x.^4 + P(3)*x.^3 + P(4)*x.^2 + P(5)*x + P(6);
for j = 1:1e3
    P = randn(1,6); y = yf(P,x);
    outliers = rand(size(x))<0.1; % Random points to become outliers
    y = y + 1e7*randn(size(y)).*double(outliers); % Add outliers
    w = double(~outliers); % Weights exclude outliers
    A = polyfit_weighted(x,y,w,5);
    assertElementsAlmostEqual(A,P)
end
end

function test_vandermode
x = linspace(-1,1,1e3);
yf = @(P,x) P(1)*x.^5 + P(2)*x.^4 + P(3)*x.^3 + P(4)*x.^2 + P(5)*x + P(6);
for j = 1:1e3
    P = randn(1,6); y = yf(P,x);
    y(1) = 1e7; w = ones(size(x)); w(1) = 0; % Skew the 1st point and exclude it
    [A,V] = polyfit_weighted(x,y,w,5); % Fit and get vandermode matrix
    B = polyfit_weighted(V,y,w,5);
    assertElementsAlmostEqual(A,B);
end
end


function test_weights_matrix
x = linspace(-1,1,1e3);
yf = @(P,x) P(1)*x.^5 + P(2)*x.^4 + P(3)*x.^3 + P(4)*x.^2 + P(5)*x + P(6);
for j = 1:1e3
    P = randn(1,6); y = yf(P,x); % Make y
    outliers = rand(size(x))<0.1; % Random points to become outliers
    y = y + 1e7*randn(size(y)).*double(outliers); % Add outliers
    w = double(~outliers); % Weights exclude outliers
    [A,~,W] = polyfit_weighted(x,y,w,5); % Fit and get weights matrix
    B = polyfit_weighted(x,y,W,5); % Fit again and get
    assertElementsAlmostEqual(A,P);
    assertElementsAlmostEqual(A,B);
end
end

