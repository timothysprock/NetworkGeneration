function [departureProcess, departureEdgeSet] = mapDepartures2DepartureProcessNode(processSet, edgeSet, P)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

[nProcess,~] = size(P);
departureProcess = Process;
departureProcess.Node_ID = nProcess+2;
departureProcess.Node_Name = 'Departure_Process';
departureProcess.Type = 'DepartureProcess';
departureProcess.ServerCount = inf;
departureProcess.ProcessTime_Mean = 0.05;
departureProcess.ProcessTime_Stdev = eps;
departureProcess.StorageCapacity = inf;
departureProcess.Echelon = 10;
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

end

