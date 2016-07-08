
%% Make Random Process Network
%Instance Parameters
rng('default')
nProd = 15;
nProcess = 50;
lengthProcessPlan = 20;

processPlan = randi(nProcess, nProd, lengthProcessPlan);
arrivalRate = randi([1, 10],nProd);
arrivalRate = arrivalRate(1:nProd,1);

P = zeros(nProcess);
%mapProcess2ProbMatrix
% Add Flow Rates to Prob Matrix
for ii = 1:nProd
    flowRate = arrivalRate(ii);
   for jj = 1:lengthProcessPlan-1
       P(processPlan(ii,jj), processPlan(ii,jj+1)) = flowRate;
   end
end

%Make Prob Matrix Stochastic (including outflow)
%Add the outflow rate to the rowSum; rows don't add up to 1
rowSum = sum(P,2);
for ii = 1:nProcess
    if rowSum(ii) > 0
        P(ii,:) = P(ii,:)./(rowSum(ii) + (processPlan(:, end) == ii)'*arrivalRate);
    end
end

%Use Graph Toolbox to visualize graph
A = digraph(P);
plot(A);

%Make arrival rate at center k
lambda = zeros(1,nProcess);
for ii = 1:nProd
    lambda(processPlan(ii,1)) = lambda(processPlan(ii,1))+ arrivalRate(ii);
end


%Make service time at process node k
serviceTime = (0.05)*ones(1,nProcess);

try
    avgNoVisits = qnosvisits(P,lambda);   
    %Set Number of machines at each workstation
    machineCount = ceil(sum(lambda) * serviceTime .* avgNoVisits / 0.95);
    [Util, avgResponseTime, avgNoRequests, Throughput] = qnopen(sum(lambda), serviceTime, avgNoVisits, machineCount);
catch err
    rethrow(err)
end
clear lambda avgNoVisits  A rowSum flowRate

%% Create ProcessNetwork Representation
clear processSet edgeSet PN NF PF EF
processSet(nProcess) = Process;

%mapProcessArray2Class
for ii = 1:nProcess
   processSet(ii).Node_ID = ii;
   processSet(ii).Node_Name = strcat('Process_', num2str(ii));
   processSet(ii).Type = 'Process';
   processSet(ii).ServerCount = machineCount(ii);
   processSet(ii).ProcessTime_Mean = serviceTime(ii);
   processSet(ii).StorageCapacity = inf;
   processSet(ii).Echelon = mod(ii,10)+1;
   routingProbability = P(ii,(P(ii,:)>0));
   processSet(ii).routingProbability = [routingProbability, 1-sum(routingProbability)];
end
clear m S

%mapProbMatrix2EdgeSet
%This code has the same effect without using the Graph tools
edgeAdjList = zeros(nProcess^2,3);
for ii = 1:nProcess
   I = find(P(ii,:));
   edgeAdjList((ii-1)*nProcess+1:(ii-1)*nProcess+length(I),:) = [ii*ones(length(I),1), I', P(ii,I)'];
end
edgeAdjList = edgeAdjList(edgeAdjList(:,1)~=0,:);

%Adjacency List to EdgeSet
edgeSet(length(edgeAdjList)) = Edge;

for ii = 1:length(edgeAdjList)
    edgeSet(ii).Edge_ID = ii;
    edgeSet(ii).Origin = edgeAdjList(ii,1);
    edgeSet(ii).EdgeType = 'Job';
    edgeSet(ii).Destination = edgeAdjList(ii,2);
end

% mapArrivals2Source
% 'DELS_Library/ArrivalProcess'
totalArrivalRate = sum(arrivalRate);
Parrival = zeros(nProcess, 1);
for ii = 1:nProd
    productArrivalRate = arrivalRate(ii);
    Parrival(processPlan(ii,1)) = Parrival(processPlan(ii,1)) + productArrivalRate;
end
arrivalProcess = Process;
arrivalProcess.Node_ID = nProcess+1;
arrivalProcess.Node_Name = 'Arrival_Process';
arrivalProcess.Type = 'ArrivalProcess';
arrivalProcess.ServerCount = inf;
arrivalProcess.ProcessTime_Mean = 1/totalArrivalRate;
arrivalProcess.StorageCapacity = inf;
arrivalProcess.Echelon = 1;
arrivalProcess.routingProbability = Parrival ./ totalArrivalRate;

arrivalEdgeSet(nProcess) = Edge;
for ii = 1:nProcess
    arrivalEdgeSet(ii).Edge_ID = length(edgeSet)+ ii;
    arrivalEdgeSet(ii).Origin = arrivalProcess.Node_ID;
    arrivalEdgeSet(ii).EdgeType = 'Job';
    arrivalEdgeSet(ii).Destination = processSet(ii).Node_ID;
end
edgeSet(end+1:end+length(arrivalEdgeSet))= arrivalEdgeSet;
processSet(end+1) = arrivalProcess;
clear arrivalProcess arrivalEdgeSet totalArrivalRate productArrivalRate Parrival routingProbability

%mapDepartures2Sink
departureProcess = Process;
departureProcess.Node_ID = nProcess+2;
departureProcess.Node_Name = 'Departure_Process';
departureProcess.Type = 'DepartureProcess';
departureProcess.ServerCount = inf;
departureProcess.ProcessTime_Mean = 0.05;
departureProcess.ProcessTime_Stdev = eps;
departureProcess.StorageCapacity = inf;
arrivalProcess.Echelon = 10;
departureProcess.routingProbability = [0 0];

rowSum = sum(P,2);
I = find(rowSum < 1);
departureEdgeSet(length(I)) = Edge;
for ii = 1:length(I)
    departureEdgeSet(ii).Edge_ID = length(edgeSet) + ii;
    departureEdgeSet(ii).Origin =  processSet(I(ii)).Node_ID;
    departureEdgeSet(ii).EdgeType = 'Job';
    departureEdgeSet(ii).Destination = departureProcess.Node_ID;
end

edgeSet(end+1:end+length(departureEdgeSet))= departureEdgeSet;
processSet(end+1) = departureProcess;

clear departureProcess departureEdgeSet rowSum I


NF = NetworkFactory;
NF.Model = 'ProcessNetworkSimulation';
NF.modelLibrary = 'DELS_Library';

PF = NodeFactory(processSet);
EF = EdgeFactory(edgeSet);
PF.allocate_edges(edgeSet);

NF.addNodeFactory(PF);
NF.addEdgeFactory(EF);

NF.buildSimulation;

utilDirector = MetricDirector;
utilDirector.ConstructMetric(processSet, 'Utilization');