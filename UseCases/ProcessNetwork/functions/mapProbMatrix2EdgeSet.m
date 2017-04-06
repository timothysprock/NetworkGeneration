function edgeSet = mapProbMatrix2EdgeSet(P)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    %This code has the same effect without using the Graph tools
    [nProcess, ~] = size(P);
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

end

