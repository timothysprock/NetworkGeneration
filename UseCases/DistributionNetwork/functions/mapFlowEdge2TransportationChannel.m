function [ TransportationChannelSet, EdgeSet ] = mapFlowEdge2TransportationChannel(nodeSet, selectedDepotSet, transportation_channel_sol )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    
    
    TransportationChannelSet(length(transportation_channel_sol(1:end-length(selectedDepotSet),1))) = TransportationChannel;
    for ii = 1:length(TransportationChannelSet)
        if transportation_channel_sol(ii,1) == 1
                TransportationChannelSet(ii).Node_ID = ii+length(nodeSet);
                TransportationChannelSet(ii).Type = 'TransportationChannel_noInfo';
                TransportationChannelSet(ii).Node_Name = strcat('TransportationChannel_', num2str(ii+length(nodeSet)));
                TransportationChannelSet(ii).Echelon = 2;
                TransportationChannelSet(ii).TravelRate = 30;
                TransportationChannelSet(ii).TravelDistance = sqrt(sum((nodeSet(transportation_channel_sol(ii,2),2:3)-nodeSet(transportation_channel_sol(ii,3),2:3)).^2));
                %Set Depot as Source; Depots always have higher Node IDs
                if nodeSet(transportation_channel_sol(ii,2),1)>nodeSet(transportation_channel_sol(ii,3),1)
                    TransportationChannelSet(ii).Source = nodeSet(transportation_channel_sol(ii,2),1);
                    TransportationChannelSet(ii).Target = nodeSet(transportation_channel_sol(ii,3),1);
                else
                    TransportationChannelSet(ii).Source = nodeSet(transportation_channel_sol(ii,3),1);
                    TransportationChannelSet(ii).Target = nodeSet(transportation_channel_sol(ii,2),1);
                end

                %Clean-up transportation_channel; set flow edges to 0;
                match = (transportation_channel_sol(:,2) == transportation_channel_sol(ii,3) & transportation_channel_sol(:,3) == transportation_channel_sol(ii,2));
                transportation_channel_sol(ii,:)= zeros(1,7);
                if any(match)
                    transportation_channel_sol(match==1,:)= zeros(1,7);
                end
        end
    end
    
    %Remove extra TransportationChannels from the Set
    %[TransportationChannelSet.Node_ID] only returns properties with value
    TransportationChannelSet = TransportationChannelSet(1:length([TransportationChannelSet.Node_ID]));
    for jj = 1:length(TransportationChannelSet)
        %renumber transportation channel nodes
        TransportationChannelSet(jj).Node_ID = length(nodeSet)+ TransportationChannelSet(jj).Node_ID;
    end

    
    EdgeSet(8*length(TransportationChannelSet)) = Edge;
    jj = 1;
    for ii = 1:length(TransportationChannelSet)
        e2 = TransportationChannelSet(ii).createEdgeSet(selectedDepotSet);
        EdgeSet(jj:jj+length(e2)-1) = e2;
        jj = jj+length(e2);
    end

    EdgeSet = EdgeSet(1:jj-1);
end

