classdef ProcessNetwork < Network
    %PROCESSNETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SequenceDependencySet@SequencingDependency
        ProcessSet@Process
        SequenceDependencyMatrix
        ProbabilityTransitionMatrix
    end
    
    methods
        function network2Matrix(PN)
        end
        
        function matrix2Network(PN)
            
        end
    end
    
end

