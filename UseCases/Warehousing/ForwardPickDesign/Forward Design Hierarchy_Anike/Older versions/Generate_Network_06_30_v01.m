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

I = find(NodeSetList(:,2) == 0.5*sd.aisle_module_width+(PD_aisle-1)*sd.aisle_module_width);
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

sd.PickerNetwork.plotNetwork;