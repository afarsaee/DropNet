function [Sum_rate_out_suboptimal, SNR_out_suboptimal] = find_sum_rate_ML_prediction_any_dropped_user(H_in, Ptot, index_dropped_desired)
% read the number of users
   [n_user, n_bs] = size(H_in);
   if index_dropped_desired ~= 0
       n_dropped_user = length(index_dropped_desired);
   else
       n_dropped_user = 0;
   end
   H_in_extended = [H_in;zeros(n_dropped_user,n_bs)];
   %% Now find the Sum-rate and SNR for the desired dropped user
   index_active_dummy = ones(1,n_user+n_dropped_user);
   index_active_dummy(index_dropped_desired) = 0;
   ind_read = find(index_active_dummy == 1);
   H_current = H_in_extended(ind_read,:);
   % find the pseudo-inverse of the channel
   pinvH = pinv(H_current);

   % find the channel norms
   pinvH_norms = abs(diag(pinvH'*pinvH));

   % find the denum for the ZF SNR
   sum_pinv = sum(pinvH_norms);

   % find the sum-rate for the ZF with max-min power control for the
   % active users
   SNR_out_suboptimal = Ptot/sum_pinv;
   Sum_rate_out_suboptimal      = (n_user - n_dropped_user) * log2(1 + SNR_out_suboptimal);
end