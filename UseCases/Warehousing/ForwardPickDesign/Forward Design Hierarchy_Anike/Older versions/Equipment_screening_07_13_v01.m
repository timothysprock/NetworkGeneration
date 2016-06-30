%% Screening equipments
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot, 
% slotting most frequent<->most desirable, routing by serpentine and skipping

%% Initialize screening for equipment
sf = 2; %shape factor (rectangle twice as long as wide)

avg_order_lines = 10;
sku_percent = 0.2;
total_sku_count = 5000;

cross_aisle_width = 10;
bays = ceil(sku_percent * total_sku_count);

c = 0; % counts number of combinations

mn = zeros(10,10);
v = zeros(10,10);

tic
%% Screening
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
        [delta_ij, D, time_ij, T]=Distances(sd);



        travel_time = zeros(50,1);
        for m = 1:50 % runs of Monte Carlo Simulation
            
            %% Batching (Monte Carlo Sampling)
            %Generate Orders (sample SKUs by frequency of access)
            %Combine orders 1..Equipment_Capacity

            stops=OrderBatching(avg_order_lines,batch_size,T,sd);

            
            %% Routing - Create Tours
            %Serpentine and skipping

            tour=SerpentineSkipping(stops,sd.aisles,sd.cross_aisle_set,sd.PickerNetwork.NodeSetList);
            
            
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

c

toc
% figure(2)
% scatter(combination(:,3),combination(:,9))
% xlabel('storage height')
% 
% figure(3)
% scatter(combination(:,4),combination(:,9))
% xlabel('capacity')
