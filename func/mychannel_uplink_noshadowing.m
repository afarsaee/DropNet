%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This functions outputs an uplink channel %
% for LOS, it supports ULA and UPA (square array)
% Users are distributed uniformly in R^2, phi, and theta :)
%% Inputs:
% M:                                #antennas at the BS
% K:                                #users (single-antenna)
% f0_gig:                           carrier frequency in hz
% R_max:                            maximum radius of user
% R_min:                            minimum radius of user
% theta_min:                        minimum phi_angle (horizontal)
% theta_max:                        maximum phi_angle (horizontal)
% min_spacing_distance_user:        minimum allowable distance between users
% spacing_array:                    0.5 if half-wavelength spacing
% flag_2D:                          1 if you want a uniform planar array (square)
%% Outputs:
% channel_unit_norm:                uplink channel with unit norm column vectors
% channel_norm:                     channel norms of for the users
% path_loss_dB:                     path loss (channel norms squared) for each TX-RX antennas
% channel_nonnormalized:            non-normalized uplink channel matrix
%% Notes and References:
% For path-loss see:
                    % ETSI TR 138 901 V14.0.0 (2017-05) %
%%
function [channel_unit_norm,channel_norms_values,path_loss_dB,channel_nonnormalized] = mychannel_uplink_navid(M_ant,K_user,f0_gig,R_max,R_min,...
                    phi_min, phi_max, min_spacing_distance_user, spacing_array, flag_2D,plot_array, theta_min, theta_max, N_x_new)

%% Read the inputs
n_user = K_user;             % # single-antenna user
n_bs = M_ant;               % # bs antennas
gig = 10^9;             % giga = 10^9
cwave = 0.3 * gig;      % C: the speed of light
freq = f0_gig;          % the frequency in Ghz
w = 2*pi*freq;          % w = 2*pi*f
k = w/cwave;            % the wave number
lambda = cwave/freq;    % the wavelenght
% the minimum allowable spacing between the users in x dimension
min_x_spacing = max(lambda,min_spacing_distance_user);
% the minimum allowable spacing between the users in y dimension
min_y_spacing = max(lambda,min_spacing_distance_user);
% the minimum allowable spacing between the users in z dimension
min_z_spacing = max(lambda,min_spacing_distance_user);
%% Coordination of antennas: ULA or UPA...?
if flag_2D == 0
    %% if ULA --> antennas at x-axis, 
        % users at x-y plane (y > 0)
    % the coordination of the antennas in the linear array
    % antennas are located in x-direction
    % in x-direction: symmetric around 0
    % y of antennas is 0
    x_ant_coordinate_new = spacing_array * (lambda)*((1-n_bs)/2:n_bs/2);
    y_ant_coordinate_new = zeros(1,n_bs);
%% if UPA:
    % the UPA is located in 
    % first check that N_x and N_y are integer
elseif flag_2D == 1 && floor(n_bs/N_x_new) == n_bs/N_x_new
    N_y_new = n_bs/N_x_new;
    line_coordinate_x  = spacing_array * (lambda)*((1-N_y_new)/2:N_y_new/2);
    line_coordinate_y  = spacing_array * (lambda)*((1-N_x_new)/2:N_x_new/2);
    plane_coordinate = combvec(line_coordinate_x,line_coordinate_y);
    
    y_ant_coordinate_new = plane_coordinate(1,:);
    x_ant_coordinate_new = plane_coordinate(2,:);
else
    error('check the numebr of antennas');
