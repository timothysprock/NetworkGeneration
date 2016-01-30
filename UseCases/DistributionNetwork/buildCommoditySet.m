function [ commodity_set ] = buildCommoditySet( FlowEdge_CommoditySet, FlowNode_CommoditySet, solution )
%COMMODITYROUTE constructs the commodity set as Struct
%Useful step towards OO construction of Simulation

%Initialize the struct (ie specify the classdef)
commodity_set = struct('ID', [], 'Origin', [], 'Destination', [], 'Quantity', [], 'Route', []);

%Use the solution from MCNF to extract routes from solution
commodity_route = [FlowEdge_CommoditySet(solution(1:length(FlowEdge_CommoditySet))>0,1:4), solution(solution(1:length(FlowEdge_CommoditySet))>0)];

for i = 1:max(FlowNode_CommoditySet(:,2))
   commodity_set(i).ID = i;
   commodity_set(i).Origin = FlowNode_CommoditySet(FlowNode_CommoditySet(:,2) == i & FlowNode_CommoditySet(:,3)>0,1);
   commodity_set(i).Destination = FlowNode_CommoditySet(FlowNode_CommoditySet(:,2) == i & FlowNode_CommoditySet(:,3)<0,1);
   commodity_set(i).Quantity =  FlowNode_CommoditySet(FlowNode_CommoditySet(:,2) == i & FlowNode_CommoditySet(:,3)>0,3);
   commodity_set(i).Route = buildCommodityRoute(commodity_route(commodity_route(:,3) == i,:));
   %Should return later to generalize to support production/consumption of
   %each commodity at each node.
end

%Return to call commodity constructor prior to MCNF
%then call buildCommodityRoute after MCNF


end

function route = buildCommodityRoute(commodity_route)
%Commodity_Route is a set of arcs that the commodity flows on
%need to assemble the arcs into a route or path

i = 1;
route = commodity_route(i,1:2);
while sum(commodity_route(:,1) == commodity_route(i,2))>0
    i = find(commodity_route(:,1) == commodity_route(i,2));
    if eq(commodity_route(i,4),0)==0
        route = [route, commodity_route(i,2)];
    end
end
%NOTE: Need a better solution to '10', it should be 2+numDepot
while length(route)<6
    route = [route, 0];
end

end

