%% Screening shape factor
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot,
% slotting most frequent<->most desirable, routing by serpentine and skipping

%% Initialize screening for shape factor
sku_percent = 0.2;

avg_order_lines = 10;
total_sku_count = 5000;
bays = sku_percent*total_sku_count;

cross_aisle_width = 10;
    
sd = Storage_Department;
sd.StorageEquipment = seqSet(25);
sd.PickEquipment = peqSet(7); 


%% Screening number SKUs
aisle_count = zeros(11,1);
mn = zeros(11,1);
e = zeros(11,1);
s = 1;
a = 1;
tic
%% Screening
for sf = 1:0.2:3; %shape factor;
    
    %% Dimensioning
    sd = Dimensioning(sd,bays,cross_aisle_width,sf);
    sd.GeneratePickerNetwork
    sd.GenerateStorageNetwork
    %sd.PlotNetworks

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
    mn(s) = mean(travel_time);
    e(s)=std(travel_time,1);
    aisle_count(s) = sd.aisles;
    
    if (s>1 && aisle_count(s-1)>aisle_count(s))
        aisles(a,1)=s;
        aisles(a,2)=mn(s);
        a=a+1;
    end
    
    s
    s = s +1;

end

figure
errorbar(mn,e)
title('Screening Shape Factor')
xlabel('Shape Factor')
ylabel('Mean travel time per stop')

hold on
scatter(aisles(:,1),aisles(:,2))
hold off

toc

