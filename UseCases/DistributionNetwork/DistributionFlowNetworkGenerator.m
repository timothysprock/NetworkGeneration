function [flownetwork, distributionNetwork] = DistributionFlowNetworkGenerator(varargin)
% DistributionFlowNetworkGenerator generates a random 
% TO DO: Output a Distribution Network Instance that contains the
% flownetwork as a reference
import Classdefs.*

flownetwork = FlowNetwork;
distributionNetwork = DistributionNetwork;

%% %%% Parameters %%%
    numCustomers = 10;
    numDepot = 5;
    gridSize = 240; %240 minutes square box, guarantee < 8hour RT
    intraDepotDiscount = 0.1;
    commoditydensity = 0.75;
    depotconcentration = 0.25; 
    depotFixedCost = 1e6;

    %FlowNode = [Node_ID, X, Y]
    %% Generate Customer Set
    %CustomerSet < FlowNode = [Node_ID, X, Y, fixedCost]
    customerSet = zeros(numCustomers,3);
    %Generate Customer Locations
    for ii = 1:numCustomers
        %[i x y]
        customerSet(ii,:) = [ii, gridSize*rand(1), gridSize*rand(1)];   
    end


    %% Generate Depot Set
    %DepotSet < FlowNode = [Node_ID, X, Y, fixedCost]
    depotSet = zeros(numDepot,3);
    jj = numCustomers+1;
    for ii = 1:numDepot
        %[i x y]
        minLoc = depotconcentration*gridSize;
        maxLoc = (1-depotconcentration)*gridSize;
        x = (maxLoc-minLoc)*rand(1) + minLoc;
        y = (maxLoc-minLoc)*rand(1) + minLoc;
        depotSet(ii,:) = [jj, x, y];
        jj = jj+1;
    end

    nodeSet = [customerSet; depotSet];
    numNodes = numCustomers+numDepot;
    numCommodity = (numCustomers-1)*numCustomers;


    %% Generate FlowEdge Set
    % FlowEdge = ID sourceFlowNode targetFlowNode grossCapacity flowFixedCost
    nbArc = numNodes*(numNodes-1);
    FlowEdgeSet = zeros(nbArc, 5);
    gg = 1;
    for ii = 1:numNodes
        for jj = 1:numNodes
            if eq(ii,jj)==0
                FlowEdgeSet(gg,:) = [gg, nodeSet(ii,1), nodeSet(jj,1), 1e7, 0.01];
                gg=gg+1;
            end
        end
    end

    %split depots & keep track of the mapping
    depotMapping = zeros(numDepot,2);    
    for ii =1:numDepot
        newIndex = depotSet(end,1)+1;
        depotSet(end+1,:) = [newIndex, depotSet(ii,2), depotSet(ii,3)];
        depotMapping(ii,:) = [depotSet(ii,1), newIndex];
        FlowEdgeSet(FlowEdgeSet(:,2) == depotSet(ii,1),2) = depotSet(end,1);
        FlowEdgeSet(end+1,:) = [gg, depotSet(ii,1), depotSet(end,1), 1e7, depotFixedCost];
        gg = gg +1;
    end

    nodeSet = [customerSet; depotSet];
    flownetwork.FlowNodeSet = nodeSet;
    flownetwork.FlowEdgeSet = FlowEdgeSet;
    nbArc = length(FlowEdgeSet);
    numNodes = length(nodeSet);

    %% Generate Production/Consumption Data
    %FlowNode_ConsumptionProduction := FlowNodeID Commodity Production/Consumption
    FlowNode_ConsumptionProduction = zeros(numNodes*numCommodity, 3);
    kk = 1;
    for ii = 1:numCustomers
        for jj = 1:numCustomers
            if eq(ii,jj)==0
                if rand(1) < commoditydensity
                    supply = randi(500);   
                    FlowNode_ConsumptionProduction(numNodes*(kk-1)+1:numNodes*(kk-1)+ numNodes,1) = 1:numNodes;
                    FlowNode_ConsumptionProduction(numNodes*(kk-1)+1:numNodes*(kk-1)+ numNodes,2) = kk;
                    FlowNode_ConsumptionProduction(numNodes*(kk-1)+ii,3) = supply;
                    FlowNode_ConsumptionProduction(numNodes*(kk-1)+jj,3) = -1*supply;
                    kk = kk+1;
                end
            end
        end
    end

    flownetwork.FlowNode_ConsumptionProduction = FlowNode_ConsumptionProduction;
    
    
    %% Generate flowTypeAllowed and flowUnitCost for each FlowEdge
    % FlowEdge_CommoditySet: FlowEdgeID origin destination k flowUnitCost
    FlowEdge_flowTypeAllowed = zeros(nbArc*numCommodity, 5);
    for kk = 1:numCommodity
            FlowEdge_flowTypeAllowed((kk-1)*nbArc+1:kk*nbArc,:) = [FlowEdgeSet(:,1:3),kk*ones(nbArc,1),sqrt((nodeSet(FlowEdgeSet(:,2),2)-nodeSet(FlowEdgeSet(:,3),2)).^2 + (nodeSet(FlowEdgeSet(:,2),3)-nodeSet(FlowEdgeSet(:,3),3)).^2)];
    end


    FlowEdge_flowTypeAllowed(FlowEdge_flowTypeAllowed(:,2)>numCustomers & FlowEdge_flowTypeAllowed(:,3)>numCustomers,5) = intraDepotDiscount*FlowEdge_flowTypeAllowed(FlowEdge_flowTypeAllowed(:,2)>numCustomers & FlowEdge_flowTypeAllowed(:,3)>numCustomers,5);

    %% Cleanup: Remove Customer to Customer Edges

    for jj= 1:length(FlowEdge_flowTypeAllowed)
        if le(FlowEdge_flowTypeAllowed(jj,2), numCustomers) && le(FlowEdge_flowTypeAllowed(jj,3), numCustomers)
           FlowEdge_flowTypeAllowed(jj,5) = inf; 
        end
    end
    FlowEdge_flowTypeAllowed = FlowEdge_flowTypeAllowed(FlowEdge_flowTypeAllowed(:,5)<inf,:);

    flownetwork.FlowEdge_flowTypeAllowed = FlowEdge_flowTypeAllowed;

    %% Display Generated Data
    %scatter([customerSet(:,2); depotSet(:,2)], [customerSet(:,3); depotSet(:,3)])
%     scatter(customerSet(:,2),customerSet(:,3))
%     hold on;
%     scatter(depotSet(:,2),depotSet(:,3), 'filled')
%     hold off;
    
    FlowNetwork = flownetwork;
    distributionNetwork.depotSet = depotSet;
    distributionNetwork.customerSet = customerSet;
    distributionNetwork.depotMapping = depotMapping;
    distributionNetwork.depotFixedCost = depotFixedCost;

end






