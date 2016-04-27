%% 0) Generate Random Instance of Distribution Network
%[fn1, customerSet, depotSet] = DistributionFlowNetworkGenerator;
depotFixedCost = 10e6;

%% 1) Build and Solve Desteriministic MCFN

fn1.solveMultiCommodityFlowNetwork;
flowNetworkSet = GenerateFlowNetworkSet( fn1, depotSet(1:length(depotSet)/2,:), 1e6);


%% 2) MAP MCFN Solution to Distribution System Model
%TO DO: Support the generation of an aggregate probabilistic flow simulation.

distributionNetworkSet(length(flowNetworkSet)) = DistributionNetwork;

for ii = 1:length(distributionNetworkSet)
    clear customerNodeSet depotNodeSet TransportationSet EdgeSet tf1 commodity_set

    
    %transportation_channel_sol = Binary Origin Destination grossCapacity flowFixedCost
    transportation_channel_sol = flowNetworkSet(ii).FlowEdge_Solution(flowNetworkSet(ii).FlowEdge_Solution(:,1) ==1,:);
    transportation_channel_sol(:,2) = []; %Drop FlowEdgeID for now
    
    commodity_route = flowNetworkSet(ii).commodityFlowSolution(:, 2:end); %drop FlowEdgeID for now
    
    for jj = 1:length(transportation_channel_sol)
        transportation_channel_sol(jj,6) = sum(commodity_route(commodity_route(:,1) == transportation_channel_sol(jj,2) & commodity_route(:,2) == transportation_channel_sol(jj,3), 5));
        transportation_channel_sol(jj,7) = transportation_channel_sol(jj,6) / sum(commodity_route(commodity_route(:,1) == transportation_channel_sol(jj,2), 5));
    end
    
    % Need a more robust way to find selected Depots
    %SelectedDepotSetIndex = find(fn1.FlowEdge_Solution(:,1) == 1 & ismember(fn1.FlowEdge_Solution(:,3), depotSet(1:length(depotSet)/2)) ==1);
    selectedDepotSet = transportation_channel_sol(transportation_channel_sol(:,5)>=1000, 2);
    depotMapping = transportation_channel_sol(transportation_channel_sol(:,5)>=1000, 2:3);

    for jj = 1:length(depotMapping(:,1))
        transportation_channel_sol(transportation_channel_sol(:,2)==depotMapping(jj,2),2) = depotMapping(jj,1);
    end

    %map FlowNode to Customer Node (Probabilistic Flow)
    [customerNodeSet, commoditySet] = mapFlowNode2CustomerProbFlow(customerSet, transportation_channel_sol);

    %ap FlowNode to Depot Node (Probabilistic Flow)
    [ depotNodeSet ] = mapFlowNode2DepotProbFlow( depotSet, transportation_channel_sol );

    % Add Transportation Channels for Flow Edges
    [ TransportationChannelSet, EdgeSet ] = mapFlowEdge2TransportationChannel([customerSet; depotSet], selectedDepotSet, transportation_channel_sol );
    

  
    distributionNetworkSet(ii).depotSet = depotSet(selectedDepotSet-length(customerNodeSet),:);
    distributionNetworkSet(ii).customerSet = customerSet;
    distributionNetworkSet(ii).transportationChannelSolution = transportation_channel_sol;
    distributionNetworkSet(ii).commoditySet = commoditySet;
    distributionNetworkSet(ii).depotNodeSet = depotNodeSet(selectedDepotSet-length(customerNodeSet));
    distributionNetworkSet(ii).customerNodeSet = customerNodeSet;
    distributionNetworkSet(ii).transportationNodeSet = TransportationChannelSet;
    distributionNetworkSet(ii).edgeSet = EdgeSet;
end

%% 3) Build and Run Low-Fidelity Simulations
for ii = 1:length(distributionNetworkSet)
    % Build & Run Simulations
    model = 'Distribution';
    library = 'Distribution_Library';
    open(model);
    warning('off','all');

    delete_model(model);
    buildSimulation(model, library, ...
        distributionNetworkSet(ii).customerNodeSet, distributionNetworkSet(ii).depotNodeSet, distributionNetworkSet(ii).transportationNodeSet, distributionNetworkSet(ii).edgeSet, distributionNetworkSet(ii).commoditySet);
    se_randomizeseeds(model, 'Mode', 'All', 'Verbose', 'off');
    save_system(model);
    close_system(model,1);
    solution = MultiGA_Distribution(model, distributionNetworkSet(ii).customerNodeSet, distributionNetworkSet(ii).depotNodeSet, 1000*ones(length(distributionNetworkSet(ii).depotNodeSet),1), [], 'true');
    distributionNetworkSet(ii).resourceSol = solution;
    clear MultiGA_Distribution;
    strcat('complete: ', num2str(ii))
