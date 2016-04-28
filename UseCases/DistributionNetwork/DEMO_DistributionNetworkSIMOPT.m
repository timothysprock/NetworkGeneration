%% 0) Generate Random Instance of Distribution Network
%[fn1, customerSet, depotSet] = DistributionFlowNetworkGenerator;
[fn1, dn1] = DistributionFlowNetworkGenerator;

%% 1) Build and Solve Desteriministic MCFN

fn1.solveMultiCommodityFlowNetwork;
flowNetworkSet = GenerateFlowNetworkSet( fn1, dn1.depotSet(1:length(dn1.depotSet)/2,:), dn1.depotFixedCost);


%% 2) MAP MCFN Solution to Distribution System Model
%TO DO: Support the generation of an aggregate probabilistic flow simulation.

distributionNetworkSet(length(flowNetworkSet)) = DistributionNetwork(dn1);
distributionNetworkSet(1) = dn1;
clear fn1 dn1;

for ii = 1:length(distributionNetworkSet)
    
    %transportation_channel_sol = Binary Origin Destination grossCapacity flowFixedCost
    transportation_channel_sol = flowNetworkSet(ii).FlowEdge_Solution(flowNetworkSet(ii).FlowEdge_Solution(:,1) ==1,:);
    transportation_channel_sol(:,2) = []; %Drop FlowEdgeID for now
    
    commodity_route = flowNetworkSet(ii).commodityFlowSolution(:, 2:end); %drop FlowEdgeID for now
    
    for jj = 1:length(transportation_channel_sol)
        transportation_channel_sol(jj,6) = sum(commodity_route(commodity_route(:,1) == transportation_channel_sol(jj,2) & commodity_route(:,2) == transportation_channel_sol(jj,3), 5));
        transportation_channel_sol(jj,7) = transportation_channel_sol(jj,6) / sum(commodity_route(commodity_route(:,1) == transportation_channel_sol(jj,2), 5));
    end
    
    % Isolate the Depots Selected by the Optimization
    depotMapping = distributionNetworkSet(ii).depotMapping;
    [LIA, LOCB] = ismember(depotMapping, transportation_channel_sol(:, 2:3), 'rows');
    selectedDepotSet = transportation_channel_sol(LOCB(LIA), 2);
    clear LIA LOCB;
    

    for jj = 1:length(depotMapping(:,1))
        transportation_channel_sol(transportation_channel_sol(:,2)==depotMapping(jj,2),2) = depotMapping(jj,1);
    end
    distributionNetworkSet(ii).transportationChannelSolution = transportation_channel_sol;
    clear depotMapping;

    %map FlowNode to Customer Node (Probabilistic Flow)
    [distributionNetworkSet(ii).customerNodeSet, distributionNetworkSet(ii).commoditySet] = mapFlowNode2CustomerProbFlow(distributionNetworkSet(ii).customerSet, transportation_channel_sol);

    %ap FlowNode to Depot Node (Probabilistic Flow)
    [ depotNodeSet ] = mapFlowNode2DepotProbFlow( distributionNetworkSet(ii).depotSet, transportation_channel_sol );
    distributionNetworkSet(ii).depotNodeSet = depotNodeSet(ismember([depotNodeSet.Node_ID], selectedDepotSet));
    clear depotNodeSet;

    % Add Transportation Channels for Flow Edges
    [ distributionNetworkSet(ii).transportationChannelNodeSet, distributionNetworkSet(ii).edgeSet ] = mapFlowEdge2TransportationChannel([distributionNetworkSet(ii).customerSet; distributionNetworkSet(ii).depotSet], selectedDepotSet, transportation_channel_sol );
    
    clear transportation_channel_sol selectedDepotSet;
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
    %networkFactorySet(ii).buildSimulation;
    
    %TO DO: Transition GA opt to a distributionNetwork based interface
    %distributionNetworkSet(ii).resourceSol = MultiGA_Distribution(model, distributionNetworkSet(ii).customerNodeSet, distributionNetworkSet(ii).depotNodeSet, 1000*ones(length(distributionNetworkSet(ii).depotNodeSet),1), [], 'true');
    clear MultiGA_Distribution tf1 df1 cf1 ef1;
    strcat('complete: ', num2str(ii))
end

%% 4) ReBuild Hi-Fidelity Simulation 
for ii = 1:length(distributionNetworkSet)
    
     %TO DO 4/28: currently works, but this needs to be rewritten
    distributionNetworkSet(ii).commoditySet = buildCommoditySet(flowNetworkSet(ii).FlowEdge_flowTypeAllowed,flowNetworkSet(ii).FlowNode_ConsumptionProduction, flowNetworkSet(ii).commodityFlowSolution);
   
    for jj = 1:length(distributionNetworkSet(ii).customerNodeSet)
        distributionNetworkSet(ii).customerNodeSet(jj).Type = 'Customer';
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
