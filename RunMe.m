InstallMe

ADC_Clock = 2500e6;

SamplePeriod = 0.00001; % The duration over which to average

NumSamples = round(2500e6 * SamplePeriod);
divisionConst = 50;
batchSize = 25;
batches = NumSamples/batchSize;

%%
% Constants for conversion from ADC value to voltage

% Theoretical Values

Bit_Range = 4096;
ADC_Input_Offset = 0;
ADC_Input_Range = 1.2;
Output_Shift = 2048;

%%
% Values from emperical testing:
Bit_Range = 4096;
ADC_Input_Offset = -0.1139;
ADC_Input_Range = 1.2729;
Output_Shift = 2047;

