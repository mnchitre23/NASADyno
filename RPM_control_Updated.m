function [servo_set] = RPM_control(is_running, rpm_des, rpm_sens, KV)
%   Function Documentation
%   
%   [Include documentation]
% 
%   Example:
%           
%   Inputs:
%           
%   Outputs:
%         
%   Follows:
%                PD Control Law (kP = 0.001, kD = 0.06)
%                       _______________
%            t_error   |               |   servo_set
%           ---------->|    System     |-------------->
%                      |_______________|
%       Updated:
%   Sam Kramer
%   Feb 21st, 2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Loop Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
    This section initiates the parameters to the function that will be
    necessary for its operation. The persistent function is the output
    memory of the system. This is in order to add the servo position
    adjustment to the previous servo position, it is stored in RAM and will
    need to be cleared before the beginning of each test.

        Last Updated:
    Sam Kramer
    Feb 21st, 2023
%}

% --Parameters
    persistent servo_out
    kP = 0.002;                     % Proportional gain
    kI = 0;                         % Integral gain (Set to 0, PD control)
    kD = 0.06;                      % Derivative gain

% --Other Parameters
    order = 3;                      % Order of output memory (time-steps)
    precision = 4;                  % Precision of the output signal
    volt = 14.8;                      % Motor input voltage (volts)
    max_rpm = KV * volt;            % Motor max rotational speed (RPM)
    servo_max = 1;                  % Max servo potentiometer position (ND)
    C = servo_max / max_rpm;        % Conversion factor (ND/RPM)

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %{
        [Include documentation]
    %}

    if (is_running == true)
        
        % --Error in RPM (Feedback)
             e_rpm = rpm_des - rpm_sens;        % RPM error 
            
        % --Calculate servo_adj from error (Multiply by plant)
            % Follows the P(s) = C/s where C is conversion factor
             servo_adj = C*kP*sign(e_rpm)*(e_rpm^2) + C*kI/2*(e_rpm^3) + C*kD*e_rpm;

        % --Saturate servo_adj to boundaries
            servo_adj = max(-0.05, servo_adj);    % Keeps above -0.25
            servo_adj = min(0.05, servo_adj);     % Keeps below +0.25 RPM
            
        % --Output new Wiper position by adding to previous WP value
            if (isempty(servo_out))
                
                servo_set = servo_adj;           % Set first value
                
            else
                
                servo_set = servo_out(1) + servo_adj;    % Add adj to prev 
                
            end
            
        % --Round to 3 decimal places and set servo_set boundaries
            servo_set = round(servo_set, precision,'decimals');
            servo_set = min(1, servo_set); 
            servo_set = max(0.301, servo_set);
            
        % --Store output of the loop in the WP_new vector
            servo_out = [servo_set, servo_out];
        
    elseif (is_running == false)
        
        % --Reset values once the test is complete
             servo_set = 0;
            servo_out = zeros(1, order);       % Reset WP_out variable 
        
    end % Control loop end
 
end % Function end