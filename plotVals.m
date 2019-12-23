rock = load('Rock.mat');
ice = load('Ice.mat');
rock = rock.ans;
ice = ice.ans;
rock = delsample(rock,'Index',1);
ice = delsample(ice,'Index',1);


figure; 
hold on; % holds the axes
iceplot = plot(ice.Time, reshape(ice.Data, size(ice.Time)));
rockplot = plot(rock.Time, reshape(rock.Data, size(rock.Time)));
xlabel('Time (s)');
ylabel('Average Power (W)');
legend('ice', 'rock');

iceplot.LineWidth = 2;
rockplot.LineWidth = 2;