end

%% 4) ReBuild Hi-Fidelity Simulation 
% This step needs some work since the current simulation builder needs to
% be reconstructed for each simulation instance (document) that needs to be
% constructed
for ii = 1:length(MCFN_solution(1,:))
    clear customerNodeSet depotNodeSet TransportationSet EdgeSet tf1 commodity_set

    % Build Customer Set
    numCustomers = length(customerSet(:,1));
    customerNodeSet(numCustomers) = Customer;
    for jj = 1:numCustomers
        customerNodeSet(jj).Node_ID = customerSet(jj,1);
        customerNodeSet(jj).Node_Name = strcat('Customer_', num2str(customerSet(jj,1)));
        customerNodeSet(jj).Echelon = 1;
        customerNodeSet(jj).X = customerSet(jj,2);
        customerNodeSet(jj).Y = customerSet(jj,3);
        customerNodeSet(jj).Type = 'Customer';
    end

    % Build Depots
    numDepot = length(depotSet(:,1));
    depotNodeSet(numDepot) = Depot;
    for jj = 1:numDepot
        depotNodeSet(jj).Node_ID = depotSet(jj,1);
        depotNodeSet(jj).Node_Name = strcat('Depot_', num2str(depotSet(jj,1)));
        depotNodeSet(jj).Echelon = 3;
        depotNodeSet(jj).X = depotSet(jj,2);
        depotNodeSet(jj).Y = depotSet(jj,3);
        depotNodeSet(jj).Type = 'Depot';
    end
    
    solution = MCFN_solution(:,ii);
    solution=round(solution);
    FlowEdge_solution = [solution(length(FlowEdge_CommoditySet)+1: end), FlowEdgeSet];
    transportation_channel_sol = FlowEdge_solution(FlowEdge_solution(:,1) ==1,:);
    commoditySet = buildCommoditySet(FlowEdge_CommoditySet,FlowNode_CommoditySet,solution);
    
    % Need a more robust way to find selected Depots
    selectedDepotSet = transportation_channel_sol(transportation_channel_sol(:,5)>1000, 2);
    depotMapping = transportation_channel_sol(transportation_channel_sol(:,5)>1000, 2:3);

    for jj = 1:length(depotMapping(:,1))
        transportation_channel_sol(transportation_channel_sol(:,2)==depotMapping(jj,2),2) = depotMapping(jj,1);
    end

    % Add Transportation Channels for Flow Edges
    jj = numCustomers + numDepot+1;
    nodeSet = [customerSet; depotSet];
    TransportationChannelSet(length(transportation_channel_sol(1:end-length(selectedDepotSet),1))) = Transportation_Channel;
    for kk = 1:length(TransportationChannelSet)
        if transportation_channel_sol(kk,1) == 1
                TransportationChannelSet(jj-numCustomers - numDepot).Node_ID = jj;
                TransportationChannelSet(jj-numCustomers - numDepot).Type = 'Transportation_Channel';
                TransportationChannelSet(jj-numCustomers - numDepot).Node_Name = strcat('Transportation_Channel_', num2str(jj));
                TransportationChannelSet(jj-numCustomers - numDepot).Echelon = 2;
                TransportationChannelSet(jj-numCustomers - numDepot).TravelRate = 30;
                TransportationChannelSet(jj-numCustomers - numDepot).TravelDistance = sqrt(sum((nodeSet(transportation_channel_sol(kk,2),2:3)-nodeSet(transportation_channel_sol(kk,3),2:3)).^2));
                %Set Depot as Source; Depots always have higher Node IDs
                if nodeSet(transportation_channel_sol(kk,2),1)>nodeSet(transportation_channel_sol(kk,3),1)
                    TransportationChannelSet(jj-numCustomers - numDepot).Source = nodeSet(transportation_channel_sol(kk,2),1);
                    TransportationChannelSet(jj-numCustomers - numDepot).Target = nodeSet(transportation_channel_sol(kk,3),1);
                else
                    TransportationChannelSet(jj-numCustomers - numDepot).Source = nodeSet(transportation_channel_sol(kk,3),1);
                    TransportationChannelSet(jj-numCustomers - numDepot).Target = nodeSet(transportation_channel_sol(kk,2),1);
                end

                %Clean-up transportation_channel; set flow edges to 0;
                match = (transportation_channel_sol(:,2) == transportation_channel_sol(kk,3) & transportation_channel_sol(:,3) == transportation_channel_sol(kk,2));
                transportation_channel_sol(kk,:)= zeros(1,5);
                if any(match)
                    transportation_channel_sol(match==1,:)= zeros(1,5);
                end
            jj = jj+1;
        end
    end

    TransportationChannelSet = TransportationChannelSet(1:jj-numCustomers - numDepot-1);
    EdgeSet(8*length(TransportationChannelSet)) = Edge;
    kk = 1;
    for jj = 1:length(TransportationChannelSet)
        e2 = TransportationChannelSet(jj).createEdgeSet(selectedDepotSet);
        EdgeSet(kk:kk+length(e2)-1) = e2;
        kk = kk+length(e2);
    end

    EdgeSet = EdgeSet(1:kk-1);

  
    distributionNetworkSet(ii).depotSet = depotSet(selectedDepotSet-numCustomers,:);
    distributionNetworkSet(ii).customerSet = customerSet;
    distributionNetworkSet(ii).transportation_channel_sol = transportation_channel_sol;
    distributionNetworkSet(ii).commoditySet = commoditySet;
    distributionNetworkSet(ii).depotNodeSet = depotNodeSet(selectedDepotSet-numCustomers);
    distributionNetworkSet(ii).customerNodeSet = customerNodeSet;
    distributionNetworkSet(ii).transportationNodeSet = TransportationChannelSet;
    distributionNetworkSet(ii).edgeSet = EdgeSet;
