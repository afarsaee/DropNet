%% General Simulation Scenario
n_channel_total  = 110;  % #total  realizations
n_Training       =  10;  % #training  realization
n_Prediction     = n_channel_total - n_Training;
n_max_drop = 2;     % max #users that shall be dropped
mySNRdB = 10*log10(15);     % received SNR per user (dB)
mySNR = 10.^(mySNRdB/10);   % received SNR per user (dec)
Ptot = mySNR * n_user_ref;  % total power (dec)
% list of all possible combinations of users that shall be dropped
list_possible_two_out_of_K_users = nchoosek(1:n_user_ref,n_max_drop);
%% Specific CB parameters (bisection method convergence criteria)
if flag_ZF1_CB0_simulation == 0
    thr_error_post_SINR_CB = 1e-2;
    threshold_precision_SNR = 1e-2;
    Ptot_margin = 0.1;
    precision_sum_rate = 1e-2;
end
%% Initialization of Other Variables
if flag_ZF1_CB0_simulation == 1
    CDFsum_rate_ZF_NoDrop = zeros(n_channel_total,1);
    CDFsum_rate_ZF_EXH    = zeros(n_channel_total,1);
elseif flag_ZF1_CB0_simulation == 0
    CDFsum_rate_CB_NoDrop = zeros(n_channel_total,1);
    CDFsum_rate_CB_EXH    = zeros(n_channel_total,1);   
    iterations = zeros(n_max_drop+1,n_channel_total);
end
% repeat the simulation for a same channel for all the SNRs
% so we need to record the "Href" once, then repeat the sims
% for it:
Href                = zeros(n_Prediction,M_ant,n_user_ref);

% final index of class for the set of dropped users
index_final_to_be_written = zeros(n_channel_total,1);

% store ||h_i|| and |\rho_{ij}| for the Training
len_correlation = nchoosek(n_user_ref,2);
HHH_Train = zeros(n_channel_total,len_correlation);
HHH_norm2 = zeros(n_channel_total,n_user_ref);