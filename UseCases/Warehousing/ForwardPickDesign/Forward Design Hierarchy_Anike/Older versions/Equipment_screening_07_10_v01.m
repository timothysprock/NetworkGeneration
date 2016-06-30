%% Screening equipments
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot, random
% slotting, routing by TSP

% Initialize screening for equipment
sf = 2; %shape factor (rectangle twice as long as wide)
cross_aisle_width = 10; % in feet

avg_order_lines = 10;
sku_percent = 0.2;
total_sku_count = 5000;

bays = ceil(sku_percent * total_sku_count);

c = 0; % counts number of combinations
travel_distance = zeros(length(seqSet),length(peqSet));
travel_distance_pick = zeros(length(seqSet),length(peqSet));
cycle_time = zeros(length(seqSet),length(peqSet));
cycle_time_pick = zeros(length(seqSet),length(peqSet));

mn = zeros(10,10);
v = zeros(10,10);

tic
% Screening
for s = 1:length(seqSet)

    bay_width = seqSet(s).bay_width; 
    bay_length = seqSet(s).bay_length;
    bay_height = seqSet(s).bay_height;
    
    sHeight = seqSet(s).storage_height;

    for p = 1:length(peqSet)
        
        pHeight = peqSet(p).reachable_height;
        
        %% Check compatibility
        if sHeight > pHeight
            continue
        end
        
        c = c + 1;
        
        aisle_width = peqSet(p).req_aisle_width; 
        batch_size = peqSet(p).capacity;
        hVelocity = peqSet(p).horizontal_velocity;
        vVelocity = peqSet(p).vertical_velocity;
        
        %% Dimensioning
        aisle_module_width = 2 * bay_width + aisle_width; % aisle plus shelves on both sides
        ground_bays = ceil(bays / sHeight);
        
        aisles = 1;
        bays_per_aisle = bays;
        aisle_length = (bays_per_aisle / sHeight / 2) * bay_length;        
        forward_length = aisle_length + 2 * cross_aisle_width;
        forward_width = aisles * aisle_module_width;

        while forward_length > sf * forward_width
            aisles = aisles + 1;
            bays_per_aisle = ceil(bays / aisles);
            aisle_length = ceil(bays_per_aisle / sHeight / 2) * bay_length;        
            forward_length = aisle_length + 2 * cross_aisle_width;
            forward_width = aisles * aisle_module_width;  
        end
        
        final_bay_count = bays_per_aisle * aisles;
        forward_area = forward_length * forward_width;  
        
        
        
        %% Build storage department

        sd = Storage_Department;
        sd.aisles = aisles;
        sd.aisle_module_width = aisle_module_width;
        sd.aisle_length = aisle_length * ones(aisles, 1);
        sd.aisle_width = aisle_width;
        sd.bays = final_bay_count;
        sd.cross_aisle_width = cross_aisle_width;
        sd.k = 50;
        sd.orientation = 0;
        sd.offset = [0,0];

        sd.StorageEquipment = seqSet(s);
        sd.PickEquipment = peqSet(p);

        sd.GeneratePickerNetwork
        sd.GenerateStorageNetwork
        
        
        %% Calculate distances and times between storage locations
        A = list2adj([sd.PickerNetwork.EdgeSetList(:, 2:end); sd.StorageNetwork.EdgeSetList(:, 2:end)]);


        % Distances
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

        % Travel times
        T = D./sd.PickEquipment.horizontal_velocity;
        time_ij = delta_ij./sd.PickEquipment.horizontal_velocity;



        travel_time = zeros(1000,1);
        for m = 1:50 % runs of Monte Carlo Simulation
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

        mn(s,p) = mean(travel_time);
        v(s,p) = var(travel_time);
        
    end
   s
end

figure
surfc(mn)
xlabel('Pick Equipment (batch size)')
ylabel('Storage Equipment (height)')
zlabel('Cycle Time per Pick')

toc
% figure(2)
% scatter(combination(:,3),combination(:,9))
% xlabel('storage height')
% 
% figure(3)
% scatter(combination(:,4),combination(:,9))
% xlabel('capacity')


% %% Build storage department (based on last pick equipment - storage equipment combination)
% 
% sd = Storage_Department;
% sd.aisles = aisles;
% sd.aisle_module_width = aisle_module_width;
% sd.aisle_length = aisle_length * ones(aisles, 1);
% sd.aisle_width = aisle_width;
% sd.bays = final_bay_count;
% sd.cross_aisle_width = cross_aisle_width;
% sd.k = 50;
% sd.orientation = 0;
% sd.offset = [0,0];
% 
% sd.StorageEquipment = seqSet(combination(end,1));
% sd.PickEquipment = peqSet(combination(end,2));
% 
% sd.GeneratePickerNetwork
% sd.GenerateStorageNetwork
% sd.PlotNetworks
