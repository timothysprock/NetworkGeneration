%% 0) Generate Random Instance of Distribution Network
%[fn1, customerSet, depotSet] = DistributionFlowNetworkGenerator;
[fn1, dn1] = DistributionFlowNetworkGenerator;

%% 1) Build and Solve Desteriministic MCFN

fn1.solveMultiCommodityFlowNetwork;
flowNetworkSet = GenerateFlowNetworkSet( fn1, dn1.depotSet(1:length(dn1.depotSet)/2,:), dn1.depotFixedCost);

%% 2) MAP MCFN Solution to Distribution System Model
distributionNetworkSet(length(flowNetworkSet)) = DistributionNetwork(dn1);
distributionNetworkSet(1) = dn1;
clear fn1 dn1;

for ii = 1:length(distributionNetworkSet)
    
    %FlowEdge_Solution = Binary FlowEdgeID Origin Destination grossCapacity flowFixedCost
    FlowEdge_Solution = flowNetworkSet(ii).FlowEdge_Solution(flowNetworkSet(ii).FlowEdge_Solution(:,1) ==1,:);
    
    %commodityFlowSolution := FlowEdgeID origin destination commodity flowUnitCost flowQuantity
    commodityFlow_Solution = flowNetworkSet(ii).commodityFlow_Solution; 
    
    %Map Commodity Flow Solution to Commodities -- Eventually Map to a
    %Product with a Process Plan / Route
    distributionNetworkSet(ii).commoditySet = mapFlowCommodity2Commodity(flowNetworkSet(ii));
    
    %Map commodity flow solution to Probabilistic Commodity Flow.
    for jj = 1:length(FlowEdge_Solution) %For each FlowEdge selected in the solution
        FlowEdge_Solution(jj,7) = sum(commodityFlow_Solution(commodityFlow_Solution(:,1) == FlowEdge_Solution(jj,2), 6));
        FlowEdge_Solution(jj,8) = FlowEdge_Solution(jj,7) / sum(commodityFlow_Solution(commodityFlow_Solution(:,2) == FlowEdge_Solution(jj,3), 6));
    end
    clear commodityFlow_Solution;
    
    %map FlowNode to Customer Node (Probabilistic Flow)
    [distributionNetworkSet(ii).customerNodeSet] = mapFlowNode2CustomerProbFlow(distributionNetworkSet(ii).customerSet, FlowEdge_Solution);

    %Map FlowNode to Depot Node (Probabilistic Flow)
    [ distributionNetworkSet(ii).depotNodeSet, selectedDepotSet, FlowEdge_Solution ] = mapFlowNode2DepotProbFlow( distributionNetworkSet(ii).depotSet, FlowEdge_Solution, distributionNetworkSet(ii).depotMapping );

    % Add Transportation Channels for Flow Edges
    [ distributionNetworkSet(ii).transportationChannelNodeSet, distributionNetworkSet(ii).edgeSet ] = mapFlowEdge2TransportationChannel([distributionNetworkSet(ii).customerSet; distributionNetworkSet(ii).depotSet], selectedDepotSet, FlowEdge_Solution );
    flowNetworkSet(ii).FlowEdge_Solution = FlowEdge_Solution;
    
    clear selectedDepotSet FlowEdge_Solution commodityFlowSolution;
end

%% 3) Build and Run Low-Fidelity Simulations
networkFactorySet(length(distributionNetworkSet)) = NetworkFactory;
for ii = 1:length(distributionNetworkSet)
    % Build & Run Simulations

    networkFactorySet(ii).Model = 'Distribution';
    networkFactorySet(ii).modelLibrary = 'Distribution_Library';
    
     
    %NodeFactory(NodeSet,(opt)EdgeSet)
    tf1 = NodeFactory(distributionNetworkSet(ii).transportationChannelNodeSet, distributionNetworkSet(ii).edgeSet);
    df1 = NodeFactory(distributionNetworkSet(ii).depotNodeSet, distributionNetworkSet(ii).edgeSet);
    cf1 = NodeFactory(distributionNetworkSet(ii).customerNodeSet, distributionNetworkSet(ii).edgeSet);
    ef1=EdgeFactory(distributionNetworkSet(ii).edgeSet);

    networkFactorySet(ii).addNodeFactory([tf1,df1,cf1]);
    networkFactorySet(ii).addEdgeFactory(ef1);
    networkFactorySet(ii).buildSimulation;
    
    %TO DO: Transition GA opt to a distributionNetwork based interface
    %distributionNetworkSet(ii).resourceSol = MultiGA_Distribution(model, distributionNetworkSet(ii).customerNodeSet, distributionNetworkSet(ii).depotNodeSet, 1000*ones(length(distributionNetworkSet(ii).depotNodeSet),1), [], 'true');
    clear MultiGA_Distribution tf1 df1 cf1 ef1;
    strcat('complete: ', num2str(ii))
end

%% 4) ReBuild Hi-Fidelity Simulation 
for ii = 1:length(distributionNetworkSet)
       
    for jj = 1:length(distributionNetworkSet(ii).customerNodeSet)
        distributionNetworkSet(ii).customerNodeSet(jj).Type = 'Customer'; %Change Resolution from Probabilistic to Complete
        distributionNetworkSet(ii).customerNodeSet(jj).setCommoditySet(distributionNetworkSet(ii).commoditySet);
    end
    
    for jj = 1:length(distributionNetworkSet(ii).depotNodeSet)
        distributionNetworkSet(ii).depotNodeSet(jj).Type = 'Depot';
    end
    
end 

%% 5) Build and Run High-Fidelity Simulations
for ii = 1:length(distributionNetworkSet)
    networkFactorySet(ii).buildSimulation;

    %distributionNetworkSet(ii).policySol = Distribution_Pareto(model, distributionNetworkSet(ii).customerNodeSet, distributionNetworkSet(ii).depotNodeSet, distributionNetworkSet(ii).transportationNodeSet, distributionNetworkSet(ii).resourceSol, 1000*ones(length(distributionNetworkSet(ii).resourceSol(1,:)),1));
    %save GenerateFamily.mat;
    strcat('complete: ', num2str(ii))
end

%% Pareto Analysis

TravelDist = [reshape(distributionNetworkSet(1).policySol(:,:,1), [],1); reshape(distributionNetworkSet(2).policySol(:,:,1), [],1); reshape(distributionNetworkSet(3).policySol(:,:,1), [],1); reshape(distributionNetworkSet(4).policySol(:,:,1), [],1); reshape(distributionNetworkSet(5).policySol(:,:,1), [],1)];
ResourceInvestment =  [reshape(distributionNetworkSet(1).policySol(:,:,3), [],1); reshape(distributionNetworkSet(2).policySol(:,:,3), [],1); reshape(distributionNetworkSet(3).policySol(:,:,3), [],1); reshape(distributionNetworkSet(4).policySol(:,:,3), [],1); reshape(distributionNetworkSet(5).policySol(:,:,3), [],1)];
ServiceLevel =  1.-[reshape(distributionNetworkSet(1).policySol(:,:,2), [],1); reshape(distributionNetworkSet(2).policySol(:,:,2), [],1); reshape(distributionNetworkSet(3).policySol(:,:,2), [],1); reshape(distributionNetworkSet(4).policySol(:,:,2), [],1); reshape(distributionNetworkSet(5).policySol(:,:,2), [],1)];
paretoI = paretoGroup([TravelDist, ResourceInvestment, ServiceLevel]);

scatter3( TravelDist(paretoI), ResourceInvestment(paretoI), 1.-ServiceLevel(paretoI));

warning('on','all');
