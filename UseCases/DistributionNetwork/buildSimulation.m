function [df1, cf1, tf1, ef1] = buildSimulation(Model, Library, customerSet, depotSet, transportationSet, edgeSet, commoditySet)
%Ideally, buildSimulation would take in a set of NodeFactories and
%EdgeFactories then check and construct the simulation, returning any
%errors


open(Model);
open(Library);
simeventslib;
simulink;

tf1 = NodeFactory('TransportationChannel');
tf1.NodeSet = transportationSet;
tf1.allocate_edges(edgeSet);

df1 = NodeFactory('Depot');
df1.NodeSet = depotSet;
df1.allocate_edges(edgeSet);

cf1 = NodeFactory('Customer');
cf1.NodeSet = customerSet;
cf1.allocate_edges(edgeSet);

tf1.Model = Model;
tf1.Library = Library;
df1.Model = Model;
df1.Library = Library;
cf1.Model = Model;
cf1.Library = Library;

tf1.CreateNodes;
for i = 1:length(tf1.NodeSet)
   for j = 1:length(tf1.NodeSet(i).PortSet)
           tf1.NodeSet(i).PortSet(j).Set_PortNum;
           tf1.NodeSet(i).setTravelTime;
           tf1.NodeSet(i).buildStatusMetric;
   end
end

df1.CreateNodes;
for i = 1:length(df1.NodeSet)
    df1.NodeSet(i).buildShipmentRouting;
    df1.NodeSet(i).buildResourceAllocation;
end

cf1.CreateNodes;

for i = 1:length(cf1.NodeSet)
    cf1.NodeSet(i).setCommoditySet(commoditySet);
    cf1.NodeSet(i).buildCommoditySet;
    cf1.NodeSet(i).setMetrics;
    cf1.NodeSet(i).buildShipmentRouting;
end

ef1=EdgeFactory;
ef1.Model = Model;
ef1.EdgeSet = edgeSet;
ef1.CreateEdges;

end