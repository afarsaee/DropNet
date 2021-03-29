clc
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CB Prediction for User Dropping %%
%% After running the code, you have
    % Plot the CDF of sum-rate for
        % Exhaustive Search
        % CDA dropping
        % DropNet
        % No Dropping
    % Plot #dropped users with
        % Exhaustive Search
        % CDA dropping
        % DropNet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization
rng('default');
addpath('func');          % adding the path for func
directory_path = 'Results_from_Python'; 
addpath(directory_path);  % adding the path for reading input from Python
addpath('Required_MatFile'); % adding the path for Required Matlab files
load H_predict.mat           % load the channel matrix to comptue sum-rate
Prediction_Sim_Par_Var_CB    % Initialize the variables/parameters for the simulation
%% Main Loop
% Repeat the simulation for n_channel realizations
for i_channel = 1:n_channel
   % read the channel matrix
   UL_Channel = squeeze(H_Predict(i_channel,:,:));
   DL_Channel = UL_Channel';
   HDL      = DL_Channel;
   %% CDA Dropping
   % read the channel
   H = HDL;
   % compute the channel norms (see CDA reference)
   channel_norm_values = sqrt(diag(H*H'));

   % drop the user according to the CDA paper
   [H_dropped, n_user_CDA] = Drop_user_MRT(H, Ptot, channel_norm_values, n_max_drop, precision_sum_rate,1);

   % find the number of dropped users
   n_drop_CDA(i_channel,1) = n_user_ref - n_user_CDA;

   % find the sum-rate after dropping
   [SINR_k_maxmin_CB_Proposed,~,~,Ptot_current_CB] = myCB_MAXMIN(size(H_dropped,1),H_dropped,Ptot,threshold_precision_SNR, Ptot_margin);
   % check if Bisection method accuracy is met
   % (that means, the difference between the SNR of users should not be
   % more than "thr_error_post_SINR_CB"
   if max(SINR_k_maxmin_CB_Proposed(:)) - min(SINR_k_maxmin_CB_Proposed(:)) > thr_error_post_SINR_CB
       error('error!');
   end
   % store the sum-rate for CDF plot and average
   Sumrate_CB_CDA = sum(log2(1+SINR_k_maxmin_CB_Proposed));
   sum_rate_CB_CDA = sum_rate_CB_CDA + Sumrate_CB_CDA;
   CDF_SumRate_CDA(i_channel)    = Sumrate_CB_CDA;
   %% Normal ZF: No Dropping
   % read the channel matrix
   H = HDL;
   % read the number of users
   n_user = n_user_ref;

   % find CB SNR
   [SINR_k_maxmin_CB_No_Drop,~,~,~] = myCB_MAXMIN(size(H,1),H,Ptot,threshold_precision_SNR, Ptot_margin);
   
   % check if Bisection method accuracy is met
   % (that means, the difference between the SNR of users should not be
   % more than "thr_error_post_SINR_CB"
   if max(SINR_k_maxmin_CB_No_Drop(:)) - min(SINR_k_maxmin_CB_No_Drop(:)) > thr_error_post_SINR_CB
       error('error!');
   end
   % store the sum-rate for CDF plot and average
   Sum_Rate_CB_No_Drop = sum(log2(1+SINR_k_maxmin_CB_No_Drop));
   sum_rate_CB_No_Drop = sum_rate_CB_No_Drop + Sum_Rate_CB_No_Drop;
   CDF_SumRate_ND(i_channel) = Sum_Rate_CB_No_Drop;
%% Exhaustive Search (read the true labels)
   % find the class associated with the set of dropped users
   index_to_be_dropped_not_decoded_EXH = Dropped_User_index(i_channel);
   % find the corresponding index
   if index_to_be_dropped_not_decoded_EXH >= 1 && index_to_be_dropped_not_decoded_EXH <= n_user_ref
       % when 1 user is dropped
       index_to_be_dropped_EXH = index_to_be_dropped_not_decoded_EXH;
   elseif index_to_be_dropped_not_decoded_EXH > n_user_ref
       % when 2 user are dropped
       index_to_be_dropped_EXH = two_dropped_reference_users(index_to_be_dropped_not_decoded_EXH - n_user_ref,:);
   else
       % when no user is dropped
       index_to_be_dropped_EXH = 0;
   end

   % read the channel
   H_optimal_dropping = HDL;
   
   % find the sum-rate
   if index_to_be_dropped_EXH == 0
       % no drop
       CDF_SumRate_EXH(i_channel) = Sum_Rate_CB_No_Drop;
       n_drop_EXH(i_channel) = 0;
   else
       % 1 or 2 users are dropped
       [CDF_SumRate_EXH(i_channel), ~] = find_sum_rate_ML_prediction_any_dropped_user_MRT(H_optimal_dropping, Ptot, index_to_be_dropped_EXH, threshold_precision_SNR, Ptot_margin);
       n_drop_EXH(i_channel) = length(index_to_be_dropped_EXH);
   end
   SumRate_EXH_Current = CDF_SumRate_EXH(i_channel);
   % update the sum-rate variable
   sum_rate_CB_EXH = sum_rate_CB_EXH + SumRate_EXH_Current;
   %% DropNet
   % read the index from DropNet
   index_to_be_dropped_not_decoded = vec_index_predict(i_channel);
   % find the class associated with the set of dropped users
   if index_to_be_dropped_not_decoded >= 1 && index_to_be_dropped_not_decoded <= n_user_ref
      index_to_be_dropped = index_to_be_dropped_not_decoded;
   elseif index_to_be_dropped_not_decoded > n_user_ref
       index_to_be_dropped  = two_dropped_reference_users(index_to_be_dropped_not_decoded - n_user_ref,:);
   else
      index_to_be_dropped = 0;
   end
   % find the sum-rate for the set of dropped users
   if index_to_be_dropped == 0
       % no drop
       SumRate_ML(i_channel) = Sum_Rate_CB_No_Drop;
       n_drop_ML(i_channel) = 0;
   else
       % when 1 or 2 users are dropped
       [SumRate_ML(i_channel), ~] = find_sum_rate_ML_prediction_any_dropped_user_MRT(H_optimal_dropping, Ptot, index_to_be_dropped, threshold_precision_SNR, Ptot_margin);
       n_drop_ML(i_channel) = length(index_to_be_dropped);
   end
end
%% Writing the Sum-Rate
Prediction_Writing_Results_CB
Find_Complexity_CB