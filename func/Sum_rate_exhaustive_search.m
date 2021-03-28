%% 
% This function checks if there is any pair of users with a very high
% channel norm ||g_i||^2 --> for ZF or THP, a very high ||g_i||^2 causes a
% huge drop in the sum-rate --> Thus, better to drop users with a very high
% channel norm --> find an appropriate threshold to drop those users
% Inputs:
    % H_in:                 input channel matrix
    % Ptot:                 input power
    % n_drop:               upto n_drop users will be dropped
% Outputs:
    % Sum_rate_out:   the maximum sum-rate among all the
                        % combinations of dropped users
%%
function [Sum_rate_out, SNR_out, index_active] = Sum_rate_exhaustive_search(H_in, Ptot, n_drop)
% read the number of users
   [n_user,~] = size(H_in);

% determine all the possible combinations (K-N_drop) out of K possibilities
% for the active users
   all_possible_active_elements = nchoosek(1:n_user,n_user - n_drop);
   len_repeat_search = length(all_possible_active_elements);

% initialize the sum-rate variable
   Sum_rate_search = zeros(1,len_repeat_search);
   SNR_search      = zeros(1,len_repeat_search);

%% main loop
   for i_search = 1:len_repeat_search
       % determine the channel for the active users
        H_current = H_in(all_possible_active_elements(i_search,:),:); 
        
        % find the pseudo-inverse of the channel
        pinvH = pinv(H_current);
        % find the channel norms
        pinvH_norms = abs(diag(pinvH'*pinvH));
        % find the denum for the ZF SNR
        sum_pinv = sum(pinvH_norms);
        % find the sum-rate for the ZF with max-min power control for the
        % active users
        SNR_search(i_search) = Ptot/sum_pinv;
        Sum_rate_search(i_search)  = (n_user - n_drop) * log2(1 + SNR_search(i_search));
   end
   % find the maximum sum-rate among all the searched ones
   [Sum_rate_out,ind_final] = max(Sum_rate_search);
   SNR_out = SNR_search(ind_final);
   index_active = all_possible_active_elements(ind_final,:);
end