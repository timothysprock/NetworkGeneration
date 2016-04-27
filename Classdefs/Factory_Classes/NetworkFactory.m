classdef NetworkFactory < handle
    %NETWORKFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Model %where the network factory will operate
        modelLibrary % Source of simulation objects to clone from
        %NetworkObject@Network %what network object the factory will build
        nodeFactorySet@NodeFactory
        edgeFactorySet@EdgeFactory
        
    end
    
    methods
        function buildSimulation(NF, varargin)
            open(NF.Model);
            open(NF.modelLibrary);
            simeventslib;
            simulink;
            
            %Currently constructs a DES representation of the Network
            for ii = 1:length(NF.nodeFactorySet)
                NF.nodeFactorySet(ii).CreateNodes;
            end
            
            
            for ii = 1:length(NF.edgeFactorySet)
                %In the simulation context these are technically flow edges
                %connecting flow ports that provide the interface to the
                %nodes/DELS
                NF.edgeFactorySet(ii).CreateEdges;
            end
            
            se_randomizeseeds(NF.Model, 'Mode', 'All', 'Verbose', 'off');
            save_system(NF.Model);
            close_system(NF.Model,1);
        end %end buildSimulation
        
        function addNodeFactory(NF, nodeFactory)
           if isa(nodeFactory, 'NodeFactory')
               nodeFactory.Model = NF.Model;
               nodeFactory.Library = NF.modelLibrary;
               NF.nodeFactorySet(end+1) = nodeFactory;
           end
        end
        
        function addEdgeFactory(NF, edgeFactory)
            if isa(edgeFactory, 'EdgeFactory')
                edgeFactory.Model = NF.Model;
                NF.edgeFactorySet(end+1) = edgeFactory;
            end
        end
    end
    
end

