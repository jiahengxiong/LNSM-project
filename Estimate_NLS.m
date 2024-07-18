clc;clear all;close all;
load('tunnel_experiment_100kmh.mat');
parameters.numberOfAP = 10;
parameters.positionAP = zeros(10,3); % 10 AP [x,y]
for i = 1:10
    parameters.positionAP(i,1) = AP(1,i);
    parameters.positionAP(i,2) = AP(2,i);
    parameters.positionAP(i,3) = AP(3,i);
end
origin_AP = AP;
AP = AP(1:2,:)';

TYPE = 'TDOA';
ground_truth_tdoa = ground_truth;
cleared_tdoa = meas_tdoa;
nan_count = sum(isnan(meas_tdoa(1:9, :)), 1);
cols_to_delete = nan_count > 7;
cleared_tdoa(:, cols_to_delete) = [];
ground_truth_tdoa(:, cols_to_delete) = [];
%for i = 1:9
%    cleared_tdoa(i, :) = fillmissing(cleared_tdoa(i, :), 'makima');
%end


%% IMPLEMENT NLS
% We initialize the sigma of the TDOA measurments to 0.1 meters and we decide
% to use 1000 iterations for each timestep
% nls_1=zeros( size(rho_clear{1,:}, 2) , 2 );
% nls_2=zeros( size(rho_clear{2,:}, 2) , 2 );
% nls_3=zeros( size(rho_clear{3,:}, 2) , 2 );
% nls_4=zeros( size(rho_clear{4,:}, 2) , 2 );

parameters.NiterMax = 100000; % number updates
% R is not used since we are not in WLNS
% nls_meas contains the position coordinates after each time interval

