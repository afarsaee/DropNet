%%  This function finds the (sub)set of users that maximizes the sum-rate with MRT
% Inputs:
    % H_in:                 input channel matrix
    % Ptot:                 input power
    % n_drop:               upto n_drop users will be dropped
    
% Outputs:
    % Sum_rate_out:   the maximum sum-rate among all the
	% index_active:  the set of active users
%%
function [Sum_rate_out, index_active, iterations_final] = Sum_rate_exhaustive_search_MRT(H_in, Ptot, n_drop, threshold_precision_SNR, threshold_post_SINR, Ptot_margin)
% read the number of users
   [n_user,~] = size(H_in);

% determine all the possible combinations (K-N_drop) out of K possibilities
% for the active users
   all_possible_cor_elements = nchoosek(1:n_user,n_user - n_drop);
   len_repeat_search = length(all_possible_cor_elements);

% initialize the sum-rate variable
   Sum_rate_search = zeros(1,len_repeat_search);
   iterations      = zeros(1,len_repeat_search);
%% main loop
% precision for the found sum-rate and SINR
% repeat finding the sum-rate
   for i_search = 1:len_repeat_search
       % determine the channel for the active users
        H_current = H_in(all_possible_cor_elements(i_search,:),:); 
        [SINR_k_maxmin_CB,iterations(i_search),~] = myCB_MAXMIN(size(H_current,1),H_current,Ptot,threshold_precision_SNR,Ptot_margin);
        if max(SINR_k_maxmin_CB(:)) - min(SINR_k_maxmin_CB(:)) > threshold_post_SINR
           error('error!');
        end
        
       % find the sum-rate corresponding the current set of active users
       Sum_rate_search(i_search)  = sum(log2(1+SINR_k_maxmin_CB));
   end
   
   % find the maximum sum-rate and the set of active users among all the searched ones
   [Sum_rate_out,ind_final] = max(Sum_rate_search);
   index_active = all_possible_cor_elements(ind_final,:);
   iterations_final = iterations(ind_final);
end