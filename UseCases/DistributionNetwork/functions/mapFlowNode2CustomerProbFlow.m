function [ customerNodeSet, commoditySet ] = mapFlowNode2CustomerProbFlow( flowNodeSet, transportation_channel_sol )
%MAPFLOWNODE2CUSTOMERPROBFLOW Summary of this function goes here
%   Detailed explanation goes here

    numCustomers = length(flowNodeSet(:,1));
    customerNodeSet(numCustomers) = Customer;
    commoditySet = struct('ID', [], 'Origin', [], 'Destination', [], 'Quantity', [], 'Route', []);
    for jj = 1:numCustomers
        customerNodeSet(jj).Node_ID = flowNodeSet(jj,1);
        customerNodeSet(jj).Node_Name = strcat('Customer_', num2str(flowNodeSet(jj,1)));
        customerNodeSet(jj).Echelon = 1;
        customerNodeSet(jj).X = flowNodeSet(jj,2);
        customerNodeSet(jj).Y = flowNodeSet(jj,3);
        customerNodeSet(jj).Type = 'Customer_probflow';
        customerNodeSet(jj).routingProbability = transportation_channel_sol(transportation_channel_sol(:,2) == flowNodeSet(jj,1),7);
    
        %Aggregate the Commodities Into 1 Commodity for Each Customer
        commoditySet(jj).ID = jj;
        commoditySet(jj).Origin = jj;
        commoditySet(jj).Destination = 0;
        commoditySet(jj).Route = 0;
        commoditySet(jj).Quantity = sum(transportation_channel_sol(transportation_channel_sol(:,2) == flowNodeSet(jj,1), 6));
        customerNodeSet(jj).setCommoditySet(commoditySet(jj));
    end

end
