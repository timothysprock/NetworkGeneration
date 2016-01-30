function [ varargout ] = NewsvendorNetwork( ProductSet, ProcessSet, ConsumableResourceSet, RenewableResourceSet )
%Newsvendor Network: 

rng default;
seed = 1;

%%%%%%%%%%%%%%%%PARAMETERS%%%%%%%%%%%%%%%%%%
%nPeriods = 12;                                                            %Number of Periods in Planning Horizon
nRepetitions = 10;                                                        %Number of Repetitions

%Map Product to Product
nProducts = length(ProductSet);                                            %Number of Products
meanDemand = [ProductSet.meanDemand];                                      %Expected Demand per Product
stdevDemand = [ProductSet.stdevDemand];                                    %Standard Deviation of Demand per product

%Map Process Set to Activity Set
nActivities = length(ProcessSet);                                          %Number of Activities
revenue =   [ProcessSet.Revenue];                                          %Net profit per unit of activity i

%Map Product & Process to Production
Output = zeros(nProducts, nActivities);                                  %Amount of product n produces per unit of activity i 
for i = 1:nProducts
   Output(i, [ProductSet(i).canBeCreatedBy.ID]) = 1;
end

%Map Renewable Resource Set to Resource Set
nResources = length(RenewableResourceSet);                                 %Number of Renewable Resources
varResourceCost = [RenewableResourceSet.variableCost];                     %Variable Cost of Each unit of Renewable Resource
ResourceCapacityReq = zeros(nResources, nActivities);                      %Amount of Capacity of Renewable Resource j Required for Activity i

%Map Process & RenewableResource to ResourceCapacityReq
for i = 1:nActivities
    ResourceCapacityReq(i,[ProcessSet(i).RenewableResourceSet.ID]) = [ProcessSet(i).RenewableResourceCapReq];
end

%Map Consumable Resource Set to Stock Input Set
nStockInputs = length(ConsumableResourceSet);                              %Number of Consumable Resources
varStockCost = [ConsumableResourceSet.variableCost];                       %Variable Cost of Each unit of Stock Input: Purchase and Holding                                                        
StockCapacityReq =  zeros(nStockInputs, nActivities);                      %Amount of Capacity of Consumable Resource j Required for Activity i

%Map Process & ConsumableResource to StockCapacityReq
for i = 1:nActivities
    StockCapacityReq(i,[ProcessSet(i).ConsumableResourceSet.ID]) = [ProcessSet(i).ConsumableResourceCapReq];
end   

%Variables
%S_j                        %Amount of Consumable Resource j
%K_j                        %Amount of Renewable Resource j
%X_i                        %Amount of Activity i

%%%%%%%%Variability%%%%%%%%%
    % Generate new streams for 
    [DemandStream, LeadTimeStream, ProductionStream] = RandStream.create('mrg32k3a', 'NumStreams', 3);

    % Set the substream to the "seed"
    DemandStream.Substream = seed;
    %LeadTimeStream.Substream = seed;
    %ProductionStream.Substream = seed;

    % Generate demands
    OldStream = RandStream.setGlobalStream(DemandStream);
    %Dem = repmat(meanDemand,1,nRepetitions);
    Dem=normrnd(repmat(meanDemand, nRepetitions,1), repmat(stdevDemand,nRepetitions,1));
    
    % Generate lead times
    %RandStream.setGlobalStream(LeadTimeStream);
    %LT=poissrnd(meanLT, nRepetitions, nPeriods);
    
    %Generate Capacity: Create Variability In Capacity of Production System
    %RandStream.setGlobalStream(ProductionStream);
    %b = normrnd(b, varB, nRepetitions,nPeriods);
    %availability = (availability(2)-availability(1))*rand(nRepetitions,nPeriods)+availability(1);
    
    RandStream.setGlobalStream(OldStream); % Restore previous stream


%% Build Model
    NN = Cplex('NN');
    NN.Model.sense = 'maximize';

    nbVar = nActivities*nRepetitions+nResources+nStockInputs;

%% Add Variables

%addCols (obj, A, lb, ub, ctype, colname)
    %Add Activity Variables
    ActivityVarIndex = 0;
    for i =1:nActivities
        for k = 1:nRepetitions
            NN.addCols(revenue(i)/nRepetitions,[],0,[], 'C', strcat('X_', num2str(i), '^', num2str(k)));
        end
    end
    
    %Add Consumable Variables
    ConsumableVarIndex = ActivityVarIndex+nActivities*nRepetitions;
    for i =1:nStockInputs
        NN.addCols(-varStockCost(i),[],0,[], 'C', strcat('S_', num2str(i)));
    end
    
    %Add Renewable Variables
    RenewableVarIndex = ConsumableVarIndex+nStockInputs;
    for i =1:nResources
        NN.addCols(-varResourceCost(i),[],0,[], 'C', strcat('K_', num2str(i)));
    end
        
%% Add Constraints
%addRows (lhs, A, rhs, rowname)

for k = 1:nRepetitions
    % Add Resource Capacity Constraints
    %Ax leq K
    for i =1:nResources
        A = zeros(1,nbVar);
        for j = 1:nActivities
            A(ActivityVarIndex+(j-1)*nRepetitions+k) = ResourceCapacityReq(i,j);
        end
        A(RenewableVarIndex+i) = -1;
        NN.addRows(-inf, A, 0, strcat('ResourceBal_', num2str(i), '^', num2str(k)));
    end
    
    % Add Stock Input Capacity Constraints
    %Rs*x leq S
    for i =1:nStockInputs
        A = zeros(1,nbVar);
        for j = 1:nActivities
            A(ActivityVarIndex+(j-1)*nRepetitions+k) = StockCapacityReq(i,j);
        end
        A(ConsumableVarIndex+i) = -1;
        NN.addRows(-inf, A, 0, strcat('StockBal_', num2str(i), '^', num2str(k)));
    end
    
    % Add Demand Constraints
    %Rd*x leq D
    for i =1:nProducts
        A = zeros(1,nbVar);
        for j = 1:nActivities
            A(ActivityVarIndex+(j-1)*nRepetitions+k) = Output(i,j);
        end
        NN.addRows(0, A, Dem(k,i), strcat('DemandBal_', num2str(i), '^', num2str(k)));
    end
end
  
%% Solve Model    
%disp(PP.Model.A);
NN.solve();
NN.writeModel('NN.mps');

disp (' - Solution:');
for i = 1:nActivities
    fprintf(strcat('\n Activity ', num2str(i),'  = %f\n'), mean(NN.Solution.x(ActivityVarIndex+(i-1)*nRepetitions+1: ActivityVarIndex+i*nRepetitions)));
end
fprintf('\n   Renewable Resources = %f\n', NN.Solution.x(RenewableVarIndex+1 : RenewableVarIndex+ nResources));  
fprintf('\n   Consumable Resources = %f\n', NN.Solution.x(ConsumableVarIndex+1 : ConsumableVarIndex+ nStockInputs));  
fprintf('\n   Profit = %f\n', NN.Solution.objval);    

  
end


