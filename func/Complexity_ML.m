%% This function computes the complex computations required for 
%% ML algorithm to find the dropped users
%% inputs: 
        % n_max: the maximum number of users that is allowed to be dropped
        % n_user: totla number of users
        % layer_in: an array contains the layers with their number of
        % nodes, example:
            % [l_1,l_2] --> two layers with l_1 nodes in layer 1 and l_2
            % nodes in layer 2
%% outputs:
        % ES_ML: complexity of the exhaustive search for a given n_user,
        % n_max
function ES_ML = Complexity_ML(n_user, n_max,layer_in, complex_flag)
% the base complexity is the complexity of finding an inverse of a ixi
% matrix
n_layer = length(layer_in);
ES_ML = 0;
if complex_flag == 0
    l_0 = nchoosek(n_user,2) + n_user;
else
    l_0 = 2 * nchoosek(n_user,2) + n_user;
end
l_final = 0;
for j = 0:n_max
    l_final = l_final + nchoosek(n_user,j);
end
%%
l_array = [l_0,layer_in,l_final];
for j = 1:n_layer+1
    ES_ML = ES_ML + (l_array(j)+l_array(j)) * l_array(j+1);
end
end