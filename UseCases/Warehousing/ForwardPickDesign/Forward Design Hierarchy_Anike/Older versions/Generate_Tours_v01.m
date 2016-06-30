%% Calculate distances and times between storage locations
A = list2adj([sd.PickerNetwork.EdgeSetList(:, 2:end); sd.StorageNetwork.EdgeSetList(:, 2:end)]);


% Distances
tic
UnitedNodeSetList = cat(1,sd.PickerNetwork.NodeSetList,sd.StorageNetwork.NodeSetList);
N = length(UnitedNodeSetList);
if N > 200
    delta_ij = zeros(N);
        parfor i= 1:N
            delta_ij(i, :) = dijk(A, UnitedNodeSetList(i,1), UnitedNodeSetList(:,1));
        end
else
    delta_ij = dijk(A, UnitedNodeSetList(:,1), UnitedNodeSetList(:,1));
end
PD_aisle = ceil(sd.aisles / 2);
PD = find(sd.PickerNetwork.NodeSetList(:,2) == 0.5*sd.aisle_module_width+(PD_aisle-1)*sd.aisle_module_width & sd.PickerNetwork.NodeSetList(:,3) == 0);
D = delta_ij(PD, length(sd.PickerNetwork.NodeSetList)+1:N);
toc

% Travel times
T = D./sd.PickEquipment.horizontal_velocity;
time_ij = delta_ij./sd.PickEquipment.horizontal_velocity;



travel_time = zeros(500,1);
for m = 1:500
    %% Batching
    %Generate Orders (sample SKUs by frequency of access)
    %Combine orders 1..Equipment_Capacity

    avg_order_lines = 10;
    batch_size = 4;

    for b = 1:batch_size
        if b == 1
            order = randsample(length(sd.StorageNetwork.NodeSetList(:,1)), avg_order_lines, true, 1./T);
        else
            order = [order, randsample(length(sd.StorageNetwork.NodeSetList(:,1)), avg_order_lines, true, 1./T)]; 
        end
    end

    stops = sd.StorageNetwork.NodeSetList(unique(order),:);
    stop_count = length(stops);

    for aisle_count=0:sd.aisles-1
        logAisle1 = stops(:,2)==0.5*sd.StorageEquipment.bay_width+aisle_count*sd.aisle_module_width;
        logAisle2 = stops(:,2)==1.5*sd.StorageEquipment.bay_width+sd.aisle_width+aisle_count*sd.aisle_module_width;
        stops(logAisle1,5) = aisle_count+1;
        stops(logAisle2,5) = aisle_count+1;
    end



    %% Create Tours
    %Serpentine and skipping

    stops = sortrows(stops, 5);
    a = 0;

    tour = [sd.PickerNetwork.NodeSetList(sd.PickerNetwork.NodeSetList(:,3)==0,:), 0]; % P/D-point

    for aisle_count=1:sd.aisles
        if ismember(aisle_count,stops(:,5))
            a = a + 1;
            if mod(a,2) == 0
                tour = cat(1, tour, [sd.cross_aisle_set(2*aisle_count),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count),2),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count),3),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count),4),aisle_count]);
                aisle_stops = sortrows(stops(stops(:,5)==aisle_count,:),-3);
                tour = cat(1, tour, aisle_stops);
                tour = cat(1, tour, [sd.cross_aisle_set(2*aisle_count-1),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count-1),2),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count-1),3),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count-1),4),aisle_count]);
            else
                tour = cat(1, tour, [sd.cross_aisle_set(2*aisle_count-1),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count-1),2),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count-1),3),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count-1),4),aisle_count]);
                aisle_stops = sortrows(stops(stops(:,5)==aisle_count,:),3);
                tour = cat(1, tour, aisle_stops);
                tour = cat(1, tour, [sd.cross_aisle_set(2*aisle_count),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count),2),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count),3),sd.PickerNetwork.NodeSetList(sd.cross_aisle_set(2*aisle_count),4),aisle_count]);
            end
        end
    end

    tour = cat(1, tour, [sd.PickerNetwork.NodeSetList(sd.PickerNetwork.NodeSetList(:,3)==0,:), 0]); % P/D-point

    %% Calculate travel time
    time = 0;
    for t = 1:length(tour)-1
        time = time + time_ij(tour(t),tour(t+1));
    end

    travel_time(m) = time/length(stops);
end

mn = mean(travel_time)
v = var(travel_time)

figure
hist(travel_time,20)