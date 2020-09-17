close all; clear; clc;

%%
N = unique(round(10.^linspace(1,6,20))); % Input sizes
M = 15; % Number of repeats
n = 1; % Degree of polynomial

%% Time polyfit
t1 = zeros(numel(N),M);
for Ni = 1:numel(N)
    x = rand(1,N(Ni)); y = rand(1,N(Ni));
    for j = 1:M
        tic
        P = polyfit(x,y,n);
        t1(Ni,j) = toc;
    end
end
t1 = t1*1e6; % Convert to us

%% Time polyfit_fast
t2 = zeros(numel(N),M);
for Ni = 1:numel(N)
    x = rand(1,N(Ni)); y = rand(1,N(Ni));
    for j = 1:M
        tic
        P = polyfit_fast(x,y,n);
        t2(Ni,j) = toc;
    end
end
t2 = t2*1e6; % Convert to us

%% Time polyfit_fast with Vandermove matrix reuse
t3 = zeros(numel(N),M);
for Ni = 1:numel(N)
    x = rand(1,N(Ni)); y = rand(1,N(Ni));
    for j = 1:M
        tic
        if j==1
            [P,V] = polyfit_fast(x,y,n);
        else
            P = polyfit_fast(V,y,n);
        end
        t3(Ni,j) = toc;
    end
end
t3 = t3*1e6; % Convert to us

% Plot
figure(1); clf; hold on;
errorbar(N,mean(t1,2),std(t1,[],2),'DisplayName','Matalb''s polyfit');
errorbar(N,mean(t2,2),std(t2,[],2),'DisplayName','polyfit\_fast');
errorbar(N,mean(t3,2),std(t3,[],2),'DisplayName','polyfit\_fast + Vandermode');
xlim([min(N) max(N)]); ylim([1e0 1e6]);
grid on; box on; axis square;
a = gca; a.XScale = 'log'; a.YScale = 'log';
xlabel('input size (N)');
ylabel('time / us');
legend('location','northwest');
title(sprintf('Fitting degree %d polynomial to random input',n))
    