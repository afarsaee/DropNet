%% Ref for iterations
Inverse_Compl_mult = @(x) 6 * (((x^3)/2) + (1.5 * ((x^2)/2)));
Inverse_Compl_addd = @(x) 2 * (((x^3)/2) - (      ((x^2)/2)));
I_i_CB_No_Shadowing = [17.5994,16.9655,16.9595;... % K = 4
                 18.7121,17.5942,17.5061;...% K = 5             
                 19.8607, 18.2326, 17.9876;...% K = 6
                 20.9904, 18.9100, 18.4090;...% K = 7
                 22.1246, 19.6543, 18.8481;...%K = 8
                 23.2250, 20.5285, 19.3441;...% K = 9
                 24.2176, 21.4502, 19.8887;...%K = 10
                 25.1342, 22.4266, 20.5630;...%K = 11
                 25.9805, 23.3956, 21.3281;...%K = 12
                 26.7285, 24.3354, 22.1915;...%K = 13
                 27.3831, 25.2480, 23.0931;...%K = 14
                 27.9575, 26.0354, 23.9898]; %K = 15
%% find the empirical probability of dropping 'i' users
len_tot = length(n_drop_EXH);
len_K_user       = length(find(n_drop_EXH == 0))/len_tot; 
len_Kminus1_user = length(find(n_drop_EXH == 1))/len_tot; 
len_Kminus2_user = length(find(n_drop_EXH == 2))/len_tot;
len_avg_K = [len_K_user, len_Kminus1_user, len_Kminus2_user];
%% Finding the total complexity of CB (EXH)
cd data_ML_Complexity
load CB_EXH_2.txt
cd ..
dropping_complexity = CB_EXH_2(n_user_ref-3,2);

Precoding_Complexity = 0;
for i = 0:n_max_drop
   Precoding_Complexity = Precoding_Complexity + len_avg_K(i+1) * 8 * M_ant * (n_user_ref-i);
end
C_EXH = dropping_complexity + Precoding_Complexity; 
%% Finding the total complexity of ZF (CDA)
len_tot = length(n_drop_CDA);
len_K_user       = length(find(n_drop_CDA == 0))/len_tot; 
len_Kminus1_user = length(find(n_drop_CDA == 1))/len_tot; 
len_Kminus2_user = length(find(n_drop_CDA == 2))/len_tot;
len_avg_K = [len_K_user, len_Kminus1_user, len_Kminus2_user];

Precoding_Complexity = 0;
Power_Coeff = 0;
for i = 0:n_max_drop
   Precoding_Complexity = Precoding_Complexity + len_avg_K(i+1) * 8 * M_ant * (n_user_ref-i);
   Power_Coeff = Power_Coeff + len_avg_K(i+1) * (Inverse_Compl_addd(n_user_ref-i) + Inverse_Compl_mult(n_user_ref-i)) * I_i_CB_No_Shadowing(n_user_ref-3,i+1);
end
C_CDA = Precoding_Complexity + Power_Coeff;
%% Finding the total complexity of ZF (DropNet)
len_tot = length(n_drop_ML);
len_K_user       = length(find(n_drop_ML == 0))/len_tot; len_Kminus1_user = length(find(n_drop_ML == 1))/len_tot; len_Kminus2_user = length(find(n_drop_ML == 2))/len_tot;
len_avg_K = [len_K_user, len_Kminus1_user, len_Kminus2_user];
Precoding_Complexity = 0;
for i = 0:n_max_drop
   Precoding_Complexity = Precoding_Complexity + len_avg_K(i+1) * 8 * M_ant * (n_user_ref-i);
   Power_Coeff = Power_Coeff + len_avg_K(i+1) * (Inverse_Compl_addd(n_user_ref-i) + Inverse_Compl_mult(n_user_ref-i)) * I_i_CB_No_Shadowing(n_user_ref-3,i+1);
end
C_ML = Complexity_ML(n_user_ref,n_max_drop,layer,0) + Power_Coeff + Precoding_Complexity;
%% Reduction ratios
C_EXH/C_ML
C_ML/C_CDA