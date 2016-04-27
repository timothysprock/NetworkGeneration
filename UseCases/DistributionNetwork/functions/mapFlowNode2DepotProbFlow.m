function [ depotNodeSet ] = mapFlowNode2DepotProbFlow( flowNodeSet, transportation_channel_sol )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    numDepot = length(flowNodeSet(:,1));
    depotNodeSet(numDepot) = Depot;
    for jj = 1:numDepot
        depotNodeSet(jj).Node_ID = flowNodeSet(jj,1);
        depotNodeSet(jj).Node_Name = strcat('Depot_', num2str(flowNodeSet(jj,1)));
        depotNodeSet(jj).Echelon = 3;
        depotNodeSet(jj).X = flowNodeSet(jj,2);
        depotNodeSet(jj).Y = flowNodeSet(jj,3);
        depotNodeSet(jj).Type = 'Depot_probflow';
        depotNodeSet(jj).routingProbability = transportation_channel_sol(transportation_channel_sol(:,2) == flowNodeSet(jj,1) ...
                                                        & transportation_channel_sol(:,5)<1000,7);
    end
end

