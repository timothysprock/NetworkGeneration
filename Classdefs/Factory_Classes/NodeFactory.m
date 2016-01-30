classdef NodeFactory < handle
    %NODEFACTORY class is a creator class implemented to generate arbitrary
    %SimEvents objects corresponding to the nodes in the NodeSet within a specified model
    
    %note: hardcoded a max of 10 echelons
    
    properties
        Model %Where is the NodeFactory to operate
        Library
        NodeSet@Node %Set of nodes to be generated
        database %Source of instance data
        Type
    end
    
    methods (Access = public)
        function obj = NodeFactory(Type)
            if nargin > 0
               obj.Type = Type;
            else
                obj.Type = 'Node';
            end
        end %Constructor
        
        function CreateNodes(NF)
           echelon_position = [0 0 0 0 0 0 0 0 0 0]; %[1 2 3 4 5 6 7 8 9 10]
           for i = 1:length(NF.NodeSet)
               
               %set position of new block relative to its echelon and
               %previous blocks in that echelon
               position = [350*(NF.NodeSet(i).Echelon-1) echelon_position(NF.NodeSet(i).Echelon)  ...
                   200+350*(NF.NodeSet(i).Echelon-1) echelon_position(NF.NodeSet(i).Echelon)+65+ 10*max(length(NF.NodeSet(i).INEdgeSet), length(NF.NodeSet(i).OUTEdgeSet))];
               echelon_position(NF.NodeSet(i).Echelon) = echelon_position(NF.NodeSet(i).Echelon) + ...
                   100+65+ 10*max(length(NF.NodeSet(i).INEdgeSet), length(NF.NodeSet(i).OUTEdgeSet));
               
               NF.NodeSet(i).SimEventsPath = strcat(NF.Model, '/', NF.NodeSet(i).Node_Name);
               NF.NodeSet(i).Model = NF.Model;
               
               %add the block
               add_block(strcat(NF.Library, '/', NF.NodeSet(i).Type), NF.NodeSet(i).SimEventsPath, 'Position', position);
               set_param(NF.NodeSet(i).SimEventsPath, 'LinkStatus', 'none');
               
               %NodeFactory is the Director
               %Node acts as a ConcreteBuilder
               NF.Construct(NF.NodeSet(i));
         
           end
           
        end %Role: ConcreteFactory
        
        function Construct(NF,N)
            N.buildPorts;
        end %Role: Director
        
        function setNodeSet(NF, varargin)
            % Read and parse the node data out of the source of instance
            % data
            if isempty(varargin) == 1  && isempty(NF.database) == 0
                if strcmp(NF.Type, 'Node') == 0
                    sqlstring = strcat('SELECT * FROM NodeTable WHERE Type = "', NF.Type, '" ORDER BY NodeTable.Node_ID;');
                else
                    sqlstring = 'SELECT * FROM NodeTable ORDER BY NodeTable.Node_ID;';
                end
                NF.NodeSet = NF.parse_nodes(sqlstring); 
            else
                %varargin(1) = Property Names; varargin(2) = Instance Data
                Labels = varargin(1);
                Values = varargin(2);
                NodeSet(length(Values(:,1))) = eval(NF.Type);
                
                for i = 1:length(Values(:,1))
                    NodeSet(i).Type = NF.Type;
                    for j = 1:length(Labels)
                        NodeSet(i).(cell2mat(Labels(j))) = Values(i,j);
                    end
                end
                NF.NodeSet = NodeSet;                
            end
         end %set Node Set
         
        function allocate_edges(NF, EdgeSet )
            %ALLOCATE_EDGES Summary of this function goes here
            %   Detailed explanation goes here

                for j = 1:length(NF.NodeSet)

                    for i = 1:length(EdgeSet)
                        NF.NodeSet(j).addEdge(EdgeSet(i));
                    end %for each edge
                    
                    NF.NodeSet(j).assignPorts;

                end %for each node

        end
    end %Methods
    
    methods (Access = protected)
        function [ NodeSet ] = parse_nodes(NF, sqlstring)
            %PARSE_NODES parses data from an RDB into class objects
            %reads data from the NodeTable stored in Access, and constructs a
            %collection of nodes from the data

            %sqlstring = 'SELECT * FROM NodeTable ORDER BY NodeTable.Node_ID;';
            recordset = getrecords(NF.database, sqlstring);

            if isempty(recordset) == 1 
                %if the recordset is empty, then there are no nodes in the node table
                %return an empty array
                NodeSet = int16.empty(0,0);
            else 
                %populate the NodeSet with Nodes, and return
                NodeSet(length(recordset.data)) = eval(NF.Type);% Node;

                for i = 1:length(NodeSet)
                   for j = 1:length(recordset.columnnames)
                       %Populate each Node with instance data from table
                       NodeSet(i).(cell2mat(recordset.columnnames(j))) = cell2mat(recordset.(cell2mat(recordset.columnnames(j)))(i));
                   end %for each column in table

                   for k = 1:length(NodeSet)
                       if eq(NodeSet(i).Parent_ID, NodeSet(k).Node_ID) == 1
                            NodeSet(i).Parent = NodeSet(k);
                       end
                   end

                end %for each line item instance in table
            end %if recordset is empty

        end %end parse nodes
        
        function recordstruct = getrecords(NF, database, sqlstring)
            %GETRECORDS(tablename) opens a connection to the MSAccess database,
            % creates a recordset from (tablename),
            % puts the columns, or fieldnames, into recordstruct.columnnames,
            % and puts the record contents into recordstruct.data.


            cn=actxserver('Access.application');
            %db=invoke(cn.DBEngine,'OpenDatabase','C:\Users\tsprock3\Desktop\DELS.accdb');
            db=invoke(cn.DBEngine,'OpenDatabase',database);

            %rs=invoke(db,'OpenRecordset',tablename);
            %s = 'SELECT * FROM NodeTable;';
            rs=invoke(db,'OpenRecordset',sqlstring);

            if get(rs,'EOF')==1
                recordstruct = int16.empty(0,0);
            else
                fieldlist=get(rs,'Fields');
                ncols=get(fieldlist,'Count');

                nrecs=0;
                while get(rs,'EOF')==0
                    nrecs=nrecs + 1;
                    for c=1:double(ncols)
                        fields{c}=get(fieldlist,'Item',c-1);
                        recordstruct.data{nrecs,c}=get(fields{c},'Value');
                    end;
                    invoke(rs,'MoveNext');
                end;

                for c=1:double(ncols)
                    recordstruct.columnnames{c}=get(fields{c},'Name');
                    %if we can discern datatypes, then we could convert them from cells at
                    %runtime: data.Weight = cell2mat(data.Weight)
                    recordstruct.(get(fields{c},'Name')) = recordstruct.data(:,c);
                end;
            end %check empty recordset



            invoke(rs,'Close');
            invoke(db,'Close');
            delete(cn);

            end
    end
    
end %NodeFactory