classdef Process < Node
    %PROCESS Process Node subclass FlowNode from TFN
    %   Captures of Analysis Semantics from M/M/1 and Factory Physics style
    %   analysis use cases
    
    properties
        %Hierarchical Organization
        Workstation_ID
        Workstation@Workstation
        %Structural Parameters
        ServerCount
        StorageCapacity
        ProcessTime_Mean
        ProcessTime_Stdev
        %Performance Measures
        Utilization %Stored as Data structure, not single point
        Throughput %Stored as Data structure, not single point
        AverageSystemTime %Stored as Data structure, not single point
        AverageWaitingTime %Stored as Data structure, not single point
        AverageQueueLength %Stored as Data structure, not single point
    end
    
    methods
        function buildPorts(P)
        %    if strcmp(P.Type, 'AssyProcess')
        %        blocklocation = get_param(strcat(P.Location, '/IN_Job'), 'Position');
        %        delete_block(strcat(P.Location, '/IN_Job'));
        %        add_block('simeventslib/Entity Management/Entity Combiner', strcat(P.Location, '/IN_Job'), 'Position', blocklocation, 'BackgroundColor', 'Cyan');
        %    elseif strcmp(P.Type, 'SourceSinkProcess')
        %        blocklocation = get_param(strcat(P.Location, '/OUT_Job'), 'Position');
        %        delete_block(strcat(P.Location, '/OUT_Job'));
        %       add_block('simeventslib/Routing/Replicate', strcat(P.Location, '/OUT_Job'), 'Position', blocklocation, 'BackgroundColor', 'Cyan');
        %    end
            buildPorts@Node(P);
        end %redefines{Node.buildPorts}
        
        function setProcessTime(P)
            %Set the dialog parameters of the event-based random number generator block called ProcessTime. 
            %Needs to be extended to handle random numbers other than normal
            set_param(strcat(P.Location, '/Process/ProcessTime'), 'meanNorm', num2str(P.ProcessTime_Mean));
            set_param(strcat(P.Location, '/Process/ProcessTime'), 'stdNorm', num2str(P.ProcessTime_Stdev));
        end
        
        function setServerCount(P)
            %Set the dialog parameter NumberofServers of the n-server block called ProcessServer. 
            set_param(strcat(P.Location, '/Process/ProcessServer'), 'NumberOfServers', num2str(P.ServerCount));
        end
        
        function setTimer(P)
            %Set the dialog parameter TimerTag of the timer blocks: start_ProcessTimer & read_ProcessTimer. 
            set_param(strcat(P.Location, '/Process/start_ProcessTimer'), 'TimerTag', strcat('T_', P.Node_Name))
            set_param(strcat(P.Location, '/Process/read_ProcessTimer'), 'TimerTag', strcat('T_', P.Node_Name))
        end
        
        function setStorageCapacity(P)
            %Set the dialog parameter Capacity of the (FIFO) queue block called ProcessQueue
            set_param(strcat(P.Location, '/Process/ProcessQueue'), 'Capacity', num2str(P.StorageCapacity));
        end
        
        %metric builders
        function buildUtilization(P)
            %Builder method for recording the utilization of the n-server block called ProcessServer  
            %Utilization of the server, which is the fraction of simulation time spent storing an entity.
            %Update the signal only after each entity departure via the OUT or TO port, and after each entity arrival.
            metric_block = add_block('simeventslib/SimEvents Sinks/Discrete Event Signal to Workspace', strcat(P.Location, '/Process/Utilization_Metric'));
            set_param(metric_block, 'VariableName', strcat('Utilization_', P.Node_Name), 'Position', [800 25 900 75]);
            add_line(strcat(P.Location, '/Process'), 'ProcessServer/2', 'Utilization_Metric/1')
        end
        
        function buildThroughput(P)
            %Builder method for recording the throughput of the n-server block called ProcessServer
            %Number of entities that have departed from this block via the OUT port since the start of the simulation.
            metric_block = add_block('simeventslib/SimEvents Sinks/Discrete Event Signal to Workspace', strcat(P.Location, '/Process/Throughput_Metric'));
            set_param(metric_block, 'VariableName', strcat('Throughput_', P.Node_Name), 'Position', [800 25 900 75]);
            add_line(strcat(P.Location, '/Process'), 'ProcessServer/1', 'Throughput_Metric/1')
        end
        
        function buildAverageSystemTime(P)
            %Builder method for recording the Average System Time of the Process node
            %Recorded and Output by the timer pair, start_ProcessTimer and read_ProcessTimer
            metric_block = add_block('simeventslib/SimEvents Sinks/Discrete Event Signal to Workspace', strcat(P.Location, '/Process/AverageSystemTime_Metric'));
            set_param(metric_block, 'VariableName', strcat('AverageSystemTime_', P.Node_Name), 'Position', [800 25 900 75]);
            add_line(strcat(P.Location, '/Process'), 'read_ProcessTimer/1', 'AverageSystemTime_Metric/1')
        end
        
        function buildAverageWaitingTime(P)
            %Builder method for recording the Average Waiting Time of the Process node as output by the ProcessQueue block
            %Sample mean of the waiting times in this block for all entities that have departed via any port.
            metric_block = add_block('simeventslib/SimEvents Sinks/Discrete Event Signal to Workspace', strcat(P.Location, '/Process/AverageWaitingTime_Metric'));
            set_param(metric_block, 'VariableName', strcat('AverageWaitingTime_', P.Node_Name), 'Position', [800 25 900 75]);
            add_line(strcat(P.Location, '/Process'), 'ProcessQueue/1', 'AverageWaitingTime_Metric/1')
        end
        
        function buildAverageQueueLength(P)
            %Builder method for recording the Average Queue Length of the Process node as output by the ProcessQueue block
            %Average number of entities in the queue over time, that is, the time average of the #n signal
            metric_block = add_block('simeventslib/SimEvents Sinks/Discrete Event Signal to Workspace', strcat(P.Location, '/Process/AverageQueueLength_Metric'));
            set_param(metric_block, 'VariableName', strcat('AverageQueueLength_', P.Node_Name), 'Position', [800 25 900 75]);
            add_line(strcat(P.Location, '/Process'), 'ProcessQueue/2', 'AverageQueueLength_Metric/1')
        end

    end
    
end

