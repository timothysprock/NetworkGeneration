classdef FlowNetwork < Network
    %FLOWNETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    FlowNodeSet % [Node_ID, X, Y]
    FlowEdgeSet %ID sourceFlowNode targetFlowNode grossCapacity flowFixedCost
    FlowNode_ConsumptionProduction %FlowNode Commodity Production/Consumption
    FlowEdge_flowTypeAllowed %FlowEdgeID origin destination commodity flowUnitCost
    FlowEdge_Solution %Binary FlowEdgeID sourceFlowNode targetFlowNode grossCapacity flowFixedCost
    commodityFlow_Solution %FlowEdgeID origin destination commodity flowUnitCost flowQuantity
    nbArc
    numNodes
    end
    
    methods
        function F=FlowNetwork(rhs)
          if nargin==0
            % default constructor
            
          elseif isa(rhs, 'FlowNetwork')
            % copy constructor
            fns = properties(rhs);
            for i=1:length(fns)
              F.(fns{i}) = rhs.(fns{i});
            end
          end
        end
        
        function solveMultiCommodityFlowNetwork(FN)
            import AnalysisLibraries/MCFN.*
            MCFNsolution = MultiCommodityFlowNetwork(FN.FlowEdge_flowTypeAllowed(:, 2:end), FN.FlowEdgeSet(:,2:end), FN.FlowNode_ConsumptionProduction);
            %MCFNsolution := [flowVariables; fixedVariables]
            %flowVariables := length(FN.FlowEdge_flowTypeAllowed), ...
                %amount of commodity k flowing on edge e
            %fixedVariables := length(FN.FlowEdgeSet), ...
                %1 if edge e is used.
            MCFNsolution = round(MCFNsolution); %NOTE: distribution network requires it 4/25/16
            FN.FlowEdge_Solution = [MCFNsolution(length(FN.FlowEdge_flowTypeAllowed)+1 : end), FN.FlowEdgeSet]; %Should reduce to only selected edges
            %TO DO: Get Ride of FlowEdge_Solution and just push solution
            %into flow network definition.
            FN.commodityFlow_Solution = [FN.FlowEdge_flowTypeAllowed(MCFNsolution(1:length(FN.FlowEdge_flowTypeAllowed))>0,1:5),...
                MCFNsolution(MCFNsolution(1:length(FN.FlowEdge_flowTypeAllowed))>0)];
        end
        
        function plotMFNSolution(FN,varargin)
            import AnalysisLibraries/matlog.*
            
            gplot(list2adj(FN.commodityFlowPath(:,1:2)), FN.FlowNodeSet(:,2:3))
            hold on;
            if length(varargin) == 2
                customerSet = varargin{1};
                depotSet = varargin{2};
                scatter(customerSet(:,2),customerSet(:,3))
                scatter(depotSet(:,2),depotSet(:,3), 'filled')
            else
                scatter(FN.FlowNodeSet(:,2),FN.FlowNodeSet(:,3), 'filled')
            end
            hold off;
        end
        
        function list2Class(FN)
            %This function should convert the list based flow network into
            %a class based representation; more or less a constructor for a
            %flow network from instance data set
            %TO DO: 
        end
    end
    
end

