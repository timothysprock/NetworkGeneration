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