%% Initialize Layout Procedure
N = 1;
E = 1;

NodeSetList = zeros(2*sd.aisles*sd.k, 4); %[ID, X, Y, Z]
EdgeSetList = zeros(2*2*sd.aisles*sd.k, 4);
Cross_Aisle_Set = zeros(2*sd.aisles, 1);


%% Generate sd.aisles (Columns) of Travel Nodes
for aisle_count = 0:sd.aisles-1
    %Generate the Bottom Cross Aisle    
    NodeSetList(N,:) = [N, 0.5*sd.aisle_module_width+aisle_count*sd.aisle_module_width, 0.5*sd.cross_aisle_width, 0];
    Cross_Aisle_Set(2*aisle_count+1) = N;

    last_xyz = [0.5*sd.aisle_module_width+aisle_count*sd.aisle_module_width, 0.5*sd.cross_aisle_width, 0];
    EdgeSetList(E,:) = [E, N, N+1, 0];
    EdgeSetList(E+1,:) = [E+1, N+1, N, 0];

    N= N+1;
    E = E+2;


    aislelength = sd.aisle_length(aisle_count+1);
    for node_count = 1:sd.k

        NodeSetList(N,:) = [N, 0.5*sd.aisle_module_width+aisle_count*sd.aisle_module_width, node_count*(aislelength/sd.k)+ sd.cross_aisle_width,0];

        distance = max(1e-6,sqrt(sum((last_xyz - [0.5*sd.aisle_module_width+aisle_count*sd.aisle_module_width, node_count*(aislelength/sd.k) + sd.cross_aisle_width,0]).^2)));
        EdgeSetList(E-2, 4) = distance;
        EdgeSetList(E-1, 4) = distance;

        last_xyz = [0.5*sd.aisle_module_width+aisle_count*sd.aisle_module_width, node_count*(aislelength/sd.k) + sd.cross_aisle_width,0];
        EdgeSetList(E,:) = [E, N, N+1, 0];
        EdgeSetList(E+1,:) = [E+1, N+1, N, 0];

        N = N+1;
        E = E+2;
    end
    %Generate the Top Cross Aisle
    NodeSetList(N,:) = [N, 0.5*sd.aisle_module_width+aisle_count*sd.aisle_module_width,node_count*(aislelength/sd.k) + 1.5*sd.cross_aisle_width,0];
    Cross_Aisle_Set(2*aisle_count+2) = N;

    distance = max(1e-6,sqrt(sum((last_xyz - [0.5*sd.aisle_module_width+aisle_count*sd.aisle_module_width, node_count*(aislelength/sd.k) + 1.5*sd.cross_aisle_width,0]).^2)));
    EdgeSetList(E-2, 4) = distance;
    EdgeSetList(E-1, 4) = distance;

    N= N+1;
end

