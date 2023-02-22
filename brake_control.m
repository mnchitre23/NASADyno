function WP_set = brake_control(is_running, t_des, t_sens, rpm_des, rpm_sens, emergency)
% Function Description:
% 
%   This will be a function that will be used to control the current that
%   is being run to the Hysteresis brake by changing the wiper position of
%   the digital pontentiometer. To do this, a PI controller is used. 
%
%   The wiper position of the system will not be adjusted until error_RPM
%   reaches less than 5%, once this condition is met the brake will begin
%   to increase torque by a maximum of .5 in-lbs. Once the motor RPM error
%   reaches less than 2.5%, the control algorithm will begin to be more
%   aggressive by adjusting by 1 in-lbs. 
% 
%   If the emergency stop button is pressed, the torque will increase to
%   about 12 in-lbs in order to stop the motor instantly and then the user
%   must turn off the test to reset the emergency stop.
%   
%   Example:
%           wiper_position = brake_control(is_running, t_des, t_sens, rpm_des, rpm_sens, emergency)
%   
%   Inputs:
%           is_running -- Boolean that tell system if the test has been
%                         started
%           t_des -- Desired torque to system
%           t_sens -- Sensed torque on the system
%           rpm_des -- Desired RPM of the test motor
%           rpm_sens -- Sensed RPM of the test motor
%           emergency -- Bool that tells system that emergency stop was
%                        pressed
%
%   Outputs:
%           wiper_position -- Wiper position of the digital potentiometer
%
%   Follows:
%                   PI Controller, where we selected kP, kI = .1
%                       _______________
%            t_error   |               |   WP_set
%           ---------->|    System     |-------------->
%                      |_______________|
% 
%       Last Updated
%   Sam Kramer
%   Feb 8th, 2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Loop Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
    This section initiates the parameters to the function that will be
    necessary for its operation. The persistent function is the output
    memory of the system. This is in order to add the wiper position
    adjustment to the previous wiper position, it is stored in RAM and will
    need to be cleared before the beginning of each test. The kP and kI are
    the controller gains. The error in RPM is for the system to not start
    until there is a threshold in RPM error reached.

        Last Updated:
    Sam Kramer
    Feb 8th, 2023
%}

% --Control Parameters
    persistent WP_out
    kP = .5;                        % Proportional gain
    kI = .1;                        % Integral gain
    
% --Physical parameters
    t_max = 16;                     % Max torque output (in-lbs)
    WP_max = 255;                   % Max wiper position (ND)
    C = WP_max / t_max;             % Conversion factor (ND/in-lbs)
    order = 3;                      % Order of output memory (time-steps)
    
% --Error in RPM
    e_rpm = 100* (rpm_des - rpm_sens)/rpm_des;    % RPM error percentage
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
    This is the actual control function and it uses a feedback control
    method with a PI controller. The gains are set in the parameters. There
    are 3 if statements which cause the function not to run until the test
    begins and the rpm error reaches that critical threshold. In the case
    of an emergency stop, the emergency if statement is tripped and then
    the motor is cut. The last else statement will set the WP = 0. 

        Last Updated:
    Sam Kramer
    Feb 8, 2023
%}

% --If statement
    if (is_running == true && e_rpm <= 5 && emergency == false)
        
        % --Calculate torque error and store it in WP_in
            t_error = t_des - t_sens;      % Calculate torque error

        % --Calculate WP_adj from error
            % Follows the P(s) = C/s where C is conversion factor
            WP_adj = (C*kI)*(t_error ^ 2)*sign(t_error) + kP*C*t_error; 

        % --Saturate WP_adj to be within -25 and +25 WP output
            WP_adj = max(-8, WP_adj);      % Keeps above -48 WP
            WP_adj = min(8,WP_adj);        % Keeps below +48 WP
            
        % --Output new Wiper position by adding to previous WP value
            if (isempty(WP_out))
                
                WP_set = WP_adj;                % Set first value
               
            else
                
                WP_set = WP_out(1) + WP_adj;    % Add adj to prev value
        
            end
            
        % --Round and set boundaries
            WP_set = round(WP_set);         % Rounds to a whole int
            WP_set = min(255, WP_set);
            WP_set = max(0, WP_set);
            
        % --Store output of the loop in the WP_new vector
            WP_out = [WP_set, WP_out];
                
    elseif (is_running == true && e_rpm <= 2 && emergency == false)
        
        % --Calculate torque error and store it in WP_in
            t_error = t_des - t_sens;      % Calculate torque error

        % --Calculate WP_adj from error
            % Follows the P(s) = C/s where C is conversion factor
            WP_adj = (C*kI)*(t_error ^ 2)*sign(t_error) + kP*C*t_error; 

        % --Saturate WP_adj to be within -16 and +16 WP output
            WP_adj = max(-16, WP_adj);      % Keeps above -16 WP
            WP_adj = min(16,WP_adj);        % Keeps below +16 WP
            
        % --Output new Wiper position by adding to previous WP value
            if (isempty(WP_out))
                
                WP_set = WP_adj;                % Set first value
               
            else
                
                WP_set = WP_out(1) + WP_adj;    % Add adj to prev value
        
            end
            
        % --Round and set boundaries
            WP_set = round(WP_set);         % Rounds to a whole int
            WP_set = min(255, WP_set);
            WP_set = max(0, WP_set);
            
        % --Store output of the loop in the WP_new vector
            WP_out = [WP_set, WP_out];
   
    elseif (emergency == true && is_running == true)
        
        % --Emergency stop feature
            WP_set = 200;    
            
    else
        
        % --Reset values once the test is complete
            WP_set = 0;
            WP_out = zeros(1, order);       % Reset WP_out variable 
        
    end     % Control loop end
    
end     % Function end