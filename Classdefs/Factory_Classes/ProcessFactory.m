classdef ProcessFactory < NodeFactory
    %PROCESSFACTORY: ConcreteFactory object subclassed from NodeFactory
    
    properties
        %NodeSet@Process {redefines Node}
    end
    
    methods (Access = public)
        function obj = ProcessFactory
           obj.Type = 'Process'; 
        end %Constructor
        
        function setNodeSet(PF)
            %Creates NodeSet for ProcessFactory
            sqlstring = 'SELECT * FROM ProcessTable ORDER BY ProcessTable.Node_ID;';
            PF.NodeSet = PF.parse_nodes(sqlstring);
        end %redefines{NodeFactory.setNodeSet}
        
        function Construct(PF, P)
            %Director Role: ProcessFactory switches from ConcreteFactory to Director pattern; 
            %Process class is configured as ConcreteBuilder. This ConcreteBuilder is responsible for
            %finishing the instantiation and customization of each process node
            Construct@NodeFactory(PF, P); 
            P.setProcessTime;
            P.setServerCount;
            P.setTimer;
            P.setStorageCapacity;
        end %redefines{NodeFactory.Construct}
        
    end
    
end

