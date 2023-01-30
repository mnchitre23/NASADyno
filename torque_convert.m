function torque_sensed = torque_convert(sensor_data)
% Function description:
%       
%   This function will be used to calculate the torque that is being
%   sensed from the reaction torque sensor. It will take in the mV/V data
%   and then calculate the data to torque measurements in lb-in. This can
%   handle both data vectors and single double data types. This uses linear
%   interpolation to calculate the torque on the motor. The linear data is
%   using the calibration data supplied with the sensor. 
%
%   Example:
%               torque_sensed = torque_convert(sensor_data)
%
%   Inputs:
%           sensor_data -- This is the mV/V measurement that is being used
%                          to calculate the torque. This is the direct
%                          reading coming from the torque sensor. Can be an
%                          array or a single integer.
%
%   Outputs:
%           torque_sensed -- This is the sensed torque that has been
%                            calculated by the function using the sensor
%                            data collected by the torque sensor. Outputs a
%                            measurement in lb-in data from -20 to 20
%                            lb-in.
%
%   Function last updated:
% Sam Kramer
% 30 Jan, 2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --Parameters
    excitation_voltage = 10;            % Excite Voltage applied to sensor
    M = [.101907 .101914];              % Slopes of mV to Torque graphs.
    B = [-0.00006817 -.000156699];      % Intercepts of linear torque slope
    

% --Convert input signal(mV) to the mV/V range
    %{
        This part of the function will convert the mV sensed measurement to
        a mV/V measurement that can be linearly fit from the given
        calibration data from the company. Follows eaquation for conversion
        which is: mV/V = mV_signal / excitation voltage

            Last updated:
        Sam Kramer
        Jan 30, 2023
    %}
    mVV = sensor_data ./ excitation_voltage;    % Convert to mV/V
    
% --Convert from the mV/V data to the torque measurement
    %{
        This part of the function linearly fits on to the calibration curve
        that was given when the sensor was purchased. If the sensor is 
        calibrated to mV/V_signal = torque*M + B then to find torque this 
        function will do (signal - B)/M = torque.
        
            Last Updated:
        Sam Kramer
        Jan 30, 2023
    %}
    conversion_factor = mean(M);        % mV to lb-in conversion factor
    adj = sign(sensor_data).*mean(B);   % Intercept of the linear relation
    torque_sensed = (mVV - adj) ./ conversion_factor; 
    
end