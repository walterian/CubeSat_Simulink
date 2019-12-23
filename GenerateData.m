% ice_voltage = [];
% rock_voltage = [];
%
% for count = 1:5
%     icey = load(['data/ice_voltage' num2str(count) '.mat']);
%     rocky = load(['data/rock_voltage' num2str(count) '.mat']);
%     fieldice = struct2cell(icey);
%     fieldrock = struct2cell(rocky);
%     ice_voltage = cat(2, ice_voltage, fieldice{1});
%     rock_voltage = cat(2, rock_voltage, fieldrock{1});
% end




for count = 1:2
    load(['data/ice_voltage' num2str(count) '.mat']);
    load(['data/rock_voltage' num2str(count) '.mat']);
%     fieldice = struct2cell(ice_voltage);
%     fieldrock = struct2cell(rock_voltage);
%     ice_voltage = fieldice(1,1);
%     rock_voltage = fieldrock(1,1);
%     ice_voltage = ice_voltage';
%     rock_voltage = rock_voltage';
    ice_voltage = vi_icebase;
    rock_voltage = vi_rockbase;
    
    set_param('Radiometer_System_Model', 'SimulationCommand', 'start')
%     blockice = 'Radiometer_System_Model/iceworkspace';
%     blockrock = 'Radiometer_System_Model/iceworkspace';
%     rtoice = get_param(blockice, 'RuntimeObject');
%     rtorock = get_param(blockrock, 'RuntimeObject');
%     time = rtoice.OutputPort(1).Data;
%     time = rtoice.OutputPort(1).Data;
%     zHLRx=time';


end