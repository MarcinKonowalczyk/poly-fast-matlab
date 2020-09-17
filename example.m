close all; clear; clc;

% `polyfit_fast` and `polyval_fast` work best in the middle of tight `for`
% loops. An example use case here is going through each time-slice through
% a stack of images.

%% Make up a stack of images (Perlin-like noise)
% Based on https://stackoverflow.com/a/12971365/2531987
N = 7; im = randn(2^N,2^N,2^(N+1)); % 2^N x 2^N x 2^(N+1)
for j = 2:N
    s = 2^(N-j+1); % New layer size, 64, 32, 16, etc...
    
    % Add new upsampled layer
    nl = interp3(randn(s+1,s+1,(2*s)+1),(j-1),'spline'); % 'nearest' is also cool
    nl = nl(1:end-1,1:end-1,1:end-1);
    im = im + j*nl;
end

%% View the data
D = im;
f = figure(1); clf;
imagesc(D(:,:,1)); colormap(bone);
grid on; box on; axis square;
a = gca; a.XTickLabel = ''; a.YTickLabel = '';
zlim([-1 1]*40);
for j = 2:size(D,3)
    if ~f.isvalid, break; end
    a.Children.CData = D(:,:,j); title(sprintf('frame %03d',j));
    drawnow; pause(0.01);
end

%% Smooth the motion by replacing each slice through time with a polynomial approximation
% This is slow because polyfit and polyval do a lot of checks on *each* iteration
[height,width,length] = size(im);
t = (1:length)';
n = 4; % Order of the polynomial

tic
new_im = zeros(size(im)); % Preallocate
for j = 1:height
    for k = 1:width
        y = squeeze(im(j,k,:)); % Slice through the stack of images
        P = polyfit(t,y,n); % Fit with a polynomial
        new_im(j,k,:) = polyval(P,t);
    end
    if ~mod(j,10)
        fprintf('% 5.2f %% done\n',j/height*100);
    end
end
t1 = toc;

%% View the new data
D = new_im;
f = figure(1); clf;
imagesc(D(:,:,1)); colormap(bone);
grid on; box on; axis square;
a = gca; a.XTickLabel = ''; a.YTickLabel = '';
zlim([-1 1]*40);
for j = 2:size(D,3)
    if ~f.isvalid, break; end
    a.Children.CData = D(:,:,j); title(sprintf('frame %03d',j));
    drawnow; pause(0.01);
end

%% Same procedure, but with polyfit_fast and polyval_fast
% Much faster
[height,width,length] = size(im);
t = (1:length)';
n = 4; % Order of the polynomial

tic
new_im = zeros(size(im)); % Preallocate
for j = 1:height
    for k = 1:width
        y = squeeze(im(j,k,:)); % Slice through the stack of images
        P = polyfit_fast(t,y,n); % Fit with a polynomial
        new_im(j,k,:) = polyval_fast(P,t);
    end
    if ~mod(j,10)
        fprintf('% 5.2f %% done\n',j/height*100);
    end
end
t2 = toc;

%% Print timing
fprintf('polyfit/val time = %.2f\n',t1);
fprintf('polyfit/val_fast time = %.2f\n',t2);
fprintf('ca. %.0f times speedup\n',t1/t2);

%% Reuse the vandermode matrix
% Can be made even faster by reusing the Vandermode matrix, but it requires
% more code rewrite. The difference here becomes much more apparent when
% the Vandermode matrix is very large (which, in this case, it isn't
% really)
[height,width,length] = size(im);
t = (1:length)';
n = 4; % Order of the polynomial

tic
new_im = zeros(size(im)); % Preallocate
for j = 1:height
    for k = 1:width
        y = squeeze(im(j,k,:)); % Slice through the stack of images
        
        if j==1 && k==1 % Get the Vandermode matrix on first point
            [P,V] = polyfit_fast(t,y,n);
        else % Replace t with V
            P = polyfit_fast(V,y,n);
        end
        new_im(j,k,:) = polyval_fast(P,V);
        
    end
    if ~mod(j,10)
        fprintf('% 5.2f %% done\n',j/height*100);
    end
end
toc