% random initial position
initial_position = [149.940344788160, 1.58054713023068];
for i = 1:size(cleared_tdoa, 2)
    [ uHat , numberOfPerformedIterations,count ] = iterativeNLS( parameters , AP , TYPE , cleared_tdoa(:,i).', initial_position); 
    uHat = uHat( 1:numberOfPerformedIterations , : ); % this is the final estimate of NLS at the last iteration
    nls_tdoa(i,:) = uHat(end,:);
    if nls_tdoa(i, 1) < 170 && nls_tdoa(i, 1) > -0.2 && nls_tdoa(i, 2) < 4.5 && nls_tdoa(i, 2) > -4.5
        initial_position = uHat(end,:);
    end
end
outlier_index = false(size(nls_tdoa, 1), 1);
for i = 1:size(nls_tdoa, 1)
    if nls_tdoa(i, 1) > 170 || nls_tdoa(i, 1) < -0.2 || nls_tdoa(i, 2) > 4.5 || nls_tdoa(i, 2) < -4.5
        outlier_index(i) = true;
    end
end
nls_tdoa_filtered = nls_tdoa(~outlier_index, :);
ground_truth_tdoa = ground_truth_tdoa(1:2, :)';
ground_truth_tdoa = ground_truth_tdoa(~outlier_index, :);
%%
TYPE = 'AOA';
ground_truth_aoa = ground_truth(1:2, :);
initial_position = [149.940344788160, 1.58054713023068];
aoa_data = meas_aoa;
time = ground_truth(4, :);
global_aoa = aoa_data(1:10, :);
for i = 1:size(global_aoa, 1)
    global_aoa(i, :) = global_aoa(i, :) + APyaw(i); 
end
%process outlier
for i=1:size(global_aoa, 1)
    for j=1:size(global_aoa, 2)
        if ~isnan(global_aoa(i, j))
            if global_aoa(i, j) > 180
                global_aoa(i, j) = 180 - ( global_aoa(i, j) - 180);
            end
            if global_aoa(i, j) < -180
                global_aoa(i, j) = -180 - ( global_aoa(i, j) + 180);
            end
        end
    end
end

cleared_global_aoa = global_aoa;
nan_count = sum(isnan(global_aoa), 1);
cols_to_delete = nan_count > 8;
cleared_global_aoa(:, cols_to_delete) = [];
ground_truth_aoa(:, cols_to_delete) = [];
%normalized_aoa = mod(cleared_global_aoa, 360);
%normalized_aoa(normalized_aoa > 180) = normalized_aoa(normalized_aoa > 180) - 360;
cleared_global_aoa = deg2rad(cleared_global_aoa);

% x_AP = sum(AP(:, 2))/10;
% left_end = [min(AP(:, 1)), x_AP];
% right_end = [max(AP(:, 1)), x_AP];
% range_aoa = zeros(size(AP));
% for i = 1:size(AP, 1)
%     angle_left = atan2((left_end(1, 2) - AP(i, 2)), (left_end(1, 1) - AP(i, 1)));
%     angle_right = atan2((right_end(1, 2) - AP(i, 2)), (right_end(1, 1) - AP(i, 1)));
%     range_aoa(i, 1) = min(angle_left, angle_right);
%     range_aoa(i, 2) = max(angle_left, angle_right);
% end
% 
% for ap = 1:size(cleared_global_aoa, 1)
%     for t = 1:size(cleared_global_aoa, 2)
%         if ~isnan(cleared_global_aoa(ap, t))
%             if cleared_global_aoa(ap, t) > range_aoa(ap, 2)
%                 cleared_global_aoa(ap, t) = range_aoa(ap, 2);
%             elseif cleared_global_aoa(ap, t) < range_aoa(ap, 1)
%                 cleared_global_aoa(ap, t) = range_aoa(ap, 1);
%             end
%         end
%     end
% end



for i = 1:size(cleared_global_aoa, 2)
    [ uHat , numberOfPerformedIterations,count ] = iterativeNLS( parameters , AP , TYPE , cleared_global_aoa(:,i).', initial_position); 
    uHat = uHat( 1:numberOfPerformedIterations , : ); % this is the final estimate of NLS at the last iteration
    nls_aoa(i,:) = uHat(end,:);
    if nls_aoa(i, 1) < 170 && nls_aoa(i, 1) > -0.2 && nls_aoa(i, 2) < 4.5 && nls_aoa(i, 2) > -4.5
        initial_position = uHat(end,:);
    end
end

%outfier
outlier_index = false(size(nls_aoa, 1), 1);
for i = 1:size(nls_aoa, 1)
    if nls_aoa(i, 1) > 170 || nls_aoa(i, 1) < -0.2 || nls_aoa(i, 2) > 4.5 || nls_aoa(i, 2) < -4.5
        outlier_index(i) = true;
    end
end
nls_aoa_filtered = nls_aoa(~outlier_index, :);
ground_truth_aoa = ground_truth_aoa';
ground_truth_aoa = ground_truth_aoa(~outlier_index, :);


TYPE = 'AOA+TDOA';
ground_truth_aoa_tdoa = ground_truth(1:2, :);
initial_position = [149.940344788160, 1.58054713023068];
meas_aoa_tdoa = [deg2rad(global_aoa(1:10, :)); meas_tdoa];

%x_AP = sum(AP(:, 2))/10;
% left_end = [min(AP(:, 1)), x_AP];
% right_end = [max(AP(:, 1)), x_AP];
% range_aoa = zeros(size(AP));
% for i = 1:size(AP, 1)
%     angle_left = atan2((left_end(1, 2) - AP(i, 2)), (left_end(1, 1) - AP(i, 1)));
%     angle_right = atan2((right_end(1, 2) - AP(i, 2)), (right_end(1, 1) - AP(i, 1)));
%     range_aoa(i, 1) = min(angle_left, angle_right);
%     range_aoa(i, 2) = max(angle_left, angle_right);
% end
% for ap = 1:size(1, 10)
%     for t = 1:size(meas_aoa_tdoa, 2)
%         if ~isnan(meas_aoa_tdoa(ap, t))
%             if meas_aoa_tdoa(ap, t) > range_aoa(ap, 2)
%                 meas_aoa_tdoa(ap, t) = range_aoa(ap, 2);
%             elseif meas_aoa_tdoa(ap, t) < range_aoa(ap, 1)
%                 meas_aoa_tdoa(ap, t) = range_aoa(ap, 1);
%             end
%         end
%     end
% end


nan_count = sum(isnan(meas_aoa_tdoa), 1);
cols_to_delete = nan_count > 17;
meas_aoa_tdoa(:, cols_to_delete) = [];
ground_truth_aoa_tdoa(:, cols_to_delete) = [];
for i = 1:size(meas_aoa_tdoa, 2)
    [ uHat , numberOfPerformedIterations,count ] = iterativeNLS( parameters , AP , TYPE , meas_aoa_tdoa(:,i).', initial_position); 
    uHat = uHat( 1:numberOfPerformedIterations , : ); % this is the final estimate of NLS at the last iteration
    nls_aoa_tdoa(i,:) = uHat(end,:);
    if nls_aoa_tdoa(i, 1) < 170 && nls_aoa_tdoa(i, 1) > -0.2 && nls_aoa_tdoa(i, 2) < 4.5 && nls_aoa_tdoa(i, 2) > -4.5
        initial_position = uHat(end,:);
    end
end

outlier_index = false(size(nls_aoa_tdoa, 1), 1);
for i = 1:size(nls_aoa_tdoa, 1)
    if nls_aoa_tdoa(i, 1) > 170 || nls_aoa_tdoa(i, 1) < -0.2 || nls_aoa_tdoa(i, 2) > 4.5 || nls_aoa_tdoa(i, 2) < -4.5
        outlier_index(i) = true;
    end
end
nls_aoa_tdoa_filtered = nls_aoa_tdoa(~outlier_index, :);
ground_truth_aoa_tdoa = ground_truth_aoa_tdoa';
ground_truth_aoa_tdoa = ground_truth_aoa_tdoa(~outlier_index, :);

figure;
hold on;
plot(nls_tdoa_filtered(:,1),nls_tdoa_filtered(:,2),'*', Color='red');
plot(nls_aoa_filtered(:,1),nls_aoa_filtered(:,2),'+', Color='blue');
plot(nls_aoa_tdoa_filtered(:,1),nls_aoa_tdoa_filtered(:,2),'o', Color='green');
x_y = ground_truth(1:2, :);
x_coords = x_y(1, :);
y_coords = x_y(2, :);

plot(x_coords, y_coords, 'gs', Color='black');  

plot(origin_AP(1, :), origin_AP(2, :), '^'); 

grid on;

legend('TDOA','AOA', 'AOA+TDOA', 'Ground Truth', 'AP Position', 'FontSize', 10, 'Location', 'best');

xlabel('X(m)');
ylabel('Y(m)');
title('NLS Estimation of 100kmh');

RMSE_TDOA = calculateRMSE(nls_tdoa_filtered, ground_truth_tdoa);
RMSE_AOA = calculateRMSE(nls_aoa_filtered, ground_truth_aoa);
RMSE_AOA_TDOA = calculateRMSE(nls_aoa_tdoa_filtered, ground_truth_aoa_tdoa);

%Slalom
% RMSE_TDOA 6.9756 RMSE_AOA 7.7571 RMSE_AOA_TDOA 2.7947
% number of used position TDOA: 183/286 AOA 228/286 AOA_TDOA 250/286

%70KMH
% RMSE_TDOA: 0.5606 RMSE_AOA 4.5543 RMSE_AOA_TDOA 1.0452
% TDOA 120/336 AOA 142/336 AOA_TDOA 256/336

%100KMH
% RMSE_TDOA: 1.0072 RMSE_AOA 8.7185 RMSE_AOA_TDOA 1.2164
% TDOA 47/168 AOA 64/168 AOA_TDOA 117/168




