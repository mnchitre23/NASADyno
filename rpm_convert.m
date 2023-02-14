function rpm_sens = rpm_convert(tach_data)
%   Function description:
% 
%   [Include documentation]
%
%       Last Updated:
%   Sam Kramer
%   Feb 13th, 2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --Parameters
    rpm_max = 10000;            % Maximum RPM range [change this based on max RPM set]
    voltage_max = 5;            % Maximum voltage output
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
    This section of the code will be a filter function for the raw ADC
    voltage values that are sensed by the Tachometer to remove noise and
    get a higher accuracy of the data.
    
    Last Updated:
        Team Member: Sam Kramer
        Date: 
%}



%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calculate rpm_sens %%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
    [Include Documentation]
%}
    
% --Calculate rpm_sens
    rpm_sens = (tach_data / voltage_max) * rpm_max;
    
end % End of Function