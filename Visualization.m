clear all;
close all;
clc;
load('tunnel_experiment_70kmh.mat');

x_y = ground_truth(1:2, :);
x_coords = x_y(1, :);
y_coords = x_y(2, :);

figure;
plot(x_coords, y_coords, '.'); 
hold on; 

plot(AP(1, :), AP(2, :), '^'); 

xlabel('X coordinate (m)');
ylabel('Y coordinate (m)');
title('Scatter Plot of Ground Truth Data of 70kmh');
grid on;

axis equal;

legend('Ground Truth', 'AP Position');
saveas(gcf, 'ground_truth_70kmh.png');


time = ground_truth(4, :);

figure;

hold on;
for i = 1:size(meas_tdoa, 1)-1
    plot(time-time(1), meas_tdoa(i, :), '.'); 
end
hold off;


xlabel('Time [s]');
ylabel('TDOA [m]');
title('TDOA Measurements Over Time 70kmh');
grid on;


ylim([-50, 100]);
saveas(gcf, 'TDOA_70kmh.png');




meas_aoa = meas_aoa;


time = ground_truth(4, :);


azimuth = meas_aoa(1:10, :);
elevation = meas_aoa(11:20, :);


figure;


subplot(2, 1, 1);
hold on;
for i = 1:size(azimuth, 1)
    plot(time-time(1), azimuth(i, :), '.'); 
end
hold off;
xlabel('Time [s]');
ylabel('AOA az. [deg]');
title('Azimuth Angle of Arrival 70kmh');
grid on;


subplot(2, 1, 2);
hold on;
for i = 1:size(elevation, 1)
    plot(time-time(1), elevation(i, :), '.'); 
end
hold off;
xlabel('Time [s]');
ylabel('AOA el. [deg]');
title('Elevation Angle of Arrival 70kmh');
grid on;


subplot(2, 1, 1);
ylim([-100, 100]);
subplot(2, 1, 2);
ylim([-50, 50]);
saveas(gcf, 'Local_AOA_70kmh.png');









aoa_data = meas_aoa; % 20 x 286
pitch_data = APpitch; % 1 x 10
yaw_data = APyaw; % 1 x 10


azimuth_data = aoa_data(1:10, :);
elevation_data = aoa_data(11:20, :);



figure;


subplot(2, 1, 1);
hold on;
for i = 1:size(azimuth_data, 1)
    plot(time-time(1), azimuth_data(i, :), '.'); 
end
hold off;
xlabel('Time [s]');
ylabel('AOA az. [deg]');
title('Azimuth Angle of Arrival local 70kmh');
grid on;


subplot(2, 1, 2);
hold on;
for i = 1:size(azimuth_data, 1)
    plot(time-time(1), azimuth_data(i, :) + APyaw(i), '.');
end
hold off;
xlabel('Time [s]');
ylabel('AOA el. [deg]');
title('Elevation Angle of Arrival global 70kmh');
grid on;
saveas(gcf, 'global_AOA_70kmh.png');


