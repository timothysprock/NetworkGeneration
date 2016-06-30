%% Build the storage department

sf = 2; %shape factor (rectangle twice as long as wide)

avg_order_lines = 10;
sku_percent = 0.20;
total_sku_count = 5000;

cross_aisle_width = 10;
bays = ceil(sku_percent * total_sku_count);

sd = Storage_Department;
sd.StorageEquipment = seqSet(1);
sd.PickEquipment = peqSet(1); 

sd = Dimensioning(sd,bays,cross_aisle_width,sf);

sd.GeneratePickerNetwork
sd.GenerateStorageNetwork

%% Calculate distances and times between storage locations
tic
[delta_ij, D, time_ij, T, I]=Distances_v01(sd);
toc


%% Simulation
travel_time = zeros(500,1);
for m = 1:500
    %% Batching (Monte Carlo Sampling)
    %Generate Orders (sample SKUs by frequency of access)
    %Combine orders 1..Equipment_Capacity

    stops=OrderBatching(avg_order_lines,T,sd);


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

mn = mean(travel_time)
v = var(travel_time)

figure
hist(travel_time,20)

sd.PlotNetworks