function [ varargout ] = NewsvendorNetwork( varargin )
%PRODUCTIONPLANNING Summary of this function goes here
%   Detailed explanation goes here

rng default;
seed = 1;
%addpath(genpath('C:\ILOG\CPLEX_Studio124\cplex\matlab'))
%addpath(genpath('C:\ILOG\CPLEX_Studio126\cplex\matlab')) %ISYE2014 Vlab

%%%%%%%%%%%%%%%%PARAMETERS%%%%%%%%%%%%%%%%%%
%nPeriods = 12;              %Number of Periods in Planning Horizon
nRepetitions = 100;         %Number of Repetitions

%Demand for Products
nProducts = 25;                                                             %Number of Products
meanDemand = round((500-100)*rand(1,nProducts) + 100);                      %Expected Demand per Product
stdevDemand = 0.10*meanDemand;                                              %Standard Deviation of Demand per product

%Activity
nActivities = 25;                                                            %Number of Activities
revenue =   round((12500-7500)*rand(1,nActivities) + 7500);                  %Net profit per unit of activity i
%produces = [1 0 0; 0 1 1]; %Figure 1                                        %Amount of product n produces per unit of activity i 
%produces = [1 0; 0 1]; %Figure 2a

%Each Activity produces one unit of a single product at random
produces = zeros(nProducts, nActivities);
p = round((nProducts-1)*rand(1,nActivities)+1);
for i = 1:length(p)
   produces(p(i),i) = 1; 
end


%Renewable Resources
nRenewableResources = 15;                                                   %Number of Renewable Resources
varRenewC = round((75-50)*rand(1,nRenewableResources) + 50);                %Variable Cost of Each unit of Renewable Resource
%RenewCapReq = [1 0 0; 0 1 1.5];%Figure 1                                   %Amount of Capacity of Renewable Resource j Required for Activity i
%RenewCapReq = [1 0; 0 1]; %Figure 2a
RenewCapReq = (1.5-1)*rand(nRenewableResources, nActivities) +1;                                                                            

%Consumable Resources
nConsumeResources = 25;                                                     %Number of Consumable Resources
varConsumeC = round((25-10)*rand(1,nConsumeResources) + 10);                %Variable Cost of Each unit of Consumable Resource: Purchase and Holding                                                        
%ConsumeCapReq = [1 0 1; 0 1 0]; %Figure 1                                  %Amount of Capacity of Consumable Resource j Required for Activity i
%ConsumeCapReq = [1 0;2 1]; %Figure 2a
ConsumeCapReq = round((4-0)*rand(nConsumeResources, nActivities) +0);    


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

    nbVar = nActivities*nRepetitions+nRenewableResources+nConsumeResources;

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
    for i =1:nConsumeResources
        NN.addCols(-varConsumeC(i),[],0,[], 'C', strcat('S_', num2str(i)));
    end
    
    %Add Renewable Variables
    RenewableVarIndex = ConsumableVarIndex+nConsumeResources;
    for i =1:nRenewableResources
        NN.addCols(-varRenewC(i),[],0,[], 'C', strcat('K_', num2str(i)));
    end
        
%% Add Constraints
%addRows (lhs, A, rhs, rowname)

for k = 1:nRepetitions
    % Add Renewable Resource Capacity Constraints
    %Ax leq K
    for i =1:nRenewableResources
        A = zeros(1,nbVar);
        for j = 1:nActivities
            A(ActivityVarIndex+(j-1)*nRepetitions+k) = RenewCapReq(i,j);
        end
        A(RenewableVarIndex+i) = -1;
        NN.addRows(-inf, A, 0, strcat('RenewBal_', num2str(i), '^', num2str(k)));
    end
    
    % Add Consumable Resource Capacity Constraints
    %Rs*x leq S
    for i =1:nConsumeResources
        A = zeros(1,nbVar);
        for j = 1:nActivities
            A(ActivityVarIndex+(j-1)*nRepetitions+k) = ConsumeCapReq(i,j);
        end
        A(ConsumableVarIndex+i) = -1;
        NN.addRows(-inf, A, 0, strcat('ConsumeBal_', num2str(i), '^', num2str(k)));
    end
    
    % Add Demand Constraints
    %Rd*x leq D
    for i =1:nProducts
        A = zeros(1,nbVar);
        for j = 1:nActivities
            A(ActivityVarIndex+(j-1)*nRepetitions+k) = produces(i,j);
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
fprintf('\n   Renewable Resources = %f\n', NN.Solution.x(RenewableVarIndex+1 : RenewableVarIndex+ nRenewableResources));  
fprintf('\n   Consumable Resources = %f\n', NN.Solution.x(ConsumableVarIndex+1 : ConsumableVarIndex+ nConsumeResources));  
fprintf('\n   Profit = %f\n', NN.Solution.objval);    

  
end


























