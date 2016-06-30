classdef ProcessNetwork < Network
    %PROCESSNETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SequenceDependencySet@SequenceDependency
        ProcessSet@Process
        SequenceDependencyMatrix
        ProbabilityTransitionMatrix
    end
    
    methods
        function network2Matrix(PN)
        end
    end
    
end

