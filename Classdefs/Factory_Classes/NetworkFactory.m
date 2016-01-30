classdef NetworkFactory
    %NETWORKFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Model %where the network factory will operate
        NetworkObject@Network %what network object the factory will build
    end
    
    methods
        function CreateNetwork(NF)
            nodefactory = NodeFactory;
            nodefactory.Model = NF.Model;
            nodefactory.NodeSet = NF.NetworkObject.NodeSet;
            
            nodefactory.CreateNodes;
            
            edgefactory = EdgeFactory;
            edgefactory.Model = NF.Model;
            edgefactory.EdgeSet = NF.NetworkObject.EdgeSet;
            
            edgefactory.CreateEdges
        end %end CreateNetwork
        
    end
    
end

