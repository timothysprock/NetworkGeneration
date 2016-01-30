classdef Customer < Node
    %CUSTOMER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        commodity_set
        routingProbability %Placeholder for value until move routing to stategy class
    end
    
    methods
        function buildCommoditySet(C)
           set_param(strcat(C.SimEventsPath, '/IN_Commodity'), 'NumberInputPorts', num2str(length(C.commodity_set)));


            for i = 1:length(C.commodity_set)
                position = get_param(strcat(C.SimEventsPath, '/IN_Commodity'), 'Position') - [400 0 400 0] + [0 (i-1)*100 0 (i-1)*100];
                %add the block
                block = add_block(strcat('Distribution_Library/CommoditySource'), strcat(C.SimEventsPath,'/Commodity_',...
                    num2str(C.commodity_set(i).ID)), 'Position', position);
                set_param(block, 'LinkStatus', 'none');

                set_param(block, 'Mean', strcat('2000/', num2str(C.commodity_set(i).Quantity)))
                %AttributeValue = '[Route]|Origin|Destination|Start'
                set_param(block, 'AttributeValue', strcat('[',num2str(C.commodity_set(i).Route),']|', num2str(C.commodity_set(i).Origin), '|', num2str(C.commodity_set(i).Destination), '|1'));

                add_line(C.SimEventsPath, strcat('Commodity_', num2str(C.commodity_set(i).ID), '/RConn1'), strcat('IN_Commodity/LConn', num2str(i)));
            end
        end
        
        function setCommoditySet(C, commodity_set)
            C.commodity_set = commodity_set([commodity_set.Origin] ==C.Node_ID);
        end
        
        function setMetrics(C)
            set_param(strcat(C.SimEventsPath, '/Shipment_Metrics'), 'VariableName', C.Node_Name);
        end
        
        function buildShipmentRouting(C)
            
            if strcmp(C.Type, 'Customer_probflow') ==1
                %Check that the probabilities, when converted to 5 sig fig by num2str,
                %add up to one
               probability = round(C.routingProbability*10000);
               error = 10000 - sum(probability);
               [Y, I] = max(probability);
               probability(I) = Y + error;
               probability = probability/10000;


               ValueVector = '[0';
               ProbabilityVector = '[0';
               for j = 1:length(probability)
                   ValueVector = strcat(ValueVector, ',' , num2str(j));
                   ProbabilityVector = strcat(ProbabilityVector, ',', num2str(probability(j)));
               end
               
               ValueVector = strcat(ValueVector, ']');
               ProbabilityVector = strcat(ProbabilityVector, ']');

               set_param(strcat(C.SimEventsPath, '/Routing'), 'probVecDisc', ProbabilityVector, 'valueVecDisc', ValueVector);
            else
                shipment_destination = findobj(C.OUTEdgeSet, 'EdgeType', 'Shipment');
                lookup_table = '[';

                for i = 1:length(shipment_destination)
                    if eq(shipment_destination(i).Destination_Node.Source, C.Node_ID) == 1
                        lookup_table = strcat(lookup_table,',', num2str(shipment_destination(i).Destination_Node.Target));
                    else
                        lookup_table = strcat(lookup_table,',', num2str(shipment_destination(i).Destination_Node.Source));
                    end
                end
                lookup_table = strcat('[',lookup_table(3:end), ']');

                set_param(strcat(C.SimEventsPath, '/Lookup'), 'Value', lookup_table);
                set_param(strcat(C.SimEventsPath, '/Node_ID'), 'Value', num2str(C.Node_ID));
            end
        end
    end
    
end

