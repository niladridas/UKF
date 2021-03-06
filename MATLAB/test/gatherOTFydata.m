% Author: Niladri Das
% Date: June 1, 2019
% Gathering the OT data
clc; clear; close all;
D1 = load('./data/OTF_ref_1_to_5.mat');
D2 = load('./data/OTF_ref_6_to_10.mat');
D3 = load('./data/OTF_ref_11_to_15.mat');
D4 = load('./data/OTF_ref_16_to_20.mat');

% yOTF is the OT filter output data set
% dim(yOTF) = 200x10x20 : 10 epochs and 20 repititions
[samples,epochs,rep] = size(D1.yOTF);
% We have 2 sets of data: total 10 repititions 
yOTF = zeros(samples,epochs,rep);
yOTF(:,:,1:5) = D1.yOTF(:,:,1:5);
yOTF(:,:,6:10) = D2.yOTF(:,:,6:10);
yOTF(:,:,11:15) = D3.yOTF(:,:,11:15);
yOTF(:,:,16:20) = D4.yOTF(:,:,16:20);
save('./data/OTF_ref.mat','yOTF');

