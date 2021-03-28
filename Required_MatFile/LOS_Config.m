%% LOS channel configuration
M_ant = 9; % #antennas at the BS
N_x = 3;   % #antenna at x-axis, note, for UPA, M_ant = N_x * N_y, for ULA, M_ant = N_x
n_user_ref = 4; % #user
flag_2D = 1; % ULA '0' or UPA '1'
plot_array = 0; % turn off the plot for channel realizations
gig = 10^9; c = 0.3 * gig; f0 = 30*gig; lambda = c/f0; % frequency config.
R_min = 10; R_max = 200;   % min and max distance of users to the BS
phi_min = 0; phi_max = 360; % min and max phi(0,360)
min_spacing_distance_user = lambda; % min spacing distance between the users
spacing_array = 0.5;        % inter-element spacing of elements
theta_min = 0; theta_max = 90;       % min and max theta
%% Set up the channel for the cell-edge users
[channel_unit_norm_test,channel_norm_values_test,~,~] = mychannel_uplink_noshadowing(M_ant, n_user_ref, f0, ...
                                                200, 200, phi_min, phi_max, ...
                                                min_spacing_distance_user, spacing_array, ...
                                                flag_2D, plot_array, ...
                                                theta_min, theta_max, N_x);
% save the channel norm when the users are at the cell-edge                
channel_norm_200m = channel_norm_values_test(1);