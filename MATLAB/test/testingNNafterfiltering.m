% Author: Niladri Das
% Date: June 1, 2019
clc; clear; close all;
load('data/AllNN.mat');
load('data/trained_NN_complete_data.mat');
%% Performance on Testing data
% Gen testing data
% Out of 583 input data, 200 is used for training, the next 200 is used for
% testing.
y1 = y1(201:400);
kEnd = length(y1);
iP = iP(201:400,:); % Testing input data
% Initializing test output-data set
yEKFtest = zeros(length(y1),1);
yEnKFtest = zeros(length(y1),1);
yUKFtest = zeros(length(y1),1);
%% EKF Code: just for testing
for k = 1:kEnd
    yEKFtest(k) = measModel(NN_EKF,iP(k,:)');
end
disp('EKF Testing Done.')

%% EnKF Code: just for testing
for k = 1:kEnd
    yEnKFtest(k) = measModel(NN_EnKF,iP(k,:)');
end
disp('EnKF Testing Done.')

%% UKF Code: just for testing 
for k = 1:kEnd
    yUKFtest(k) = measModel(NN_UKF,iP(k,:)');
end
disp('UKF Testing Done.')

%% OT Code
% TO-DO

%% Save reference output-data and the NN output-data
yMeas = y1;
save('./data/testresults.mat','y1','yEKFtest','yEnKFtest','yUKFtest');

%% Plotting
figure(1); hold on; box; grid;
plot(yEKFtest(:),'b--','LineWidth',1);
plot(yEnKFtest(:),'k--','LineWidth',1);
plot(yUKFtest(:),'g--','LineWidth',1);
plot(y1(:),'r--','LineWidth',1);
drawnow;