%% Prepare data to be save for Training
% feature vector
Abs_Rho            = zeros(n_channel_total,nchoosek(n_user,2) + n_user_ref);
% class corresponds to the feature vector
Dropped_User_index = zeros(n_channel_total,1);
%% Loop over the samples to prepare features and corresponding class
% corresponding class should start from 0 (python friendly!)
for i_dum = 1:1
    n_write = n_channel_total;
    for i = 1:n_write
           HHH       = HHH_Train(i,:);           
           Pathloss = HHH_norm2(i,:);
           HHH_abs   = abs(HHH);
           Abs_Rho(i,:) = [HHH_abs,Pathloss];
           Dropped_User_index(i) = index_final_to_be_written(i)-1;
    end
end
%% Save variables in mat files
Dropped_User_index_temp = Dropped_User_index;
Dropped_User_index = Dropped_User_index_temp(1:n_Training);
save('Training_Dropped_User_index.mat','Dropped_User_index');

Dropped_User_index = Dropped_User_index_temp(1+n_Training:end);
save('Prediction_Dropped_User_index.mat','Dropped_User_index');

Training_Abs_Rho   = Abs_Rho(1:n_Training,:);
Prediction_Abs_Rho = Abs_Rho(n_Training+1:end,:);

save('Training_Abs_Rho.mat', 'Training_Abs_Rho');
save('Prediction_Abs_Rho.mat', 'Prediction_Abs_Rho');

% save the channel matrix for prediction 
% (comparing with other dropping algorithm)    
H_Predict = squeeze(Href(1:end,:,:));

% clear other variables to free memory
clearvars -except H_Predict
save('H_predict.mat','H_Predict');