% Author: Vedang Deshpande
% Date: 14th May 2019
% Training NN using non-linear filters
% Note: States here are the parameters of neural network
clc; clear; close all;
%% Initialize
load('data/trained_NN_complete_data.mat')
NN_EKF = NNconstruct(ni,Ln); % We will train this NN using EKF
% w_true = nn2param(NN); 
% NN_EKF = param2nn(NN_EKF,w_true);
NN_UKF = NN_EKF;
x0 = nn2param(NN_EKF); % Initial state
nx  = length(x0); % Number of states
ny = Ln(end); % Number of measurements = no. of o/p of NN
Inx  = eye(nx);
Ast = Inx; % State transition matrix is identity

var_meas = 0.01; % variance of measurement noise; sigma^2
var_proc = 0.05; % variance of process noise
var_initState = 1e6; % initial state covariance

P0 = var_initState*Inx; % Initial state covariance matrix
Q = var_proc*Inx; % Process noise covariance matrix
R = var_meas*eye(ny); % Measurements noise covariance matrix
y1 = y1(1:100);
yMeas = y1 + normrnd(0,var_meas,[length(y1),1]); % Synthetic Noisy measurements
kEnd = length(yMeas);
maxEpoch = 1;

%% EKF Code
x_prev = x0; % estimate of x(k-1)
P_prev = P0; 
yEKF=zeros(kEnd,maxEpoch);
for iEp = 1:maxEpoch
    fprintf('EKF: Epoch = %d.\n',iEp);
    fprintf('norm = %d.\n',norm(x_prev-x0)); 
    for k = 1:kEnd
    %     clc; 
    %     fprintf('EKF: Epoch = %d, k = %d.\n',iEp,k);

        % EKF Propagation/Prediction
        x_pr = Ast*x_prev; % x-(k) a priori state estimate
        P_pr = Ast*P_prev*Ast' + Q; % P-(k) a priori state covariance matrix

        % EKF Update
        NN_EKF =  param2nn(NN_EKF,x_pr); % Update parameters of the NN
        res = yMeas(k,1) - measModel(NN_EKF,iP(k,:)'); % Innovation/ Measurement residual
        H = nnJacobian(NN_EKF,iP(k,:)'); % Jacobian of measurement model w.r.t states (NN Params in this case)
        KK = P_pr*H'/(H*P_pr*H'+R); % Kalman Gain
        x_pst = x_pr + KK*res; % a posteriori state estimate
        P_pst = (Inx-KK*H)*P_pr; % a posteriori state covariance matrix

        x_prev = x_pst; 
        P_prev = P_pst; 
    %     
    %     NN_EKF = param2nn(NN_EKF,x_pst); % Update parameters of the NN
    %     yEKF(k,iEp) = measModel(NN_EKF,iP(k,:)');
    end
    % Evaluate o/p of NN using a posteriori parameters estimates at the end
    % of this epoch, for all input sets
    NN_EKF = param2nn(NN_EKF,x_pst); % Update parameters of the NN
    for k = 1:kEnd
        yEKF(k,iEp) = measModel(NN_EKF,iP(k,:)');
    end
end

%% UKF Code 
% Algorithm 3.1 from the Ref. paper

% Augmented state = [state; process_noise; measurement_noise]; 
procMean = zeros(nx,1); measMean = zeros(ny,1);
xAug0 = [x0;procMean;measMean];
PAug0 = diag([diag(P0);diag(Q);diag(R)]); 

xAug_prev = xAug0; 
PAug_prev = PAug0; 
yUKF=zeros(kEnd,maxEpoch);
for iEp = 1:maxEpoch
for k = 1:1
    clc; 
    fprintf('UKF k = %d.\n',k);
    
    [xAugSP,Wm,Wc] = getSigmaPts(xAug_prev,PAug_prev,0.1,0,2); % sigma pts of augemented state
    nPt = size(xAugSP,2); % no. of sigma pts
    xSP = xAugSP(1:nx,:); % sigma points of the actual state
    procSP =  xAugSP(nx+1:nx+nx,:); % sigma points of the process noise
    measSP = xAugSP(nx+nx+1:end,:); % sigma points of the measurement noise
    
    % UKF Time Update
    xSP_pr = xSP + procSP; % parameter dynamics with identity state transition matrix
    x_pr = xSP_pr*Wm'; % a priori state estimate = weighted sum of prior sigma pts
    tmpP1 = xSP_pr - x_pr; P_pr = zeros(nx,nx);
    for isp = 1:nPt
        P_pr = P_pr + Wc(isp)*(tmpP1(:,isp)*tmpP1(:,isp)');
    end
    
    ySP_pr = zeros(ny,nPt); % prior sigma pts of o/p
    for isp = 1:nPt
        NN_UKF = param2nn(NN_UKF,xSP_pr(:,isp)); % Update parameters of the NN
        ySP_pr(:,isp) = measModel(NN_UKF,iP(k,:)') + measSP(:,isp);
    end
    y_pr = ySP_pr*Wm'; % a priori o/p estimate
    
    % UKF Measurement Update
    Pyy = zeros(ny,ny); Pxy = zeros(nx,ny); 
    tmpP2 = ySP_pr - y_pr;
    for isp = 1:nPt
        Pyy = Pyy +  Wc(isp)*(tmpP2(:,isp)*tmpP2(:,isp)');
        Pxy = Pxy +  Wc(isp)*(tmpP1(:,isp)*tmpP2(:,isp)');
    end
    KK = Pxy/Pyy;
    res = yMeas(k,1) - y_pr;
    x_pst = x_pr + KK*(res);
    P_pst = P_pr - KK*Pyy*KK';
    
    xAug_prev = [x_pst;procMean;measMean];
    PAug_prev = [P_pst,                    zeros(nx,nx+ny);
                 zeros(nx,nx+ny)', diag([diag(Q);diag(R)])];
             
    % Evaluate o/p of NN using a posteriori parameters estimates
%     NN_UKF = param2nn(NN_UKF,x_pst); % Update parameters of the NN
%     yUKF(k,iEp) = measModel(NN_UKF,iP(k,:)');
end
    % Evaluate o/p of NN using a posteriori parameters estimates
    NN_UKF = param2nn(NN_UKF,x_pst); % Update parameters of the NN
    for k = 1:kEnd
        yUKF(k,iEp) = measModel(NN_UKF,iP(k,:)');
    end
end

%% Plot
figure(1); clf; hold on; box; grid;
plot(y1,'r','LineWidth',1) % Clean output
plot(yEKF,'b-','LineWidth',1) % Estimated using EKF
plot(yUKF,'g--','LineWidth',1) % Estimated using UKF
plot(yMeas,'k+','MarkerSize',3) % Noisy measurements
legend('Clean','EKF','UKF','Noisy')
set(gcf,'Position',[370,554,929,370])
% saveas(gcf,'plots/trainingUsingFilters.png')

figure(2); clf; hold on; box; grid;
plot(abs(yEKF-y1)./abs(y1),'b','LineWidth',1) % Estimated using EKF
plot(abs(yUKF-y1)./abs(y1),'g--','LineWidth',1) % Estimated using UKF
legend('EKF','UKF')
set(gcf,'Position',[368,118,933,347])