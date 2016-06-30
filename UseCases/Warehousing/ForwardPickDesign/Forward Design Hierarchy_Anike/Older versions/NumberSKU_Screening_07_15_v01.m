%% Screening number SKUs
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot,
% slotting most frequent<->most desirable, routing by serpentine and skipping

%% Initialize screening for number of SKUs
sf = 2; %shape factor (rectangle twice as long as wide)

avg_order_lines = 10;
total_sku_count = 5000;

cross_aisle_width = 10;

sd = Storage_Department;
sd.StorageEquipment = seqSet(5);
sd.PickEquipment = peqSet(8); 


%% Screening number SKUs
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot,
% slotting most frequent<->most desirable, routing by serpentine and skipping

mn = zeros(10,1);
e = zeros(10,1);
s = 1;
tic
%% Screening
for sku_percent = 0.1:0.1:1;
    bays = sku_percent*total_sku_count;
    
    %% Dimensioning
    sd = Dimensioning(sd,bays,cross_aisle_width,sf);
    sd.GeneratePickerNetwork
    sd.GenerateStorageNetwork
    
    %% Calculate distances and times between storage locations
    [delta_ij, D, time_ij, T]=Distances(sd);
    
    travel_time = zeros(100,1);
    for m = 1:100 % runs of Monte Carlo Simulation

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
            time = time + time_ij(tour(t),tour(t+1));
        end

        travel_time(m) = time/length(stops);
    end
    mn(s) = mean(travel_time);
    e(s)=std(travel_time,1);
    s
    s = s +1;

end

figure
errorbar(mn,e)
title('Screening number of SKUs')
xlabel('SKU percentage')
ylabel('Mean travel time per stop')

toc

