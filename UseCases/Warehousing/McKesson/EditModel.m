%%Useful Commands 
find_system('UberSpurs/spur1WorkCell') %get all the blocks in that subsystem
 se_randomizeseeds('UberSpurs','Mode','All', 'Verbose', 'On') %randomize all the rng seeds
 % fill to verify time for channel 1 on spur 1
 histogram(logsout.get('fill2VerifyTime').Values.Data(logsout.get('Channel').Values.Data == 1),'BinWidth', 1.5)

 %% for UberSpurs_oneSpur
%set process time at each channel
for ii = 1:18
set_param(strcat('UberSpurs/spur1WorkCell/fillChannel', num2str(ii),'/processTime'), 'meanNorm', '25', 'stdNorm', '2.5');
end

%set capacity and travel time of one spur MHS
for ii = 1:18
set_param(strcat('UberSpurs/spur1WorkCell/toChannel', num2str(ii)), 'NumberOfServers', '5', 'ServiceTime', '0.1');
end
set_param('UberSpurs/spur1WorkCell/toVerify', 'NumberOfServers', '5', 'ServiceTime', '0.1');

%rename stuff
for ii = 1:18
    try
        set_param(strcat('UberSpurs/spur1WorkCell/route2Channel', num2str(ii), '/Chart'), 'Name', 'RoutingControlBehavior')
    end
    try
        set_param(strcat('UberSpurs/spur1WorkCell/route2Channel', num2str(ii), '/route2Channel', num2str(ii)), 'Name', 'RoutingControlActuator')
    end
end

%set 'constant' value that each routing control uses
for ii = 1:18
    try
        set_param(strcat('UberSpurs/spur1WorkCell/route2Channel', num2str(ii), '/Constant'), 'Value', num2str(ii))
    end
end



%% Reset the parameters for UberSpurs

for jj = 1:3
    for ii = 1:18
        set_param(strcat('UberSpurs/spur', num2str(jj), 'WorkCell/fillChannel', num2str(ii),'/processTime'), 'meanNorm', '25', 'stdNorm', '2.5');
    end
    set_param(strcat('UberSpurs/spur', num2str(jj), 'WorkCell/verifyWorkstation/VerifyServer'), 'ServiceTime', '1.55');

%set capacity and travel time of on spur MHS
    for ii = 1:18
    set_param(strcat('UberSpurs/spur', num2str(jj), 'WorkCell/toChannel', num2str(ii)), 'NumberOfServers', '5', 'ServiceTime', '0.1');
    end
    set_param(strcat('UberSpurs/spur', num2str(jj), 'WorkCell/toVerify'), 'NumberOfServers', '45', 'ServiceTime', '3');

end