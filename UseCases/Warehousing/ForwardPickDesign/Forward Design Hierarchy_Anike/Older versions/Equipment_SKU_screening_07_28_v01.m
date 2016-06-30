%% Screening equipment heights an number of SKUs
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot, 
% slotting most frequent<->most desirable, routing by serpentine and skipping



%% Initialize screening for equipment

sd(50) = Storage_Department;

maxHeight = sd.maxHeight;
c = 1;

tic
%% Screening
for e = 1:maxHeight

    for sku_percent = 0.1:0.1:1;
        
        sd(c).ID = c;
        sd(c).sku_percent = sku_percent;
        
        sd(c).StorageEquipment = Storage_Equipment;
        sd(c).StorageEquipment.ID = e;
        sd(c).StorageEquipment.storage_height = e;
        
        sd(c).PickEquipment = Pick_Equipment;
        sd(c).PickEquipment.ID = e;
        sd(c).PickEquipment.reachable_height = e;
        
        
        %% Dimensioning
        sd(c).Dimensioning
        
        sd(c).GeneratePickerNetwork
        sd(c).GenerateStorageNetwork


        %% Calculate distances and times between storage locations
        sd(c).Distances
        
        
        %% Simulation (determine mean time per stop)
        travel_time = zeros(50,1);
        for m = 1:50 % runs of Monte Carlo Simulation

            % Batching (Monte Carlo Sampling)
            stops = sd(c).GenerateBatches;

            % Routing - Create Tours
            tour = sd(c).NearestNeighbor(stops);

            % Calculate travel time
            time = sd(c).TourTravelTime(tour);

            travel_time(m) = (time + sd(c).penalty * length(stops))/length(stops);
        end
        
        %% Calculate metrics (mean travel time per stop, footprint)
        if c == 1
            mn = [e,sku_percent,mean(travel_time)];
            v = [e,sku_percent,var(travel_time)];
        else
            mn = [mn; [e,sku_percent,mean(travel_time)]];
            v = [v; [e,sku_percent,var(travel_time)]];
        end
        
        forward_length = sd(c).aisle_length(1) + 2 * sd(c).cross_aisle_width;
        forward_width = sd(c).aisles * sd(c).aisle_module_width;
        
        sd(c).mn_time_per_stop = mean(travel_time);
        sd(c).footprint = forward_length * forward_width;
        
        c = c + 1;
        
    end
    
   e
end


%% Plot 
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