end 

%% 5) Build and Run High-Fidelity Simulations
for ii = 1:length(distributionNetworkSet)
    model = 'Distribution';
    library = 'Distribution_Library';
    open(model);
    warning('off','all');
    delete_model(model);

    buildSimulation(model, library, ...
        distributionNetworkSet(ii).customerNodeSet, distributionNetworkSet(ii).depotNodeSet, distributionNetworkSet(ii).transportationNodeSet, distributionNetworkSet(ii).edgeSet, distributionNetworkSet(ii).commoditySet);
    se_randomizeseeds(model, 'Mode', 'All', 'Verbose', 'off');
    save_system(model);
    close_system(model,1);

    distributionNetworkSet(ii).policySol = Distribution_Pareto(model, distributionNetworkSet(ii).customerNodeSet, distributionNetworkSet(ii).depotNodeSet, distributionNetworkSet(ii).transportationNodeSet, distributionNetworkSet(ii).resourceSol, 1000*ones(length(distributionNetworkSet(ii).resourceSol(1,:)),1));
    save GenerateFamily.mat;
    strcat('complete: ', num2str(ii))
end

%% Pareto Analysis

TravelDist = [reshape(distributionNetworkSet(1).policySol(:,:,1), [],1); reshape(distributionNetworkSet(2).policySol(:,:,1), [],1); reshape(distributionNetworkSet(3).policySol(:,:,1), [],1); reshape(distributionNetworkSet(4).policySol(:,:,1), [],1); reshape(distributionNetworkSet(5).policySol(:,:,1), [],1)];
ResourceInvestment =  [reshape(distributionNetworkSet(1).policySol(:,:,3), [],1); reshape(distributionNetworkSet(2).policySol(:,:,3), [],1); reshape(distributionNetworkSet(3).policySol(:,:,3), [],1); reshape(distributionNetworkSet(4).policySol(:,:,3), [],1); reshape(distributionNetworkSet(5).policySol(:,:,3), [],1)];
ServiceLevel =  1.-[reshape(distributionNetworkSet(1).policySol(:,:,2), [],1); reshape(distributionNetworkSet(2).policySol(:,:,2), [],1); reshape(distributionNetworkSet(3).policySol(:,:,2), [],1); reshape(distributionNetworkSet(4).policySol(:,:,2), [],1); reshape(distributionNetworkSet(5).policySol(:,:,2), [],1)];
paretoI = paretoGroup([TravelDist, ResourceInvestment, ServiceLevel]);

scatter3( TravelDist(paretoI), ResourceInvestment(paretoI), 1.-ServiceLevel(paretoI));

warning('on','all');
