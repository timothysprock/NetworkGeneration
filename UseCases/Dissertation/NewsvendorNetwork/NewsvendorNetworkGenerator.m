nProducts = 10;
ProductSet(nProducts) = Product;

for i = 1:length(ProductSet)
   ProductSet(i).ID = i;
   ProductSet(i).meanDemand = round((500-100)*rand + 100);
   ProductSet(i).stdevDemand = 0.1*ProductSet(i).meanDemand;
end

nRenewableResources = 15;
RenewableResourceSet(nRenewableResources) = Resource;

for i = 1:length(RenewableResourceSet)
    RenewableResourceSet(i).ID = i;
    RenewableResourceSet(i).variableCost = round((75-50)*rand + 50); 
end

nConsumableResources = 25;
ConsumableResourceSet(nConsumableResources) = Resource;

for i = 1:length(ConsumableResourceSet)
    ConsumableResourceSet(i).ID = i;
    ConsumableResourceSet(i).variableCost = round((25-10)*rand + 10); 
end

nProcesses = 25;
ProcessSet(nProcesses) = Process;
Produces = randsample(nProducts,nProcesses, true);

for i = 1:nProcesses
   ProcessSet(i).ID = i;
   ProcessSet(i).Revenue = round((12500-7500)*rand + 7500);
   ProcessSet(i).Produces = [ProcessSet(i).Produces, ProductSet(Produces(i))];
   ProcessSet(i).Produces.canBeCreatedBy = [ProcessSet(i).Produces.canBeCreatedBy, ProcessSet(i)];
   ProcessSet(i).RenewableResourceSet = RenewableResourceSet(randsample(length(RenewableResourceSet), 5));
   ProcessSet(i).RenewableResourceCapReq = (1.5-1)*rand(1, length(ProcessSet(i).RenewableResourceSet)) +1;
   ProcessSet(i).ConsumableResourceSet = ConsumableResourceSet(randsample(length(ConsumableResourceSet), 5));
   ProcessSet(i).ConsumableResourceCapReq = round((4-0)*rand(1, length(ProcessSet(i).ConsumableResourceSet)) +0);
end

