classdef TransportationChannel < Node
    %TRANSPORTATION_CHANNEL Summary of this class goes here
    %   Detailed explanation goes here
    %Note: Older versions of the instance data have the class name as
    %Transportation_Channel
    
    properties
        TravelDistance = 0 %{redefines: Weight}
        TravelRate
        Source
        Target
    end
    
    methods
        function decorateNode(TC)
            for jj = 1:length(TC.PortSet)
                TC.PortSet(jj).Set_PortNum;
            end
                TC.setTravelTime;
                TC.buildStatusMetric; 
        end
        
        function buildPorts(TC)
            %Override Node's method to buildPorts; in this use case, the
            %Transportation Channel comes pre-built with its ports complete
        end
        
        function EdgeSet = createEdgeSet(TC, DepotSet)
            %Maps a set of Flow Edges to a single Flow/Process Node and
            %creates the required new flow edges.
            %Future Work: How does mapping multiple flow edges to a TC
            
            EdgeSet(8) = Edge;
            k=1;
            
            %Add Edges for flows from Source to Target
            EdgeSet(k).Edge_ID = k;
            EdgeSet(k).Origin = TC.Source;
            EdgeSet(k).Destination = TC.Node_ID;
            EdgeSet(k).EdgeType = 'Shipment';
            k= k+1;

            EdgeSet(k).Edge_ID = k;
            EdgeSet(k).Origin = TC.Node_ID;
            EdgeSet(k).Destination = TC.Target;
            EdgeSet(k).EdgeType = 'Shipment';
            k=k+1;
            
            if any(TC.Source == DepotSet(:))
                EdgeSet(k).Edge_ID = k;
                EdgeSet(k).Origin = TC.Source;
                EdgeSet(k).Destination = TC.Node_ID;
                EdgeSet(k).EdgeType = 'Resource';
                k=k+1;

                EdgeSet(k).Edge_ID = k;
                EdgeSet(k).Origin = TC.Node_ID;
                EdgeSet(k).Destination = TC.Source;
                EdgeSet(k).EdgeType = 'Resource';
                k=k+1;
            end
            
            %Add Edges for flows from Target To Source
            EdgeSet(k).Edge_ID = k;
            EdgeSet(k).Origin = TC.Target;
            EdgeSet(k).Destination = TC.Node_ID;
            EdgeSet(k).EdgeType = 'Shipment';
            k=k+1;

            EdgeSet(k).Edge_ID = k;
            EdgeSet(k).Origin = TC.Node_ID;
            EdgeSet(k).Destination = TC.Source;
            EdgeSet(k).EdgeType = 'Shipment';
            k=k+1;

           if any(TC.Target == DepotSet(:))
                EdgeSet(k).Edge_ID = k;
                EdgeSet(k).Origin = TC.Target;
                EdgeSet(k).Destination = TC.Node_ID;
                EdgeSet(k).EdgeType = 'Resource';
                k=k+1;

                EdgeSet(k).Edge_ID = k;
                EdgeSet(k).Origin = TC.Node_ID;
                EdgeSet(k).Destination = TC.Target;
                EdgeSet(k).EdgeType = 'Resource';
                k=k+1;
            end
            
            EdgeSet = EdgeSet(1:k-1);
        end
    end
    
    methods (Access = private)
       function setTravelTime(TC)
            set_param(strcat(TC.SimEventsPath, '/TravelTime'), 'Value', strcat(num2str(TC.TravelDistance),'/', num2str(TC.TravelRate)));
        end
        
       function buildStatusMetric(TC)
            try
                set_param(strcat(TC.SimEventsPath, '/TC_Status'), 'VariableName', strcat(TC.Node_Name,'_Status'));
                set_param(strcat(TC.SimEventsPath, '/Goto'), 'GotoTag', strcat(TC.Node_Name,'_Status'));
            end
        end 
    end
    
end

