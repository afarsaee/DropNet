%% find the average sum-rate
sum_rate_ZF_NoDrop  = sum_rate_ZF_NoDrop/n_channel;
sum_rate_ZF_CDA     = sum_rate_ZF_CDA/n_channel;
sum_rate_ZF_EXH     = sum_rate_ZF_EXH/n_channel;
%% displaying the avg sum-rate
display(['avg Optimal   = ',num2str(sum_rate_ZF_EXH)]);
display(['avg Old CDA   = ',num2str(sum_rate_ZF_CDA)]);
display(['avg ZF normal = ',num2str(sum_rate_ZF_NoDrop)]);
%% showing the number of dropped users
figure;
cdfplot(n_drop_EXH);
hold on;
cdfplot(n_drop_CDA);
cdfplot(n_drop_ML);
legend('EXH','CDA', 'ML');
title('number of dropped users');
%% Plotting the CDFs
figure;
h1 = cdfplot(CDF_SumRate_EXH);
CDF_EXH_val = get(h1,'YData');
CDF_EXH     = get(h1,'XData');

hold on
h5 = cdfplot(CDF_SumRate_ML);
CDF_ML_val = get(h5,'YData');
CDF_ML     = get(h5,'XData');

h2 = cdfplot(CDF_SumRate_CDA);
CDF_CDA_val = get(h2,'YData');
CDF_CDA     = get(h2,'XData');

hNDA = cdfplot(CDF_SumRate_ND);
CDF_NDA_val = get(hNDA,'YData');
CDF_NDA    = get(hNDA,'XData');
legend('EXH', 'ML','CDA', 'ND');    
title('CDF of sum-rate for the dropping algorithms');
%% Writing the Sum-Rate
if flag_write == 1
    cd(directory_path)
    for i_dummy = 1:1
            %%
            name_EXH    = sprintf('CDF_Sumrate_EXH_%d_%d.txt',M_ant,n_user_ref);
            fEXH      = fopen(name_EXH,'w');
            n_CDF_write = 1000;
            
            n_write = length(CDF_EXH);
            n_step = floor(n_write/n_CDF_write);
            for i = 3:n_step:n_write
               fprintf(fEXH,'%0.6f %2.6f\n',        CDF_EXH(i), CDF_EXH_val(i));
            end
            fclose(fEXH);
            %% Write CDA data
            name_ML     = sprintf('CDF_Sumrate_ML_%d_%d_%d_%d.txt',   M_ant,n_user_ref, layer, abs_flag);
            fML       = fopen(name_ML,'w');
            n_write = length(CDF_ML);
            n_step = floor(n_write/n_CDF_write);
            for i = 3:n_step:n_write
               fprintf(fML,'%0.6f %2.6f\n',         CDF_ML(i) , CDF_ML_val(i));
            end
            fclose(fML);
            %% Write data for CDA
            name_CDA    = sprintf('CDF_Sumrate_CDA_%d_%d.txt',   M_ant,n_user_ref);
            fCDA = fopen(name_CDA,'w');
            n_write = length(CDF_CDA);
            n_step = floor(n_write/n_CDF_write);
            for i = 3:n_step:n_write
               fprintf(fCDA,'%0.6f %2.6f\n',   CDF_CDA(i) ,CDF_CDA_val(i));
            end           
            fclose(fCDA);
        cd ..
    end
end