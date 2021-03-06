clc
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ZF Dataset Generation for User Dropping %%
%% After running the code, you have
    % Training_Dropped_User_index.mat
    % Training_Abs_Rho.mat
    % Prediction_Abs_Rho.mat
    % Prediction_Dropped_User_index.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization
flag_ZF1_CB0_simulation = 1;    % '1' to simulate ZF, '0' to simulate CB
rng('default');
addpath('func');                % adding the path for func
addpath('Required_MatFile');    % adding the path for other Mfiles
%% Reading important information
LOS_Config      % Line-of-sight channel matrix configuration
Sim_Par_Var     % initialize variables for the simulation
%% Main Loop: Repeat the simulation for n_channel realizations
for i_channel = 1:n_channel_total
    %% generate the channel
    [channel_unit_norm,channel_norm_values,~,~] = mychannel_uplink_shadowing(M_ant, n_user_ref, f0, ...
                                                R_max, R_min, phi_min, phi_max, ...
                                                min_spacing_distance_user, spacing_array, ...
                                                flag_2D, plot_array, ...
                                                theta_min, theta_max, N_x);
%% normalize the channle vectors
    % find the channel norms normalized to the "channel_norm_200m"                     
	channel_norm_values = channel_norm_values/channel_norm_200m;
    % store the unit-norm channel vector
    DL_temp   = channel_unit_norm';
    % store the channel
    H_DL_normalized = diag(channel_norm_values) * DL_temp;
    % store the channel norms
    channel_norm       = channel_norm_values;
    % find the indices of unique |\rho_{ij}| from H*H'
    HHH_current_dummy  = triu(H_DL_normalized * H_DL_normalized');
    HHH_current        = find_rho_ij_complex(H_DL_normalized);
    ind_correlation    = find(HHH_current_dummy == 0);
    % store the |\rho_{ij}|
    HHH_Train(i_channel,:) = HHH_current(ind_correlation);
    % store ||h_i||
    HHH_norm2(i_channel,:) = channel_norm_values.^2;
    % store the Channel Matrix for the Prediction 
    % (required to compare the DropNet other dropping algorithms)
	if i_channel > n_Training
       Href(i_channel-n_Training,:,:) = H_DL_normalized';            % read the unit-norm row vector channel
    end
   %% Normal ZF: No Dropping
   % read the channel matrix
   H = H_DL_normalized;
   % read the number of users
   n_user = n_user_ref;
   
   % find ZF SNR (5)
   UZF_non_normalized = pinv(H);
   sum_filter_norm2 = sum(diag(UZF_non_normalized'*UZF_non_normalized));
   SNR_ZF_No_Drop = Ptot/(sum_filter_norm2);
   
   % find ZF sum-rate
   Sum_Rate_ZF_No_Drop = n_user_ref * log2(1+SNR_ZF_No_Drop);

   % update the CDF variable
   CDFsum_rate_ZF_NoDrop(i_channel,1) = Sum_Rate_ZF_No_Drop;
   %% Optimal Dropping Algorithm: Exhaustive Search
   % read the channel matrix
   H_optimal_dropping = H_DL_normalized;
   
   % store sum-rate to find #users that should be dropped
   sum_rate_array = zeros(1,n_user_ref);

   % loop to find the optimal #users to be dropped
   % store the best sum-rate for the best set of dropped users
   for i_array_to_be_dropped = 1:n_max_drop
       [sum_rate_array(i_array_to_be_dropped),~,~] = Sum_rate_exhaustive_search(H_optimal_dropping, Ptot, i_array_to_be_dropped);
   end

   % the last index corresponds to the "no drop" case
   sum_rate_array(n_user_ref) = Sum_Rate_ZF_No_Drop;

   % find the optimal #users that are dropped --> maximum sum-rate achived
   [sum_rate_EXH_current,ind_dropped_optimal] = max(sum_rate_array);
   %% Save Data Set for ML
   % Output classes:
   % No user dropped  --> Class 0
   % One user dropped --> Class 1 to Class n_user_ref 
   % Two users dropped--> Class n_user_ref+1 to Class nchoosek(n_user_ref,2) + n_user_ref+1 
   
   % indices to be written for ML
   help_index = zeros(1,n_user_ref);
   % find #users that are dropped
   if ind_dropped_optimal == n_user_ref
       % if no users is dropped, means no dropping!
       % save the index of the class
       index_final_to_be_written(i_channel) = 1; 
   else
       % if some users are dropped, first, find the set of active
           % users
       [~,~,index_active_temp] = Sum_rate_exhaustive_search(H_optimal_dropping, Ptot, ind_dropped_optimal);
       help_index(index_active_temp) = 1;
       % find the dropped users
       index_dropped_user = sort(find(help_index == 0));
       % now, we would like to give the class id corresponds 
           % to the set of found active users (K = n_user_ref)
                % (class 1 --> no drop)
                % class 2-K+1 --> drop 1 user
                % class K+2 - 1+K+(K,2) --> drop 2 users
        % if two users are dropped, then, find which of the two
            % users are dropped
       if ind_dropped_optimal == 2 
           % through the following loop, we find the set of active/dropped
               % users
           for i_dropped = 1:nchoosek(n_user_ref,2)
              % read each of possible set of dropped users
              read_indexes = list_possible_two_out_of_K_users(i_dropped,:);
              % check if the set of dropped users is found
              if read_indexes == index_dropped_user
                  % find the relative index 
                  ind_class = i_dropped;
                  break;
              end
           end
           % find the index of the class
           index_final_to_be_written(i_channel) = ind_class + n_user_ref + 1;
       elseif ind_dropped_optimal == 1
       % if only one user is dropped
           % save the index of the class when 1 user is dropped
           index_final_to_be_written(i_channel) = index_dropped_user + 1;
       end
   end
end
%% Print Results
Print_Results