%% Addition of the Cross sd.aisles on Top and Bottom
% Can generalize to arbitrary number of cross sd.aisles (perhaps with the mild
% condition that the aisle node was already placed in previous section

Cross_Aisle = Cross_Aisle_Set(1:2: 2*(sd.aisles-1)+1);

for i = 1:length(Cross_Aisle)-1

        distance = max(1e-06, sqrt(sum([NodeSetList(Cross_Aisle(i),2) NodeSetList(Cross_Aisle(i),3) NodeSetList(Cross_Aisle(i),4)] - [NodeSetList(Cross_Aisle(i+1),2) NodeSetList(Cross_Aisle(i+1),3) NodeSetList(Cross_Aisle(i+1),4)]).^2));
        EdgeSetList(E,:) = [E, NodeSetList(Cross_Aisle(i),1), NodeSetList(Cross_Aisle(i+1),1), distance];
        EdgeSetList(E+1,:) = [E+1, NodeSetList(Cross_Aisle(i+1),1), NodeSetList(Cross_Aisle(i),1), distance];
        E = E+2;
end

Cross_Aisle = Cross_Aisle_Set(2:2: 2*(sd.aisles-1)+2);

for i = 1:length(Cross_Aisle)-1

        distance = max(1e-06, sqrt(sum([NodeSetList(Cross_Aisle(i),2) NodeSetList(Cross_Aisle(i),3) NodeSetList(Cross_Aisle(i),4)] - [NodeSetList(Cross_Aisle(i+1),2) NodeSetList(Cross_Aisle(i+1),3) NodeSetList(Cross_Aisle(i+1),4)]).^2));
        EdgeSetList(E,:) = [E, NodeSetList(Cross_Aisle(i),1), NodeSetList(Cross_Aisle(i+1),1), distance];
        EdgeSetList(E+1,:) = [E+1, NodeSetList(Cross_Aisle(i+1),1), NodeSetList(Cross_Aisle(i),1), distance];
        E = E+2;
end

%% Insert Pickup & Drop-off Point(s)
PD_aisle = ceil(sd.aisles / 2);

NodeSetList(N,:) = [N, 0.5*sd.aisle_module_width+(PD_aisle-1)*sd.aisle_module_width, 0,0];

I = find(NodeSetList(:,2) == 0.5*sd.aisle_module_width+(PD_aisle-1)*sd.aisle_module_width & NodeSetList(:,3) == 0.5*sd.cross_aisle_width);
n1 = I(1);

distance = max(1e-06, sqrt(sum([NodeSetList(N,2) NodeSetList(N,3) NodeSetList(N,4)] - [NodeSetList(n1,2) NodeSetList(n1,3) NodeSetList(n1,4)]).^2));
EdgeSetList(E,:) = [E, N, n1, distance];
EdgeSetList(E+1,:) = [E+1, n1, N, distance];

N = N+1;
E = E+2;

%% Commit Data to Network Structure
sd.PickerNetwork = Network;
sd.PickerNetwork.NodeSetList = NodeSetList(1:N-1, :);
sd.PickerNetwork.EdgeSetList = EdgeSetList(1:E-1, : ); 
sd.cross_aisle_set = Cross_Aisle_Set;

sd.PickerNetwork.EdgeSetAdjList = list2adj(sd.PickerNetwork.EdgeSetList(:, 2:end));

coordinates = [sd.PickerNetwork.NodeSetList(:,2), sd.PickerNetwork.NodeSetList(:,3)];
sd.PickerNetwork.NodeSetList(:,2) = coordinates(:,1)*cos(sd.orientation)-coordinates(:,2)*sin(sd.orientation) + sd.offset(1);
sd.PickerNetwork.NodeSetList(:,3) = coordinates(:,1)*sin(sd.orientation)+coordinates(:,2)*cos(sd.orientation) + sd.offset(2);

% sd.PickerNetwork.plotNetwork;








%% Generate Storage Network 
%(two storage nodes for each travel node in an aisle)
N = 1;
E = 1;

NodeSetList = [0,0,0,0];
EdgeSetList = [0,0,0,0];

for height_count = 0:sd.StorageEquipment.storage_height-1
    for aisle_count = 0:sd.aisles-1
        for node_count = 0:ceil(bays/sd.aisles/sd.StorageEquipment.storage_height/2)-1 %ground bays per aisle on one side

                NodeSetList(N,:) = [N, 0.5*sd.StorageEquipment.bay_width+aisle_count*sd.aisle_module_width, 0.5*sd.StorageEquipment.bay_length+node_count*sd.StorageEquipment.bay_length+sd.cross_aisle_width, height_count*sd.StorageEquipment.bay_height];
                NodeSetList(N+1,:) = [N+1, 1.5*sd.StorageEquipment.bay_width+sd.aisle_width+aisle_count*sd.aisle_module_width, 0.5*sd.StorageEquipment.bay_length+node_count*sd.StorageEquipment.bay_length+sd.cross_aisle_width, height_count*sd.StorageEquipment.bay_height];

                N = N+2;
        end
    end
end

% Shift Node IDs
l = length(sd.PickerNetwork.NodeSetList);
NodeSetList(:,1) = NodeSetList(:,1)+l;

% Closest travel node to ground bays, ground edges
logGroundBaySet = NodeSetList(:,4) == 0;
GroundBaySet = NodeSetList(logGroundBaySet,:);

for i=1:length(GroundBaySet)
    [distance, I] = min(max(1e-6,sqrt((GroundBaySet(i,2)-sd.PickerNetwork.NodeSetList(:,2)).^2+(GroundBaySet(i,3)-sd.PickerNetwork.NodeSetList(:,3)).^2)));
    closest = sd.PickerNetwork.NodeSetList(I,1);
    EdgeSetList(E,:) = [E, GroundBaySet(i,1), closest, distance];
    EdgeSetList(E+1,:) = [E+1, closest, GroundBaySet(i,1), distance];
    E=E+2;
end

% Vertical edges
for node_count = 1:length(GroundBaySet)
    logHigherBaySet = NodeSetList(:,2) == NodeSetList(node_count,2) & NodeSetList(:,3) == NodeSetList(node_count,3);
    HigherBaySet = NodeSetList(logHigherBaySet,:);
    for height_count = 1:length(HigherBaySet)-1
        EdgeSetList(E,:) = [E, HigherBaySet(height_count,1), HigherBaySet(height_count+1,1), sd.StorageEquipment.bay_height];
        EdgeSetList(E+1,:) = [E+1, HigherBaySet(height_count+1,1), HigherBaySet(height_count,1), sd.StorageEquipment.bay_height];
        E=E+2;
    end
    
end

% Changing weight of vertical edges based on vertical velocity and
% acceleration
for E=length(GroundBaySet)*2+1:length(EdgeSetList)
    EdgeSetList(E,4) = sd.StorageEquipment.bay_height*(sd.PickEquipment.horizontal_velocity/sd.PickEquipment.vertical_velocity); % vertical accelerations can be considered here!
end

E=E+1;

% for node_count = 1:length(GroundBaySet)
%     logHigherBaySet = NodeSetList(:,2) == NodeSetList(node_count,2) & NodeSetList(:,3) == NodeSetList(node_count,3);
%     HigherBaySet = NodeSetList(logHigherBaySet,:);
%     for height_count = 1:length(HigherBaySet)-1
%         EdgeSetList(E,:) = [E, HigherBaySet(height_count,1), HigherBaySet(height_count+1,1), sd.StorageEquipment.bay_height*(sd.PickEquipment.horizontal_velocity/sd.PickEquipment.vertical_velocity)]; % accelerations can be considered here!
%         EdgeSetList(E+1,:) = [E+1, HigherBaySet(height_count+1,1), HigherBaySet(height_count,1), sd.StorageEquipment.bay_height*(sd.PickEquipment.horizontal_velocity/sd.PickEquipment.vertical_velocity)]; % accelerations can be considered here!
%         E=E+2;
%     end
%     
% end


% Horizontal edges
for height_count = 1:sd.StorageEquipment.storage_height
    for aisle_count = 0:sd.aisles-1
        logLeftBaySet = NodeSetList(:,2) == 0.5*sd.StorageEquipment.bay_width+aisle_count*sd.aisle_module_width & NodeSetList(:,4) == height_count*sd.StorageEquipment.bay_height;
        logRightBaySet = NodeSetList(:,2) == 1.5*sd.StorageEquipment.bay_width+sd.aisle_width+aisle_count*sd.aisle_module_width & NodeSetList(:,4) == height_count*sd.StorageEquipment.bay_height;
        
        LeftBaySet = NodeSetList(logLeftBaySet,:);
        RightBaySet = NodeSetList(logRightBaySet,:);
        
        for node_count = 1:length(LeftBaySet)-1 %ground bays per aisle on one side
            EdgeSetList(E,:) = [E, LeftBaySet(node_count,1), LeftBaySet(node_count+1,1), sd.StorageEquipment.bay_length];
            EdgeSetList(E+1,:) = [E+1, LeftBaySet(node_count+1,1), LeftBaySet(node_count,1), sd.StorageEquipment.bay_height];
            EdgeSetList(E+2,:) = [E+2, RightBaySet(node_count,1), RightBaySet(node_count+1,1), sd.StorageEquipment.bay_length];
            EdgeSetList(E+3,:) = [E+3, RightBaySet(node_count+1,1), RightBaySet(node_count,1), sd.StorageEquipment.bay_height];
            E=E+4;
            
        end
    end
end
%% Commit Data to Network Structure
sd.StorageNetwork = Network;
sd.StorageNetwork.NodeSetList = NodeSetList(1:N-1, :);
sd.StorageNetwork.EdgeSetList = EdgeSetList(1:E-1, : ); 

sd.StorageNetwork.EdgeSetAdjList = list2adj(sd.StorageNetwork.EdgeSetList(:, 2:end));





%% Create plots
UnitedNodeSetList = cat(1,sd.PickerNetwork.NodeSetList,sd.StorageNetwork.NodeSetList);

figure
scatter3(sd.StorageNetwork.NodeSetList(:,2),sd.StorageNetwork.NodeSetList(:,3),sd.StorageNetwork.NodeSetList(:,4),'filled','MarkerEdgeColor','r','MarkerFaceColor','r')
hold on
gplot(sd.PickerNetwork.EdgeSetAdjList, [sd.PickerNetwork.NodeSetList(:,2), sd.PickerNetwork.NodeSetList(:,3)], '-*')
gplot32(sd.StorageNetwork.EdgeSetAdjList, [UnitedNodeSetList(:,2), UnitedNodeSetList(:,3), UnitedNodeSetList(:,4)], 'c')
hold off












%% Calculate distances and times between storage locations
A = list2adj([sd.PickerNetwork.EdgeSetList(:, 2:end); sd.StorageNetwork.EdgeSetList(:, 2:end)]);
%StorageNetworkNodes = sd.StorageNetwork.NodeSetList;
logGroundBaySet = sd.StorageNetwork.NodeSetList(:,4) == 0;
GroundBaySet = sd.StorageNetwork.NodeSetList(logGroundBaySet,:);

% Distances
tic
PD_aisle = ceil(sd.aisles / 2);
PD = find(sd.PickerNetwork.NodeSetList(:,2) == 0.5*sd.aisle_module_width+(PD_aisle-1)*sd.aisle_module_width & sd.PickerNetwork.NodeSetList(:,3) == 0);
D = dijk(A, PD, sd.StorageNetwork.NodeSetList(:,1));
N = length(sd.StorageNetwork.NodeSetList(:,1));
if N > 200
    delta_ij = zeros(N);
        parfor i= 1:N
            delta_ij(i, :) = dijk(A, sd.StorageNetwork.NodeSetList(i,1), sd.StorageNetwork.NodeSetList(:,1));
        end
else
    delta_ij = dijk(A, sd.StorageNetwork.NodeSetList(:,1), sd.StorageNetwork.NodeSetList(:,1));
end
toc


% Travel times
T = D./sd.PickEquipment.horizontal_velocity;
time_ij = delta_ij./sd.PickEquipment.horizontal_velocity;





% DGroundBaySet = D(:,logGroundBaySet);
% logStandard = DGroundBaySet >= (sd.PickEquipment.horizontal_velocity^2/sd.PickEquipment.horizontal_acc);
% logSharp = DGroundBaySet < (sd.PickEquipment.horizontal_velocity^2/sd.PickEquipment.horizontal_acc);
% 
% T = (DGroundBaySet./sd.PickEquipment.horizontal_velocity+sd.PickEquipment.horizontal_velocity./sd.PickEquipment.horizontal_acc).*logStandard + (2*sqrt(DGroundBaySet./sd.PickEquipment.horizontal_acc)).*logSharp;
% 
% for height_count = 1:sd.StorageEquipment.storage_height-1
%     if height_count*sd.StorageEquipment.bay_height>=(sd.PickEquipment.vertical_velocity^2/sd.PickEquipment.vertical_acc)
%         vT(height_count)=(height_count*sd.StorageEquipment.bay_height)/sd.PickEquipment.vertical_velocity+sd.PickEquipment.vertical_velocity./sd.PickEquipment.vertical_acc;
%         T=[T, T(1:length(GroundBaySet))+ones(1,length(GroundBaySet))*vT(height_count)];
%     else
%         vT(height_count)=2*sqrt((height_count*sd.StorageEquipment.bay_height)/sd.PickEquipment.vertical_acc);
%         T=[T, T(1:length(GroundBaySet))+ones(1,length(GroundBaySet))*vT(height_count)];
%     end
% end

