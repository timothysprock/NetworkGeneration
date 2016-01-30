classdef Commodity < Token
    %COMMODITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID
        Origin@FlowNode
        Origin_ID
        Destination@FlowNode
        Destination_ID
        Quantity
        Route = []
    end
    
    methods
    end
    
end

