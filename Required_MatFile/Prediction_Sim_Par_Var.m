% Read the prediction results
load predictions_OneL_14shadowing_abs_newnormalization.mat
abs_flag = 1;  % we use |\rho_{ij}| as the features
layer = 14;    % #layers for DropNet
%% flags in the code
flag_write = 1;         % write the results? yes:1, no: 0
[n_Prediction,M_ant,n_user_ref] = size(H_Predict);
n_channel = n_Prediction;
%% SNR config.
mySNRdB = 10*log10(15);
mySNR = 10.^(mySNRdB/10);
Ptot = mySNR * n_user_ref;
%% Variables to store the sum-rate
CDF_SumRate_ND = zeros(1,n_Prediction);
SNR_ND      = zeros(1,n_Prediction);

SumRate_ML = zeros(1,n_Prediction);
CDF_SNR_ML      = zeros(1,n_Prediction);

CDF_SumRate_EXH = zeros(1,n_Prediction);

CDF_SumRate_CDA    = zeros(1,n_Prediction);
% specify the maximum number of users to be dropped
n_max_drop = 2;
% all the sets of dropped users
two_dropped_reference_users = nchoosek(1:n_user_ref,2);
%% variables
sum_rate_ZF_NoDrop  = 0;
sum_rate_ZF_CDA     = 0;
sum_rate_ZF_EXH     = 0;
sum_rate_ZF_ML      = 0;
% record the number of dropped users
n_drop_EXH    = zeros(n_channel,1);
n_drop_CDA    = zeros(n_channel,1);
n_drop_ML = zeros(n_channel,1);