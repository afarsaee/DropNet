clc
clear all
close all
%% This code finds the computational complexity of
% a) exhaustive search for CB and ZF
% b) using Neural Network (real value neural network)
% Note 1:
    % for CB and ZF, please take a look at
    % "Floating Point Operations in Matrix-Vector Calculus"
            % (Version 1.3) Raphael Hunger, page 14
% Note 2: 
    % for CB, a number of iterations have to be set,
        % we used the average number of iterations found by another
        % simulations (CB precoding using bisectoin method to find the
                                        % power control coefficients)
%% Parameters
addpath('func\');
flag_complex = 0;       % 0: if you used |rho| as in paper, 1: if you'd like to use \rho (complex)
flag_write = 0;         % if you'd like to save the data
K_max = 10;
K_min = 4;
K_ref = K_min:K_max;
n_max = 2;
n_sim = K_max - K_min + 1;
%% Variables to store the computational complexity of dropping algorithms
C_EX_ZF = zeros(1,n_sim);
C_EX_CB = zeros(1,n_sim);
l_power = 4:11;
l_1_ref = 2.^(l_power);
n_l = length(l_power);
C_ML = zeros(n_l,n_sim);
%% macros for finding the complexity of CB and ZF
Inverse_Compl = @(x) (16/3)*(x^3);

Inverse_Compl_mult = @(x) 6 * (((x^3)/2) + (3 * ((x^2)/2)));
Inverse_Compl_addd = @(x) 2 * (((x^3)/2) - (      ((x^2)/2)));

Complex_MRT   = @(x) 4*(x^3) + 8*(x^2) + x;
%% Lookup table for bisection method required iterations
% I_i_MRT found by simulation/ when 0 (col 1), 1 (col 2), 2 (col 3) users are dropped
                    % found for 64 x K MIMO
% 20m-200m, 10K realizations of the channel, No Shadowing
shadowing_flag = 0;
I_i_MRT_No_Shadowing = [17.5994,16.9655,16.9595;... % K = 4
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
%% Main Loop
for i_l = 1:n_l
    l_1 = l_1_ref(i_l);
    for i = 1:n_sim
        K = K_ref(i);
        %% find ML complexity
        C_ML(i_l,i) = Complexity_ML(K,2,l_1,flag_complex);
        %% find EX complexity
        if i_l == 1
            for j = 0:n_max
                C_EX_ZF(i) = C_EX_ZF(i) + Inverse_Compl(K-j) * nchoosek(K,j);
                C_EX_CB(i) = C_EX_CB(i) + (K-j+ Inverse_Compl_mult(K-j) + Inverse_Compl_addd(K-j))   * nchoosek(K,j) * I_i_MRT_No_Shadowing(i,j+1);
            end
        end
    end
end
%% plotting the final results (Fig. 3 of the paper)
figure;
plot(K_ref, C_EX_ZF);
hold on;
plot(K_ref,C_EX_CB);
for j = 1:n_l
    plot(K_ref, C_ML(j,:));
end
set(gca, 'YScale', 'log')
legend('ZF','CB');
%% Writing the results
if flag_write == 1
    for i_dummy = 1:1
        cd data_ML_Complexity
            %%
            name_EXH_ZF = sprintf('ZF_EXH_%d.txt',n_max);
            name_EXH_CB = sprintf('CB_EXH_%d.txt',n_max);
            
            fEX_ZF = fopen(name_EXH_ZF,'w');
            fEX_CB = fopen(name_EXH_CB,'w');
            for i = 1:n_sim
               fprintf(fEX_ZF,'%d %2d\n', K_ref(i) ,C_EX_ZF(i));
               fprintf(fEX_CB,'%d %2d\n', K_ref(i) ,C_EX_CB(i));
            end
            fclose(fEX_ZF);
            fclose(fEX_CB);
            %% writing the ML results
            for j = 1:n_l
                if flag_complex == 0
                    name_ML  = sprintf('ML_%d_%d_abs.txt',   l_1_ref(j),n_max);
                else
                    name_ML  = sprintf('ML_%d_%d_realimage.txt',   l_1_ref(j),n_max);
                end
                fML = fopen(name_ML,'w');
                for i = 1:n_sim
                   fprintf(fML,'%d %d\n', K_ref(i) ,C_ML(j,i));
                end
                fclose(fML);
            end
        cd ..
    end
end