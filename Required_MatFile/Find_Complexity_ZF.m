%% Required routines for finding the complexity of Pinv
% Look at Floating Point Operations in Matrix-Vector Calculus
% (Version 1.3) Raphael Hunger, page 14
Inverse_Compl_mult = @(x) 6 * (((x^3)/2) + (1.5 * ((x^2)/2)));
Inverse_Compl_addd = @(x) 2 * (((x^3)/2) - (      ((x^2)/2)));
%% find the empirical probability of dropping 'i' users
len_tot    = length(n_drop_EXH);
len_K_user = length(find(n_drop_EXH == 0))/len_tot; 
len_Kminus1_user = length(find(n_drop_EXH == 1))/len_tot; 
len_Kminus2_user = length(find(n_drop_EXH == 2))/len_tot;
len_avg_K  = [len_K_user, len_Kminus1_user, len_Kminus2_user];
%% Finding the total complexity of ZF (EXH)
cd data_ML_Complexity
load ZF_EXH_2.txt
cd ..
dropping_complexity = ZF_EXH_2(n_user_ref-3,2);

% filter computation, finding precoding vector, finding dropped users
Complexity_pinv = 0;
Precoding_Complexity = 0;
% Pinv(H) = H^H (HH^H)^{-1} 
    % complexity includes --> inverse of (HH^H) and 
                           % --> multiplication of H^H and (HH^H)^{-1}
for i = 0:n_max_drop
   Complexity_pinv      = Complexity_pinv + len_avg_K(i+1) * (Inverse_Compl_mult(n_user_ref-i) + Inverse_Compl_addd(n_user_ref-i) + 8*M_ant*((n_user_ref-i)^2));
   Precoding_Complexity = Precoding_Complexity + len_avg_K(i+1) * 8 * M_ant * (n_user_ref-i);
end
finding_U_complexity = Complexity_pinv + Precoding_Complexity;
C_EXH = dropping_complexity + finding_U_complexity; 
%% Finding the total complexity of ZF (CDA)
len_tot = length(n_drop_CDA);
len_K_user       = length(find(n_drop_CDA == 0))/len_tot; 
len_Kminus1_user = length(find(n_drop_CDA == 1))/len_tot; 
len_Kminus2_user = length(find(n_drop_CDA == 2))/len_tot;
len_avg_K = [len_K_user, len_Kminus1_user, len_Kminus2_user];

Complexity_pinv = 0;
Precoding_Complexity = 0;
for i = 0:n_max_drop
   Complexity_pinv = Complexity_pinv + len_avg_K(i+1) * (Inverse_Compl_mult(n_user_ref-i) + Inverse_Compl_addd(n_user_ref-i) + 8*M_ant*((n_user_ref-i)^2));
   Precoding_Complexity = Precoding_Complexity + len_avg_K(i+1) * 8 * M_ant * (n_user_ref-i);
end
C_CDA = finding_U_complexity + Precoding_Complexity;
%% Finding the total complexity of ZF (DropNet)
len_tot     = length(n_drop_ML);
len_K_user  = length(find(n_drop_ML == 0))/len_tot; 
len_Kminus1_user = length(find(n_drop_ML == 1))/len_tot; 
len_Kminus2_user = length(find(n_drop_ML == 2))/len_tot;
len_avg_K   = [len_K_user, len_Kminus1_user, len_Kminus2_user];

Complexity_pinv = 0;
Precoding_Complexity = 0;
for i = 0:n_max_drop
   Complexity_pinv = Complexity_pinv + len_avg_K(i+1) * (Inverse_Compl_mult(n_user_ref-i) + Inverse_Compl_addd(n_user_ref-i) + 8*M_ant*((n_user_ref-i)^2));
   Precoding_Complexity = Precoding_Complexity + len_avg_K(i+1) * 8 * M_ant * (n_user_ref-i);
end
C_ML = Complexity_ML(n_user_ref,n_max_drop,layer,0) + finding_U_complexity + Precoding_Complexity;
%% Reduction ratios
C_EXH/C_ML
C_ML/C_CDA