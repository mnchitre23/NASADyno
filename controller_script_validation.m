%% Control Function Test Cases
%{
    Used to test the control function that has been created. Will be used
    for the RPM and the torque control.

        Last Updated
    Sam Kramer
    Feb 8, 2023
%}


%% Brake controller Test Case

% --Setup
    clear; clc; format compact; close all;
    
% --Parameters
    t = 1:1000;
    time = 0:.01:10;
    t_des = 4;
    t_sens = 0;
    rpm_des = 5000;
    rpm_sens = 3500;
    WP_set = [];
    is_running = true;
    emergency = false;
    clear brake_control         % --Clear persistant data from memory
    
% --Simulate Brake control data 

    for i = 1:length(t)+1

        % --Call on function
            WP = brake_control(is_running, t_des, t_sens, rpm_des, rpm_sens, emergency);
            WP_set = [WP_set, WP];
            
        % --Inject random noise into t_sens data
            t_sens = t_sens + randi([-100, 100])/100;
        
        % --Simulate responses
            t_sens = WP / 16;
            if (rpm_sens <= rpm_des), rpm_sens = rpm_sens + 50; end
            
        % --Change t_des at time = 50 seconds
            if (i == 300), t_des = 7.5; end
            if (i == 450), t_des = 4.5; end
            %if (i == 800), emergency = true; end
            if (i == 875), is_running = false; end
        
    end
    
    
 % --Plot results 
    figure (1);
    plot(time,WP_set)
        hold on
        xlim([0 10])
        xlabel('Time (s)')
        ylabel('Wiper Position')
        grid on
        title('Validation of the brake controller using PI Control')
        legend('kP, kI = .1')
        
        
 %% RPM Controller Test Case
 
 % --Setup
    clear; clc; format compact; close all;
    
% --Parameters
    t = 1:100;
    time = 0:.1:10;
    is_running = true;
    emergency = false;
    rpm_des = 5000;
    rpm_sens = 0;
    servo_set = [];
    KV = 920;               % Realistic for DJI 2212 motor 
    clear RPM_control
    
    max_rpm = KV * 10;       % Motor max rotational speed (RPM)
    servo_max = 1;                  % Max servo potentiometer position (ND)
    C = servo_max / max_rpm;        % Conversion factor (ND/RPM)

% --Control simulation
    for i = 1:length(t)+1

        % --Call on function
            servo = RPM_control(is_running, emergency, rpm_des, rpm_sens, KV) ;
            servo_set = [servo_set, servo];
            
        % --Simulate response
             rpm_sens = servo/C;

        % --Change t_des at time = 50 seconds
            if (i == 30), rpm_des = 7500; end
            if (i == 45), rpm_des = 6000; end
            if (i == 60), emergency = true; end
            if (i == 70), emergency = false; is_running = true; end
            if (i == 87), is_running = false; end

    end
    
    plot(time,servo_set)