close all; clear; clc;

%%
Ns = unique(round(10.^linspace(1,6,20))); % Input sizes
M = 10; % Number of repeats
n = 1; % Degree of polynomial
t = {};

%% Time polyfit
t{1} = zeros(numel(Ns),M);
for Ni = 1:numel(Ns)
    x = rand(1,Ns(Ni)); y = rand(1,Ns(Ni));
    for j = 1:M
        tic
        P = polyfit(x,y,n);
        t{1}(Ni,j) = toc;
    end
    fprintf('polyfit | N = %.0f\n',Ns(Ni))
end
t{1} = t{1}*1e6; % Convert to us

%% Time polyfit_fast
t{2} = zeros(numel(Ns),M);
for Ni = 1:numel(Ns)
    x = rand(1,Ns(Ni)); y = rand(1,Ns(Ni));
    for j = 1:M
        tic
        P = polyfit_fast(x,y,n);
        t{2}(Ni,j) = toc;
    end
    fprintf('polyfit_fast | N = %.0f\n',Ns(Ni))
end
t{2} = t{2}*1e6; % Convert to us

%% Time polyfit_fast with Vandermove matrix reuse
t{3} = zeros(numel(Ns),M);
for Ni = 1:numel(Ns)
    x = rand(1,Ns(Ni)); y = rand(1,Ns(Ni));
    for j = 1:M
        tic
        if j==1
            [P,V] = polyfit_fast(x,y,n);
        else
            P = polyfit_fast(V,y,n);
        end
        t{3}(Ni,j) = toc;
    end
    fprintf('polyfit_fast + Vandermode | N = %.0f\n',Ns(Ni))
end
t{3} = t{3}*1e6; % Convert to us

%% Time polyfit_weighted
t{4} = zeros(numel(Ns),M);
for Ni = 1:numel(Ns)
    x = rand(1,Ns(Ni)); y = rand(1,Ns(Ni)); w = rand(1,Ns(Ni));
    for j = 1:M
        tic
        P = polyfit_weighted(x,y,w,n);
        t{4}(Ni,j) = toc;
    end
    fprintf('polyfit_weighted | N = %.0f\n',Ns(Ni))
end
t{4} = t{4}*1e6; % Convert to us

%% Time polyfit_fast with Vandermove matrix reuse
t{5} = zeros(numel(Ns),M);
for Ni = 1:numel(Ns)
    x = rand(1,Ns(Ni)); y = rand(1,Ns(Ni)); w = rand(1,Ns(Ni));
    for j = 1:M
        tic
        if j==1
            [P,V,W] = polyfit_weighted(x,y,w,n);
        else
            P = polyfit_weighted(V,y,W,n);
        end
        t{5}(Ni,j) = toc;
    end
    fprintf('polyfit_weighted + Vandermode | N = %.0f\n',Ns(Ni))
end
t{5} = t{5}*1e6; % Convert to us

%% Plot
figure(1); clf;
lNs = log10(Ns);
a = subplot(1,2,1); hold on;
h = []; % Plot handles for the legend
cm = lines; cm(1,:) = [1 1 1]*0.1;
names = {'polyfit','polyfit\_fast','\_fast + Vander.','polyfit\_weighted','\_weighted + Vander.'};
for j = [1 2 3]
    y = sort(t{j},2); y = y(:,round([1/4 1/2 3/4]*M)); % Approximate quartiles of the data
    y(:,3) = y(:,2)+(y(:,3)-y(:,2))*2; y(:,1) = y(:,2)-(y(:,2)-y(:,1))*2; % Error = 2*interquartile range
    y = log10(max(y,1)); % Make sure times are posititive
    h(end+1) = plot(lNs,y(:,2),'Color',cm(j,:),'DisplayName',names{j});
    patch([lNs'; flip(lNs)'],[y(:,3); flip(y(:,1))],cm(j,:),'Edgecolor','none','FaceAlpha',0.2);
end
a.XTick = min(lNs):max(lNs);
xlim([min(lNs) max(lNs)]); ylim([0 6]); 
grid on; box on; axis square;
xlabel('log_{10}( input size (N) )'); ylabel('log_{10}( time / us )');
title(sprintf('Fit degree %d poly.',n))
legend(h,'location','northwest');

a = subplot(1,2,2); hold on;
h = []; % Plot handles for the legend
for j = [1 4 5]
    y = sort(t{j},2); y = y(:,round([1/4 1/2 3/4]*M)); % Approximate quartiles of the data
    y(:,3) = y(:,2)+(y(:,3)-y(:,2))*2; y(:,1) = y(:,2)-(y(:,2)-y(:,1))*2; % Error = 2*interquartile range
    y = log10(max(y,1)); % Make sure times are posititive
    h(end+1) = plot(lNs,y(:,2),'Color',cm(j,:),'DisplayName',names{j});
    patch([lNs'; flip(lNs)'],[y(:,3); flip(y(:,1))],cm(j,:),'Edgecolor','none','FaceAlpha',0.2);
end
a.XTick = min(lNs):max(lNs);
xlim([min(lNs) max(lNs)]); ylim([0 6]); 
grid on; box on; axis square;
xlabel('log_{10}( input size (N) )'); ylabel('log_{10}( time / us )');
title(sprintf('Fit degree %d poly.',n))
legend(h,'location','northwest');