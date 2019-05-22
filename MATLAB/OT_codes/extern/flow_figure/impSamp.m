clc,clear all,close all;
addpath('altmany-export_fig-7720793');
rng('default')

%% prior parameters
P = 0.75*[0.75,0.5;0.5,0.6];
mu = [0;0];
%% likelihood parameter
obs = [0.975;-0.6];
R = 0.01*[1,-6.75;-6.75,50];

%% sampling of particles from prior
x = mvnrnd(mu',P,100)';
id1 = find(x(1,:)<-2.25);
id2 = find(x(1,:)>1.75);
id3 = find(x(2,:)<-1.5);
id4 = find(x(2,:)>1.5);
id = unique([id1,id2,id3,id4]);
x(:,id) = []; 

%% plotting contour of prior
x1 = -2.25:.01:1.75; x2 = -1.5:.01:1.5;
[X1,X2] = meshgrid(x1,x2);
prior = exp(loggausspdf([X1(:) X2(:)]',mu,P));
prior = reshape(prior,length(x2),length(x1));
%prior = prior./sum(sum(prior));
figure(1),
contour(x1,x2,prior,10,'LineWidth',2);
hold on
%% plotting particles from prior
scatter(x(1,:),x(2,:),75,'*');
set(gcf, 'Color', 'w');
ax = gca;
set(ax,'xlim',[-2.25,1.75],'ylim',[-1.5,1.5]);
ax.Visible = 'off';
ax.FontSize = 25;
ax.LineWidth = 1;
[~,b] = legend('prior','particles','Location','northwest');
set(findobj(b,'-property','MarkerSize'),'MarkerSize',25);
set(findobj(b,'-property','LineWidth'),'LineWidth',2);
export_fig(gcf,'FontMode','fixed','FontSize',25,'Color','imp1.pdf','-nocrop');
hold off

%% plotting contour of posterior
x1 = -2.25:.01:1.75; x2 = -1.5:.01:1.5;
[X1,X2] = meshgrid(x1,x2);
posterior = exp(loggausspdf([X1(:) X2(:)]',obs,R) + loggausspdf([X1(:) X2(:)]',mu,P));
posterior = reshape(posterior,length(x2),length(x1));
% posterior = posterior./sum(sum(posterior));
figure(2),
contour(x1,x2,posterior,10,'LineWidth',2);
hold on
%% plotting particles from prior
scatter(x(1,:),x(2,:),75,'*');
set(gcf, 'Color', 'w');
ax = gca;
set(ax,'xlim',[-2.25,1.75],'ylim',[-1.5,1.5]);
ax.Visible = 'off';
ax.FontSize = 25;
ax.LineWidth = 1;
[~,b]= legend('posterior','particles','Location','northwest');
set(findobj(b,'-property','MarkerSize'),'MarkerSize',25);
set(findobj(b,'-property','LineWidth'),'LineWidth',2);
export_fig(gcf,'FontMode','fixed','FontSize',25,'Color','imp2.pdf','-nocrop');
hold off
%% plotting contour of posterior
figure(3),
contour(x1,x2,posterior,10,'LineWidth',2);
hold on
%% plotting  resampled particles from posterior
logW = loggausspdf(x,obs,R);
x= resampleRegularize(x,logW);
%x = x(:,logW == max(logW));
scatter(x(1,:),x(2,:),75,'*');
set(gcf, 'Color', 'w');
ax = gca;
set(ax,'xlim',[-2.25,1.75],'ylim',[-1.5,1.5]);
ax.Visible = 'off';
ax.FontSize = 25;
ax.LineWidth = 1;
txt1 = 'after resampling';
text(-0.5,-1,txt1,'FontSize',25);
[~,b] = legend('posterior','particles','Location','northwest');
set(findobj(b,'-property','MarkerSize'),'MarkerSize',25);
set(findobj(b,'-property','LineWidth'),'LineWidth',2);
export_fig(gcf,'FontMode','fixed','FontSize',25,'Color','imp3.pdf','-nocrop');
hold off