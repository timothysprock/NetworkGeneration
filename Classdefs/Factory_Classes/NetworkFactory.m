classdef NetworkFactory < handle
    %NETWORKFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Model %where the network factory will operate
        modelLibrary % Source of simulation objects to clone from
        NetworkObject@Network %what network object the factory will build
        nodeFactorySet@NodeFactory
        edgeFactorySet@EdgeFactory
        
    end
    
    methods
        function CreateNetwork(NF)
            %Currently constructs a DES representation of the Network
            for ii = 1:length(NF.nodeFactorySet)
                
            end
            
            
            for ii = 1:length(NF.edgeFactorySet)
                %In the simulation context these are technically flow edges
                %connecting flow ports that provide the interface to the
                %nodes/DELS
                ef = NF.edgeFactorySet(ii);
                ef.Model = NF.Model;
                ef.EdgeSet = edgeSet;
                ef.CreateEdges;
                clear ef;
            end
        end %end CreateNetwork
        
    end
    
end

