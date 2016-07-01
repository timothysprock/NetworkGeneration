nProd = 15;
nProcess = 50;
lengthProcessPlan = 200;

processPlan = randi(nProcess, nProd, lengthProcessPlan);


arrivalRate = randi([40, 100],nProd);
arrivalRate = arrivalRate(1:nProd,1);

P = zeros(nProcess);

% Add Flow Rates to Prob Matrix
for ii = 1:nProd
    flowRate = arrivalRate(ii);
   for jj = 1:lengthProcessPlan-1
       P(processPlan(ii,jj), processPlan(ii,jj+1)) = flowRate;
   end
end

%Make Prob Matrix Stochastic
rowSum = sum(P,2);
for ii = 1:nProcess
    if rowSum(ii) > 0
        P(ii,:) = P(ii,:)./rowSum(ii);
    end
end

A = digraph(P);
plot(A);

%Make arrival rate at center k
lambda = zeros(1,nProcess);

for ii = 1:nProd
    lambda(processPlan(ii,1)) = lambda(processPlan(ii,1))+ arrivalRate(ii);
end


%Make service rate
S = (0.05)*ones(1,nProcess);

%Set Number of machines at each workstation
m = 8*ones(1,nProcess);

try
    V = qnosvisits(P,lambda);
    [U, R, Q, X] = qnopen(sum(lambda), S, V, m);
catch err
    rethrow(err)
end

%% Create ProcessNetwork Representation
processSet(nProcess) = Process;

for ii = 1:nProcess
   processSet(ii).Node_ID = ii;
   processSet(ii).Node_Name = strcat('Process_', num2str(ii));
end
%Get the Adjacency List from the digraph
%A = digraph(P);
edgeAdjList1 = table2array(A.Edges);

%This code has the same effect without using the Graph tools
edgeAdjList = zeros(nProcess^2,3);
for ii = 1:nProcess
   I = find(P(ii,:));
   edgeAdjList((ii-1)*nProcess+1:(ii-1)*nProcess+length(I),:) = [ii*ones(length(I),1), I', P(ii,I)'];
end
edgeAdjList = edgeAdjList(edgeAdjList(:,1)~=0,:)

%To DO: Adjacency List to EdgeSet

