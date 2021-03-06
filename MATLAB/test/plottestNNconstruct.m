clc;clear;close all;
load('data/oP.mat'); % Normalized real output data 
load('data/y1.mat'); % NN output
load('data/X.mat');
X = X(1:400,1);
% Normalize the data
X = (X - min(X))./(max(X)-min(X));



ns = size(oP,1);

h1 = plot(oP);
h1.LineWidth = 1.0;
h1.Color = 'b';
h1.LineStyle = '-.';
h1.Marker = 'o';
h1.MarkerEdgeColor = 'k';
h1.MarkerFaceColor = 'g';
h1.MarkerSize = 5;


hold on;
h2 = plot(y1);
h2.LineWidth = 1.0;
h2.Color = 'red';
h2.LineStyle = '-.';
h2.Marker = 'square';
h2.MarkerEdgeColor = 'k';
h2.MarkerFaceColor = 'red';
h2.MarkerSize = 5;

ax = gca;
ax.FontSize = 30;
ax.XLabel.String = 'Time';
ax.YLabel.String = 'Value';
%ax.XTick = 1:2:ns;
%ax.YTick = 0:1:6;
%ax.XLim = [1 ns];
%ax.YLim = [0 6]; 

legend('real', 'NN');

hold on;

keyboard
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
%print(fig, '-dpdf', './plotlemma7.pdf');
print(fig, '-depsc', './plots/mkglass.eps');
