function [ commodity_set ] = buildCommoditySet( FlowEdge_CommoditySet, FlowNode_CommoditySet, commodityFlowSolution )
%COMMODITYROUTE constructs the commodity set as Struct
%Useful step towards OO construction of Simulation

%Initialize the struct (ie specify the classdef)
commodity_set = struct('ID', [], 'Origin', [], 'Destination', [], 'Quantity', [], 'Route', []);

%commodityFlowSolution %FlowEdgeID origin destination commodity flowUnitCost flowQuantity

for i = 1:max(FlowNode_CommoditySet(:,2))
   commodity_set(i).ID = i;
   commodity_set(i).Origin = FlowNode_CommoditySet(FlowNode_CommoditySet(:,2) == i & FlowNode_CommoditySet(:,3)>0,1);
   commodity_set(i).Destination = FlowNode_CommoditySet(FlowNode_CommoditySet(:,2) == i & FlowNode_CommoditySet(:,3)<0,1);
   commodity_set(i).Quantity =  FlowNode_CommoditySet(FlowNode_CommoditySet(:,2) == i & FlowNode_CommoditySet(:,3)>0,3);
   commodity_set(i).Route = buildCommodityRoute(commodityFlowSolution(commodityFlowSolution(:,4) == i,2:6));
   %Should return later to generalize to support production/consumption of
   %each commodity at each node.
end

%Return to call commodity constructor prior to MCNF
%then call buildCommodityRoute after MCNF


end

function route = buildCommodityRoute(commodityFlowSolution)
%Commodity_Route is a set of arcs that the commodity flows on
%need to assemble the arcs into a route or path

i = 1;
route = commodityFlowSolution(i,1:2);
while sum(commodityFlowSolution(:,1) == commodityFlowSolution(i,2))>0
    i = find(commodityFlowSolution(:,1) == commodityFlowSolution(i,2));
    if eq(commodityFlowSolution(i,4),0)==0
        route = [route, commodityFlowSolution(i,2)];
    end
end
%NOTE: Need a better solution to '10', it should be 2+numDepot
while length(route)<6
    route = [route, 0];
end

end

