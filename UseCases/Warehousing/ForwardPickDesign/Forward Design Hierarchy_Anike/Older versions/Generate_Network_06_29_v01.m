%% Initialize Layout Procedure
N = 1;
E = 1;

%NodeSetList = zeros(2*SD.aisles*SD.k, 4); %[ID, X, Y, Z]
%EdgeSetList = zeros(2*2*SD.aisles*SD.k, 4);
%Cross_Aisle_Set = zeros(2*SD.aisles, 1);


%% Generate SD.aisles (Columns) of Travel Nodes
for aisle_count = 0:aisles-1
    %Generate the Bottom Cross Aisle    
    NodeSetList(N,:) = [N, 0.5 * aisle_module_width + aisle_count * aisle_module_width, 0.5 * cross_aisle_width, 0];
    Cross_Aisle_Set(2*aisle_count+1) = N;

    last_xyz = [0.5 * aisle_module_width + aisle_count * aisle_module_width, 0.5 * cross_aisle_width, 0];
    EdgeSetList(E,:) = [E, N, N+1, 0];
    EdgeSetList(E+1,:) = [E+1, N+1, N, 0]; %[ID, source node, destination node, distance]

    N= N+1;
    E = E+2;


    %aislelength = SD.aisle_length(aisle_count+1);
    for node_count = 0:slots_per_aisle-1

        NodeSetList(N,:) = [N, 0.5 * aisle_module_width + aisle_count * aisle_module_width, 0.5 * slot_length +  node_count * slot_length + cross_aisle_width, 0];

        distance = max(1e-6,sqrt(sum((last_xyz - [0.5 * aisle_module_width + aisle_count * aisle_module_width, 0.5 * slot_length +  node_count * slot_length + cross_aisle_width, 0]).^2)));
        EdgeSetList(E-2, 4) = distance;
        EdgeSetList(E-1, 4) = distance;

        last_xyz = [0.5 * aisle_module_width + aisle_count * aisle_module_width, 0.5 * slot_length +  node_count * slot_length + cross_aisle_width, 0];
        EdgeSetList(E,:) = [E, N, N+1, 0];
        EdgeSetList(E+1,:) = [E+1, N+1, N, 0];

        N = N+1;
        E = E+2;
    end
    
    
    %Generate the Top Cross Aisle
    NodeSetList(N,:) = [N, 0.5 * aisle_module_width + aisle_count * aisle_module_width, 0.5 * slot_length +  node_count * slot_length + 1.5 * cross_aisle_width, 0];
    Cross_Aisle_Set(2*aisle_count+2) = N;

    distance = max(1e-6,sqrt(sum((last_xyz - [0.5 * aisle_module_width + aisle_count * aisle_module_width, 0.5 * slot_length +  node_count * slot_length + 1.5 * cross_aisle_width, 0]).^2)));
    EdgeSetList(E-2, 4) = distance;
    EdgeSetList(E-1, 4) = distance;

    N= N+1;
end

%% Addition of the Cross SD.aisles on Top and Bottom
% % Can generalize to arbitrary number of cross SD.aisles (perhaps with the mild
% % condition that the aisle node was already placed in previous section
% 
% Cross_Aisle = Cross_Aisle_Set(1:2: 2*(SD.aisles-1)+1);
% 
% for i = 1:length(Cross_Aisle)-1
% 
%         distance = max(1e-06, sqrt(sum([NodeSetList(Cross_Aisle(i),2) NodeSetList(Cross_Aisle(i),3) NodeSetList(Cross_Aisle(i),4)] - [NodeSetList(Cross_Aisle(i+1),2) NodeSetList(Cross_Aisle(i+1),3) NodeSetList(Cross_Aisle(i+1),4)]).^2));
%         EdgeSetList(E,:) = [E, NodeSetList(Cross_Aisle(i),1), NodeSetList(Cross_Aisle(i+1),1), distance];
%         EdgeSetList(E+1,:) = [E+1, NodeSetList(Cross_Aisle(i+1),1), NodeSetList(Cross_Aisle(i),1), distance];
%         E = E+2;
% end
% 
% Cross_Aisle = Cross_Aisle_Set(2:2: 2*(SD.aisles-1)+2);
% 
% for i = 1:length(Cross_Aisle)-1
% 
%         distance = max(1e-06, sqrt(sum([NodeSetList(Cross_Aisle(i),2) NodeSetList(Cross_Aisle(i),3) NodeSetList(Cross_Aisle(i),4)] - [NodeSetList(Cross_Aisle(i+1),2) NodeSetList(Cross_Aisle(i+1),3) NodeSetList(Cross_Aisle(i+1),4)]).^2));
%         EdgeSetList(E,:) = [E, NodeSetList(Cross_Aisle(i),1), NodeSetList(Cross_Aisle(i+1),1), distance];
%         EdgeSetList(E+1,:) = [E+1, NodeSetList(Cross_Aisle(i+1),1), NodeSetList(Cross_Aisle(i),1), distance];
%         E = E+2;
% end
%% Commit Data to Network Structure
SD.PickerNetwork = Network;
SD.PickerNetwork.NodeSetList = NodeSetList(1:N-1, :);
SD.PickerNetwork.EdgeSetList = EdgeSetList(1:E-1, : ); 
SD.cross_aisle_set = Cross_Aisle_Set;

SD.PickerNetwork.EdgeSetAdjList = list2adj(SD.PickerNetwork.EdgeSetList(:, 2:end));

coordinates = [SD.PickerNetwork.NodeSetList(:,2), SD.PickerNetwork.NodeSetList(:,3)];
%SD.PickerNetwork.NodeSetList(:,2) = coordinates(:,1)*cos(SD.orientation)-coordinates(:,2)*sin(SD.orientation) + SD.offset(1);
%SD.PickerNetwork.NodeSetList(:,3) = coordinates(:,1)*sin(SD.orientation)+coordinates(:,2)*cos(SD.orientation) + SD.offset(2);

SD.PickerNetwork.plotNetwork;

    