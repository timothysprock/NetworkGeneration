%% Screening equipment heights an number of SKUs
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot, 
% slotting most frequent<->most desirable, routing by serpentine and skipping



%% Initialize screening for equipment
sf = 1; %shape factor
maxHeight = 5;

avg_order_lines = 10;
total_sku_count = 5000;

cross_aisle_width = 10;

penalty = 2; % time penalty for each stop, in seconds

sd(50) = Storage_Department;
c = 1;

tic
%% Screening
for e = 1:maxHeight

    for sku_percent = 0.1:0.1:1;
        
        sd(c).ID = c;
        
        sd(c).StorageEquipment = Storage_Equipment;
        sd(c).StorageEquipment.ID = e;
        sd(c).StorageEquipment.storage_height = e;
        
        sd(c).PickEquipment = Pick_Equipment;
        sd(c).PickEquipment.ID = e;
        sd(c).PickEquipment.reachable_height = e;

        bays = sku_percent*total_sku_count;

        %% Dimensioning
        sd(c) = Dimensioning(sd(c),bays,cross_aisle_width,sf);
        
        forward_length = sd(c).aisle_length(1) + 2 * sd(c).cross_aisle_width;
        forward_width = sd(c).aisles * sd(c).aisle_module_width;

        sd(c).GeneratePickerNetwork
        sd(c).GenerateStorageNetwork


        %% Calculate distances and times between storage locations
        [delta_ij, D, time_ij, T, I] = Distances_v01(sd(c));
        sd(c).delta_ij = delta_ij;
        sd(c).time_ij = time_ij;
        sd(c).D = D;
        sd(c).T = T;
        sd(c).I = I;

        travel_time = zeros(50,1);
        for m = 1:50 % runs of Monte Carlo Simulation

            %% Batching (Monte Carlo Sampling)
            %Generate Orders (sample SKUs by frequency of access)
            %Combine orders 1..Equipment_Capacity

            stops = OrderBatching_v01(avg_order_lines,T,sd(c));


            %% Routing - Create Tours
            %TSP - Nearest neighbor

            tour = NearestNeighbor(stops,sd(c));


            %% Calculate travel time
            time = 0;
            for t = 1:length(tour)-1
                time = time + time_ij(I==tour(t),I==tour(t+1));
            end

            travel_time(m) = (time + penalty * length(stops))/length(stops);
        end

        if c == 1
            mn = [e,sku_percent,mean(travel_time)];
            v = [e,sku_percent,var(travel_time)];
        else
            mn = [mn; [e,sku_percent,mean(travel_time)]];
            v = [v; [e,sku_percent,var(travel_time)]];
        end
        
        sd(c).travel_time_per_stop = mean(travel_time);
        sd(c).footprint = forward_length * forward_width;
        
        c = c + 1;
        
    end
    
   e
end


% Plot 
match = findobj(sd, '-function', 'travel_time_per_stop', @(x)(x<20), '-and', '-function', 'footprint', @(y)(y<2e04));
color = repmat([0,0,1],50,1);
for i = 1:length(match)
    color(match(i).ID,:) = [0,1,0];
end
figure
scatter3(mn(:,2),mn(:,1),mn(:,3),ones(50,1)*36,color,'filled')
title('Screening Forward Structure')
xlabel('SKU percentage')
ylabel('Height')
zlabel('Mean travel time per stop [s]')


% figure
% plot3d_errorbars(mn(:,2),mn(:,1),mn(:,3),sqrt(v(:,3)))
% xlabel('SKU percentage')
% ylabel('Height')
% zlabel('Mean travel time per stop')

toc