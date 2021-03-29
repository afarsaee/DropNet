clc
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ZF Prediction for User Dropping %%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization
rng('default');
addpath('func');         % adding the path for func
directory_path = 'Results_from_Python';
addpath(directory_path); % adding the path for reading input from Python
addpath('Required_MatFile');  % adding the path for Required Matlab files
load H_predict.mat            % load the channel matrix to comptue sum-rate
Prediction_Sim_Par_Var        % Initialize the variables/parameters for the simulation
%% Repeat the simulation for n_channel realizations
for i_channel = 1:n_channel
   % read the channel matrix
   UL_Channel = squeeze(H_Predict(i_channel,:,:));
   DL_Channel = UL_Channel';
   HDL      = DL_Channel;
   %% CDA
   % read the channel
   H = HDL;
   % compute the channel norms (see CDA reference)
   channel_norm_values = sqrt(diag(H*H'));
   
   % drop the user according to the CDA paper
   flag_cell_edge = 0;
   [H_dropped, n_user_CDA] = Drop_user_ZF(H, Ptot, channel_norm_values, flag_cell_edge, n_max_drop, 1);

   % find the number of dropped users
   n_drop_CDA(i_channel,1) = n_user_ref - n_user_CDA;

   % find the sum-rate after dropping
    % find the ZF filters
   UZF_non_normalized = pinv(H_dropped);
   sum_filter_norm2 = sum(diag(UZF_non_normalized'*UZF_non_normalized));
   SNR_ZF_CDA = Ptot/(sum_filter_norm2);
   % find the sum-rate
   Sum_Rate_ZF_CDA = n_user_CDA * log2(1+SNR_ZF_CDA);

   % store the sum-rate for CDF plot and average
   sum_rate_ZF_CDA = sum_rate_ZF_CDA + Sum_Rate_ZF_CDA;
   CDF_SumRate_CDA(i_channel) = Sum_Rate_ZF_CDA;
   %% Normal ZF: No Dropping
   % read the channel matrix
   H = HDL;
   
   % read the number of users
   n_user = n_user_ref;

   % find ZF sum-rate
   % find ZF filters
   UZF_non_normalized = pinv(H);
   sum_filter_norm2 = sum(diag(UZF_non_normalized'*UZF_non_normalized));
   SNR_ZF_No_Drop = Ptot/sum_filter_norm2;
   % find ZF sum-rate
   Sum_Rate_ZF_No_Drop = n_user_ref * log2(1+SNR_ZF_No_Drop);

   % store the sum-rate for CDF plot and average
   sum_rate_ZF_NoDrop = sum_rate_ZF_NoDrop + Sum_Rate_ZF_No_Drop;
   CDF_SumRate_ND(i_channel) = Sum_Rate_ZF_No_Drop;
   %% Exhaustive Search
   % read the channel
   H_optimal_dropping = HDL;
   % array to find the optimal #users to be dropped
   sum_rate_array = zeros(1,n_user_ref);
   SNR_array = zeros(1,n_user_ref);

   % loop to find the optimal #users to be dropped
   for i_array_to_be_dropped = 1:n_max_drop
       [sum_rate_array(i_array_to_be_dropped),SNR_array(i_array_to_be_dropped),index_active_temp] = Sum_rate_exhaustive_search(H_optimal_dropping, Ptot, i_array_to_be_dropped);
   end

   % the last index corresponds to the "no drop" case
   sum_rate_array(n_user_ref) = CDF_SumRate_ND(i_channel);
   SNR_array(n_user_ref)      = SNR_ZF_No_Drop;

   % find the optimal #users that are dropped --> maximum sum-rate achived
   [sum_rate_EXH_current,ind_dropped_optimal] = max(sum_rate_array);
   if ind_dropped_optimal ~= n_user_ref % if drop, update n_drop_EXH
       n_drop_EXH(i_channel) = ind_dropped_optimal;
   end
   SNR_final_Optimal = SNR_array(ind_dropped_optimal);

   % store the sum-rate for CDF plot and average
   sum_rate_ZF_EXH = sum_rate_ZF_EXH + sum_rate_EXH_current;
   CDF_SumRate_EXH(i_channel) = sum_rate_EXH_current;
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
       CDF_SumRate_ML(i_channel) = Sum_Rate_ZF_No_Drop;
   else
       % when 1 or 2 users are dropped
       [SumRate_ML_temp, ~] = find_sum_rate_ML_prediction_any_dropped_user(H_optimal_dropping, Ptot, index_to_be_dropped);
       n_drop_ML(i_channel)  = length(index_to_be_dropped);
       CDF_SumRate_ML(i_channel) = SumRate_ML_temp;
   end
end
%% Writing the results
Prediction_Writing_Results
Find_Complexity_ZF