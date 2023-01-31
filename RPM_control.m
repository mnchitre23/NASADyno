function v_out = RPM_control(is_running, v_des, v_in, plantNum, plantDenom)
%   Function Documentation
%   
%   This will be the function that will be used to calculate control the
%   motor during the acoustic testing of the test motor. This function will
%   rely upon the other helper function motorPlant() that will come with
%   this function. This will be responsible for the calculation of the
%   control voltages of the motor.
%
%               [v_out] = RPM_control(v_in, plantNum, plantDenom)
%
%   Inputs:
%           v_in -- The input voltage that is either the desired input to
%                   the system or the input data from the laser tachometer
%           plantNum -- This is the plant numerator of the motor. 
%                       This is a discrete time TF plant.
%           plantDenom -- This is the plant denominator of the motor. This
%                         is a discrete time TF plant.
%
%           is_running -- This is a bool that is used to designate if the
%                         tests are running.
%
%   Outputs:
%           v_out -- The output voltage that will be output from the
%                    Arduino pin to the motor to be controlled.
% 
%   Follows:
%                       _______________
%            error(z)  |               |  V_control(z)
%           ---------->| Trnsfr Fnc(z) |-------------->
%                      |_______________|
%   
%       Updated:
%   Sam Kramer
%   30 Jan, 2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --Control Parameters for system
    %{
        The persistant functions are called because they will need to be
        remembered by the function after each loop in order to properly
        loop through and utilize the Z-domain plant.

            Updated:
        Sam Kramer
        30 Jan, 2023
    %}
    persistent v_control_in v_control_out order
    
    order = length(plantDenom);         % Order of the control function
    v_control_in = zeros(1, order);     % Initialize v_control variable
    v_control_out = zeros(1, order);    % Initializee control_out variable
    first_step = true;

% --Control loop
    %{
        This part of the code will provide the actual voltage calculations
        for the control of the data. v_control_in is stored because the
        data needs to be stored in order to complete the z-domain discrete
        transfer function. The loop is tripped when the test is running so
        the bool is_running will be = 1. If there is no data saved, then
        v_out = v_desired, if there is data saved, then there will be a
        control law.

            Updated:
        Sam Kramer
        21 Jan, 2023
    %}

    if (is_running == true)
        %{
            This if statement is meant to be the actual control flow of the
            control calculations. If the test is not running, then the
            control of the voltage is not needed. The first_step is a
            boolean that will control if there has already been a first
            output signal to the motor. If there has already been signals
            running to the motor, the elseif statement will be triggered
            and the voltage will be controlled.
        
                Updated:
            Sam Kramer
            Jan 30, 2023
        %}
        
        if (first_step == true) 
            
            v_out = v_des;          % Output desired if first iteration
            first_step = false;     % Set bool to false to start control
            
        elseif (first_step == false)
        
            % --Calculate error of the motor RPM
                error = v_des - v_in;       % Calcualtes the error in RPM 

            % --Store error in error memory array
                v_control_in = [error, v_control_in(1:order - 1)]; 

            % --Create new control values for voltage
                v_out = v_control_in * plantNum - v_control_out(1:end-1) * plantDenom(2:4);

            % --Store control out values 
                v_control_out = [v_out, v_control_out(1:order - 1)];
    
        end % Nested if statement end
        
    end % If statement end

 
end%%%%%%%%%%%%%%%%%%%%%%%%%%% Function End %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%