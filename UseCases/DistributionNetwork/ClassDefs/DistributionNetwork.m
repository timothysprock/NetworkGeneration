classdef DistributionNetwork < Network
    %DISTRIBUTIONNETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        depotSet
        depotNodeSet@Depot
        depotMapping
        depotFixedCost
        customerSet
        customerNodeSet@Customer
        transportationChannelNodeSet@TransportationChannel
        transportationChannelSolution
        edgeSet@Edge
        commoditySet
        resourceSolution
        policySolution
        %flowNetworkAbstraction@FlowNetwork
    end
    
    methods
        function DN=DistributionNetwork(rhs)
          if nargin==0
            % default constructor
            
          elseif isa(rhs, 'DistributionNetwork')
            % copy constructor
            fns = properties(rhs);
            for i=1:length(fns)
              DN.(fns{i}) = rhs.(fns{i});
            end
          end
        end
    end
    
end

