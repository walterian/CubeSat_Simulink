% Copyright (c) 2014, Analog Devices Inc. 
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright
% notice, this list of conditions and the following disclaimer.
%
% 2.Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

classdef AD9625_sysobj < matlab.System & ...
                         matlab.system.mixin.Propagates & ...
                         matlab.system.mixin.CustomIcon
    % System Object behavioral model for Analog Devices' High-Speed ADCs
    % Notes:
    %   - The Resolution dropdown filters the ADC options
    %   - In the name of the ADC is the maximum sampling clock, be sure
    %     to adjust your sampling clock accordingly.
   
    properties (Nontunable)
        % Operating Mode
        Mode = 'ADC Only';
        
        % DDC Decimation
        Decimation = '8';
        
        % DDC Gain
        Gain = '0';
                
        % NCO Frequency
        NcoFreq = 'maskNcoFreq';
        %NcoFreq = '0';
        
        % Sampling Clock Frequency
        Fclk = 2500e6;
        
        % Mean Frequency
        Tessitura = 2.3e6;
        
        % RMS Clock Jitter
        ExtJitter = 60e-15;
        
        % Input Configuration
        InputConfig = 'Normalized';
    end
       
    properties (Access = private)
        pm;         % MOTIF Object
        poffset;    % ADC Offset
        prange;     % ADC Range
        pmodelName = 'AD9625_2500';
    end
    
    properties (Constant, Hidden)
        ModeSet = matlab.system.StringSet({'ADC Only', 'ADC + DDC'});
        DecimationSet = matlab.system.StringSet({'8', '16'});
        GainSet = matlab.system.StringSet({'0', '6', '12', '18'});
        InputConfigSet = matlab.system.StringSet({'Normalized', 'Absolute'});
    end
    
    properties (DiscreteState)
    end
    
    methods
        % Constructor
        function obj = AD9625_sysobj(varargin)
            % Support name-value pair arguments when constructing the
            % object.
            
            % Add MOTIF path
            %modelPath = get_param(gcs,'FileName');
            %modelFolder = fileparts(modelPath);
            %resourcesFolder = fullfile(modelFolder, 'MOTIF');
            %addpath(resourcesFolder);
            
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl
            header = matlab.system.display.Header(mfilename('class'),...                
                'Title','System Object for an ADC',...
                'Text','This is a behavioral model of an ADC.',...
                'ShowSourceLink',false);
        end     
    end
    
    methods (Access = protected)
        %% Common functions
        function setupImpl(obj)
            % Implement tasks that need to be performed only once,
            % such as pre-computed constants.
            obj.pm = MOTIF_if(['MOTIF/' obj.pmodelName '.pmf']);
            
            if (~obj.pm.isLoaded())
                disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
                return
            end
            
            % Set the mode
            if strcmp(obj.Mode, 'ADC Only')
                obj.pm.setMode('mode1');
            else
                obj.pm.setMode('mode2');
            end
            
            % Get maximum sampling rate, and coerce if necessary
            clkmax = str2double(obj.pm.getProp('settings', 'clkmax'));
            if obj.Fclk > clkmax
                fclk = clkmax;
                warning('Sampling Rate was too high, coerced to maximum for this device');
            else
                fclk = obj.Fclk;
            end
            
            % Push simulation properties to MOTIF
            obj.pm.setProp('GLOBAL', 'fclk', num2str(fclk));
            obj.pm.setProp('GLOBAL', 'tessitura', num2str(obj.Tessitura));
            obj.pm.setProp('settings', 'extjitter', num2str(obj.ExtJitter));
            
            if strcmp(obj.InputConfig, 'Normalized')
               obj.poffset = str2double(obj.pm.getProp('settings', 'offset'));
               obj.prange = str2double(obj.pm.getProp('settings', 'range'));
            else
                obj.poffset = 0;
                obj.prange = 2;
            end
            
            if strcmp(obj.Mode, 'ADC + DDC')
               obj.pm.setProp('ddc', 'm', obj.Decimation);
               obj.pm.setProp('ddc', 'gain', obj.Gain);
               obj.pm.setProp('nco', 'freq', obj.NcoFreq);
            end
        end
             
        function y = stepImpl(obj, u)
            % Implement algorithm. Calculate y as a function of
            % input u and discrete states.            
            uprime = u * obj.prange / 2 + obj.poffset;
            y = obj.pm.runSamples(uprime);
        end
        
        function releaseImpl(obj)
            % Initialize discrete-state properties.
            obj.pm.destroy();
        end
        
        % This method controls visibility of the object's properties
        function flag = isInactivePropertyImpl(obj, propertyName)
            %if strcmp(propertyName, 'Decimation') || ...
            %   strcmp(propertyName, 'Gain') || ...
            %   strcmp(propertyName, 'NcoFreq')           
            %    flag = strcmp(obj.Mode, 'ADC Only');
            %else
            flag = false;
            %end
        end        
        
        function icon = getIconImpl(obj)
            % Extract generic name from file name
            idx = strfind(obj.pmodelName, '_');
            
            if ~isempty(idx)
                generic = obj.pmodelName(1:idx(1)-1);
            else
                generic = obj.pmodelName;
            end

            icon = sprintf(generic);
        end     
             
        function dataout = getOutputDataTypeImpl(~)
            dataout = 'double';
        end

        function sizeout = getOutputSizeImpl(obj)
            if strcmp(obj.Mode, 'ADC Only')
                d = 1;
            else
                d = str2num(obj.Decimation);
            end
            
            sz = 64 / d;
            sizeout = [sz 1];
        end

        function cplxout = isOutputComplexImpl(obj)
            if strcmp(obj.Mode, 'ADC Only')
                cplxout = false;
            else
                cplxout = true;
            end
        end

        function fixedout = isOutputFixedSizeImpl(~)
            fixedout = true;
        end
        
        function num = getNumInputsImpl(~)
           num = 1; 
        end
        
        function varargout = getInputNamesImpl(obj)
            numInputs = getNumInputs(obj);
            varargout = cell(1,numInputs);
            varargout{1} = 'in (V)';
        end        
        
        function varargout = getOutputNamesImpl(~)
            varargout = cell(1,1);
            varargout{1} = 'out (Code)';
        end    
    end
end
