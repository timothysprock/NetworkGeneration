numCustomers = 50;
numDepot = 20;
gridSize = 240; %240 minutes square box, guarantee < 8hour RT
intraDepotDiscount = 0.1;
commoditydensity = 0.75;
depotconcentration = 0.25; 

%FlowNode = [Node_ID, X, Y]
%% Generate Customer Set
%CustomerSet < FlowNode = [Node_ID, X, Y]
customerSet = zeros(numCustomers,3);
%Generate Customer Locations
for i = 1:numCustomers
    %[i x y]
    customerSet(i,:) = [i, gridSize*rand(1), gridSize*rand(1)];   
end


%% Generate Depot Set
%DepotSet < FlowNode = [Node_ID, X, Y]
depotSet = zeros(numDepot,3);
j = numCustomers+1;
for i = 1:numDepot
    %[i x y]
    minLoc = 0.25*gridSize;
    maxLoc = 0.75*gridSize;
    x = (maxLoc-minLoc)*rand(1) + minLoc;
    y = (maxLoc-minLoc)*rand(1) + minLoc;
    depotSet(i,:) = [j, x, y];
    j = j+1;
end

nodeSet = [customerSet; depotSet];
numNodes = numCustomers+numDepot;
numCommodity = (numCustomers-1)*numCustomers;


%% Generate FlowEdge Set
% FlowEdge = ID sourceFlowNode targetFlowNode grossCapacity flowFixedCost
nbArc = numNodes*(numNodes-1);
FlowEdgeSet = zeros(nbArc, 4);
g = 1;
for i = 1:numNodes
    for j = 1:numNodes
        if eq(i,j)==0
            FlowEdgeSet(g,:) = [nodeSet(i,1), nodeSet(j,1), 1e7, 0.01];
            g=g+1;
        end
    end
end

%split depots
for i =1:numDepot
    depotSet(end+1,:) = [depotSet(end,1)+1, depotSet(i,2), depotSet(i,3)];
    FlowEdgeSet(FlowEdgeSet(:,1) == depotSet(i,1)) = depotSet(end,1);
    FlowEdgeSet(end+1,:) = [depotSet(i,1), depotSet(end,1), 1e7, 1e6];
end

nodeSet = [customerSet; depotSet];
nbArc = length(FlowEdgeSet);
numNodes = length(nodeSet);

%% Generate Production/Consumption Data
%FlowNode_CommoditySet: FlowNode Commodity Production/Consumption
FlowNode_CommoditySet = zeros(numNodes*numCommodity, 3);
k = 1;
for i = 1:numCustomers
    for j = 1:numCustomers
        if eq(i,j)==0
            if rand(1) < commoditydensity
                supply = randi(500);   
                FlowNode_CommoditySet(numNodes*(k-1)+1:numNodes*(k-1)+ numNodes,1) = 1:numNodes;
                FlowNode_CommoditySet(numNodes*(k-1)+1:numNodes*(k-1)+ numNodes,2) = k;
                FlowNode_CommoditySet(numNodes*(k-1)+i,3) = supply;
                FlowNode_CommoditySet(numNodes*(k-1)+j,3) = -1*supply;
                k = k+1;
            end
        end
    end
end

%% Generate flowTypeAllowed and flowUnitCost for each FlowEdge
% FlowEdge_CommoditySet: i j k flowUnitCost
FlowEdge_CommoditySet = zeros(nbArc*numCommodity, 4);
for k = 1:numCommodity
        FlowEdge_CommoditySet((k-1)*nbArc+1:k*nbArc,:) = [FlowEdgeSet(:,1:2),k*ones(nbArc,1),sqrt((nodeSet(FlowEdgeSet(:,1),2)-nodeSet(FlowEdgeSet(:,2),2)).^2 + (nodeSet(FlowEdgeSet(:,1),3)-nodeSet(FlowEdgeSet(:,2),3)).^2)];
end


FlowEdge_CommoditySet(FlowEdge_CommoditySet(:,1)>numCustomers & FlowEdge_CommoditySet(:,2)>numCustomers,4) = intraDepotDiscount*FlowEdge_CommoditySet(FlowEdge_CommoditySet(:,1)>numCustomers & FlowEdge_CommoditySet(:,2)>numCustomers,4);

%% Cleanup: Remove Customer to Customer Edges

for j= 1:length(FlowEdge_CommoditySet)
    if le(FlowEdge_CommoditySet(j,1), numCustomers) && le(FlowEdge_CommoditySet(j,2), numCustomers)
       FlowEdge_CommoditySet(j,4) = inf; 
    end
end
FlowEdge_CommoditySet = FlowEdge_CommoditySet(FlowEdge_CommoditySet(:,4)<inf,:);

%% Display Generated Data
%scatter([customerSet(:,2); depotSet(:,2)], [customerSet(:,3); depotSet(:,3)])
scatter(customerSet(:,2),customerSet(:,3))
hold on;
scatter(depotSet(:,2),depotSet(:,3), 'filled')
hold off;






