%% Screening equipments
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot, 
% slotting most frequent<->most desirable, routing by serpentine and skipping

%% Initialize screening for equipment
sf = 1; %shape factor

avg_order_lines = 10;
total_sku_count = 5000;

cross_aisle_width = 10;

sd = Storage_Department;
c = 0;

tic
%% Screening
for e = 1:length(seqSet)
    
    sd.StorageEquipment = seqSet(e);
    sd.PickEquipment = peqSet(e);


    if sd.StorageEquipment.storage_height > sd.PickEquipment.reachable_height
        continue
    end
    
    for sku_percent = 0.1:0.1:1;
        
        c = c + 1;
        bays = sku_percent*total_sku_count;

        %% Dimensioning
        sd = Dimensioning(sd,bays,cross_aisle_width,sf);
        sd.GeneratePickerNetwork
        sd.GenerateStorageNetwork


        %% Calculate distances and times between storage locations
        [delta_ij, D, time_ij, T, I]=Distances_v01(sd);



        travel_time = zeros(100,1);
        for m = 1:100 % runs of Monte Carlo Simulation

            %% Batching (Monte Carlo Sampling)
            %Generate Orders (sample SKUs by frequency of access)
            %Combine orders 1..Equipment_Capacity

            stops=OrderBatching_v01(avg_order_lines,T,sd);


            %% Routing - Create Tours
            %Serpentine and skipping

            tour=SerpentineSkipping(stops,sd);


            %% Calculate travel time
            time = 0;
            for t = 1:length(tour)-1
                time = time + time_ij(I==tour(t),I==tour(t+1));
            end

            travel_time(m) = time/length(stops);
        end

        if c == 1
            mn = [e,sku_percent,mean(travel_time)];
            v= [e,sku_percent,var(travel_time)];
        else
            mn = [mn; [e,sku_percent,mean(travel_time)]];
            v = [v; [e,sku_percent,var(travel_time)]];
        end
        
    end
    
   e
end

figure
scatter3(mn(:,2),mn(:,1),mn(:,3),'filled')
xlabel('SKU percentage')
ylabel('Height')
zlabel('Cycle Time per Pick')

toc
% figure(2)
% scatter(combination(:,3),combination(:,9))
% xlabel('storage height')
% 
% figure(3)
% scatter(combination(:,4),combination(:,9))
% xlabel('capacity')
