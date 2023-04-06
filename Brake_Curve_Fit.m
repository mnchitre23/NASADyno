%% Electric Hysteresis Brake Torque vs. Current Curve Fitting
%{
    This script will be used for the curve fitting and function generation
    of the current vs. torque curve that is provided with the brake. This
    will help determine the amount of torque that is being applied by the
    brake by the amount of current being supplied. To do this a polyfit
    must be done to generate the proper polynomial relationship between the
    two.

    Sam Kramer
    Jan 30, 2023
%}

% --Setup
    clear;clc;close all; format compact;

% --Parameters
    current_points = [20 70 80 110 110 130 140 150 160 170 180 190 230 250 ...
                        270 320 200 190 310 300 250 310 30 40 290 ...
                        240 210 215 250 260 190 275 315 300 280 120 ...
                        90 80 100 100 70 60 60 50 85 50 120 ...
                        150 140 160 90 130 200 170 180 95 95 ...
                        85 55];
    torque_points =  [00 .1 .3 0.5 0.7 0.8 1.0 1.4 1.3 1.7 1.6 1.7 2.3 2.3 ...
                        2.4 2.6 2.1 1.7 2.6 2.55 2.4 2.58 0.0 0.0 2.5...
                        2.2 1.975 2.2 2.4 2.45 1.95 2.5 2.58 2.58 2.52 0.9 ...
                        0.4 .16 0.4 0.55 0.195 0.1 0.04 0.025 0.2 0.001 0.65 ...
                        1.15 1.21 1.55 0.26 1.05 1.85 1.45 1.83 0.31 0.48 ...
                        0.35 0.02];
    Nm_Inlbs_conversion = 8.850;

% % --Plot data points
%     figure(1)
%     plot(current_points, torque_points, '*');
%         grid on
%         hold on
%         xlabel('Current (mA)')
%         ylabel('Torque (Nm)')
        
% --Convert data from Nm to in-lbs
    torque_points = torque_points .* Nm_Inlbs_conversion;
    
% --Plot new data
    figure(2)
    plot(current_points, torque_points,'.');
        grid on
        hold on
        xlabel('Current (mA)')
        ylabel('Torque (in-lbs)')
        
% --Fit data using polyfit
    P = polyfit(current_points, torque_points, 5);
    
% --Plot the polyfit data on the same plot to see the fit
    x = 0:1:350;
    A = P(1).*(x.^5) + P(2).*(x.^4) + P(3).*(x.^3) + P(4).*(x.^2) + P(5).*(x) + P(6);
    plot(x,A)
        xline(146)
        yline(10)
        
% --Fprintf data
    fprintf('The coefficiencts for the data are \n %3.5f, %3.5f, %3.5f %3.3f, %3.3f, %3.3f \n', P(1), P(2), P(3), P(4), P(5),P(6))
