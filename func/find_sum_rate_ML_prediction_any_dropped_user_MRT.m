function [Sum_rate_out_suboptimal, SNR_out_suboptimal] = find_sum_rate_ML_prediction_any_dropped_user_MRT(H_in, Ptot, index_dropped_desired, threshold_precision_SNR, Ptot_margin)
% read the number of users
   [n_user, n_bs] = size(H_in);
   if index_dropped_desired ~= 0
       n_dropped_user = length(index_dropped_desired);
   else
       n_dropped_user = 0;
   end
   H_in_extended = [H_in;zeros(n_dropped_user,n_bs)];
   %% Now find the Sum-rate and SNR for the desired dropped user
   index_active = ones(1,n_user);
   index_active(index_dropped_desired) = 0;
   ind_read = find(index_active == 1);
   H_current = H_in(ind_read,:);
   
   n_active = n_user - n_dropped_user;
   
   [SNR_out_suboptimal,~] = myCB_MAXMIN(n_active,H_current,Ptot,threshold_precision_SNR, Ptot_margin);
   Sum_rate_out_suboptimal      = sum(log2(1+SNR_out_suboptimal));
end