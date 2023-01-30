function [numPlant, denomPlant] = motor_plant(motor_number,fs)
%   Function Documentation:
%
%   This will be a helper function that will be used to develop the
%   plant for the motor control of the final project. This will simply be
%   responsible for plant creation and not the control functions. 
% 
%       [numPlant, denomPlant] = motor_plant(motor_number, fs)
%
%   Inputs:
%           motor_number -- The selected motor number for parameter
%                           selection
%           fs -- Sample frequency of the Arduino itself, used for the
%                 discrete equation of the plant
%
%   Outputs:  
%           numPlant -- Discrete time motor plant tf numerator
%   
%           denomPlant -- Discrete time motor plant tf denominator
% 
%   Last Updated:
%   Sam Kramer
%   30 Jan, 2023

%%%%%%%%%%%%%%%%%%%%%%%%% Develop System Plant %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
    This section of the function will be used develop the plant that will
    be used for the RPM Controller. This will first select the parameters
    based on the motor number, then developing the open loop plant with the
    PID controller implemented. This assumes that the Kt = Ke of the motor. 

    Updated:
    Sam Kramer
    30 Jan, 2023
%}

% --Motor parameter selection
    L = 1.16 * 10^-3;   % Motor Inductance (Henry)
    j = 2.5*10^-5;      % Rotational inertia [CHECK BRAKE DOCUMENTATION]
    b = 1*10^-6;        % Tota rotational damping of motor
    
switch motor_number
    % Set motor RPM and kV parameters depending on test motor
    
    case 1
    
        % Motor is DJI phantom
        R = 0.117;      % Motor resistance (Ohms)
        kV = 920;       % Motor kV (RPM/volt)
        
    case 2
        
        % Motor is Tarot 4114
        R = 0.126;      % Motor resistance (Ohms)
        kV = 320;       % Motor kV (RPM/volt)
        
    case 3
        
        % Motor is Scorpion 
        R = 0.02;       % Motor resistance (Ohms)
        kV = 650;       % Motor kV (RPM/volt)
        
end

% --Controller Parameter selection
    kP = 1;             % Proportional gain
    kI = 1;             % Integral gain
    kD = 1;             % Derivative gain
    
% --Define PID controller
    PID_controller = pid(kP, kI, kD);       % controller in tf form
    
% --Define motor plant
    num = [0 0 0 1/kV];         
    denom = [L*j (R*j + L*b) (R*b + (1/kV)*(1/kV))];
    plant = tf(num, denom);

% --Define open-loop plant for system
    open_loop = PID_controller * plant;         % Open-loop plant for sys
   
%%%%%%%%%%%%%%%%%%%%%%%%% Develop LQR Controller %%%%%%%%%%%%%%%%%%%%%%%%%%
%{
    This section of the function will be used to develop the LQR controller
    and then will convert the data into a discrete time function.
    
    Updated:
    Sam Kramer
    16 Jan, 2023
%}

% --Convert plant from TF to State-Space equation
    [pNum, pDenom] = tfdata(open_loop,'v');     % Open-loop num and denom
    [a,b,c,d] = tf2ss(pNum,pDenom);             % Convert TF to State-Space

% --Develop Q and R constants for LQR equation
    Q = c'*c;                       % Performance constant
    R = 1;                          % Energy saving constant
    
% --Develop optimal gain for LQR feedback loop
    k = lqr(a,b,Q,R);               % LQR gain for feedback loop
    
% --Close loop plant
    A = a - b*k;
    [closedNum, closedDenom] = ss2tf(A,b,c,d);   % Closed loop TF plant
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Make plant DTF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
    This section of the script will make a discrete transfer function that
    will be exported as the final system plant. This will create the
    transfer function numerator and denominator arrays using the c2dm 
    function that is inherent to MATLAB.

    Updated:
    Sam Kramer
    30 Jan, 2023
%}

% --Discretize the plant
    [numPlant, denomPlant] = c2dm(closedNum, closedDenom, 1/fs, 'tustin');  
    
end