end
%% Distributing the users uniformly in a sector
% distributed uniformly in R^2, and uniformly in phi
% and uniformly in theta
flag_user_spacing = 1;  % flag is true as long as the users do not meet the min spacing
while flag_user_spacing == 1
    % uniform distribution in R^2
    % generate a uniform random variable between [0,1]
    % then use "a" to generate R_user
    a = (R_min/R_max)^2;
    add_val = a + (1-a)*rand(1,n_user);
    R_user_raw = R_max * sqrt(add_val);
    % Sort the R to further check the min spacing
    [R_user,index_R_sorted] = sort(R_user_raw,'ascend');
    
    % phi uniformly distributed \in [\phi_min,\phi_max]
    phi_user_deg = phi_min + (phi_max-phi_min).*rand(1,n_user);
    theta_user_deg = theta_min + (theta_max-theta_min)*rand(1,n_user);
    % The location is found by:
    if flag_2D == 0
        % for ULA (1D) case
        % y > 0
        y_user_new = R_user .* sind(phi_user_deg);
        x_user_new = R_user .* cosd(phi_user_deg);
        z_UT = zeros(1,n_user);
    else
        % for UPA (2D) case
        % UPA located at x-z plane
        % y > 0
        y_user_new = R_user .* sind(theta_user_deg) .* sind(phi_user_deg);
        x_user_new = R_user .* sind(theta_user_deg) .* cosd(phi_user_deg);
        z_UT   = R_user .* cosd(theta_user_deg);
    end
    %% Check whether two users are very close to each other:
    % when both the dimensions of the users are closer than the min
    % spacing, then the users are really really close!
    % we avoid these scenarios! by repeating the generating the users
    y_user_difference_flag_new =  abs(diff(y_user_new)) <= min_x_spacing;
    x_user_difference_flag_new =  abs(diff(x_user_new)) <= min_y_spacing;
    h_UT_difference_flag   =  abs(diff(z_UT))   <= min_z_spacing;
    if sum(y_user_difference_flag_new.*x_user_difference_flag_new.*h_UT_difference_flag) == 0
        % if no co-located users:
    	flag_user_spacing = 0;
        y_user_new = y_user_new(index_R_sorted);
        x_user_new = x_user_new(index_R_sorted);
        z_UT       = z_UT(index_R_sorted);
    else
        % if at least two co-located users
    	flag_user_spacing = 1;
    end
end
%% Build the LOS components
channel_nonnormalized   = zeros(n_bs,n_user);
channel_unit_norm       = zeros(n_bs,n_user);
channel_norms_values            = zeros(1,n_user);
path_loss_dB            = zeros(1,n_user);
%% Main loop for the LOS path loss
for l_user = 1:n_user
    d_2D = sqrt( (y_user_new(l_user))^2 + (x_user_new(l_user))^2 );
    d_3D = sqrt( (z_UT(l_user))^2 + d_2D^2 );
    % Free-space path loss + Shadowing 
    path_loss_dB(l_user) = 20*log10((4*pi)/(cwave)) + 20*log10(d_3D) + 20*log10(f0_gig); 
    path_loss_dec = 10^(-path_loss_dB(l_user)/10);
    for i_antenna = 1:n_bs
        R_calculated_LOS = sqrt((z_UT(l_user))^2 +(y_user_new(l_user) - y_ant_coordinate_new(i_antenna))^2 + ( (x_ant_coordinate_new(i_antenna)-x_user_new(l_user))^2 ) );
        channel_nonnormalized(i_antenna,l_user) = sqrt(path_loss_dec) * exp(-1j*k*R_calculated_LOS);
    end
    channel_norms_values(l_user)         = norm(channel_nonnormalized(:,l_user));
    channel_unit_norm(:,l_user)  = channel_nonnormalized(:,l_user)/channel_norms_values(l_user);
end
%% Plotting the array
if plot_array == 1 && flag_2D == 0
   figure;
   plot(x_ant_coordinate_new,y_ant_coordinate_new,'b*');
   hold on;
   plot(x_user_new,y_user_new,'c*');
   xlabel('x');
   ylabel('y');
elseif plot_array == 1 && flag_2D == 1
   figure;
   ant_loc = combvec(x_ant_coordinate_new,y_ant_coordinate_new);
   x_ant_plot = ant_loc(1,:);
   z_ant_plot = ant_loc(2,:);
   y_ant_plot  = zeros(size(x_ant_plot));
   plot3(x_ant_plot,y_ant_plot, z_ant_plot, 'b*');
   hold on;
   plot3(x_user_new,y_user_new,z_UT, 'r*');
   xlabel('x');
   ylabel('y');
   zlabel('z');
   grid on
end
end