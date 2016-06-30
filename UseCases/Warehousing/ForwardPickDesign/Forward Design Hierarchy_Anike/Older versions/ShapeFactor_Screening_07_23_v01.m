%% Screening shape factor
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot,
% slotting most frequent<->most desirable, routing by serpentine and skipping

%% Initialize screening for shape factor
avg_order_lines = 10;
total_sku_count = 5000;

cross_aisle_width = 10;

[minT, idx] = min(mn(:,3));
sd_minT = sd(idx);

sku_percent = mn(idx,2);
bays = sku_percent*total_sku_count;


%% Screening Shape Factor
sd_sf(11) = Storage_Department;
aisle_count = zeros(11,1);
mn = zeros(11,1);
e = zeros(11,1);
s = 1;
a = 1;
tic
%% Screening
for sf = 1:0.2:3; %shape factor;
    
    sd_sf(s)= sd_minT;
    sd_sf(s).shape_factor = sf;
    
    %% Dimensioning
    sd_sf(s) = Dimensioning(sd_sf(s),bays,cross_aisle_width,sf);
    sd_sf(s).GeneratePickerNetwork
    sd_sf(s).GenerateStorageNetwork
    %sd.PlotNetworks

    %% Calculate distances and times between storage locations
    [delta_ij, D, time_ij, T, I]=Distances_v01(sd_sf(s));
    sd_sf(s).delta_ij = delta_ij;
    sd_sf(s).time_ij = time_ij;
    sd_sf(s).D = D;
    sd_sf(s).T = T;
    sd_sf(s).I = I;
    
    travel_time = zeros(100,1);
    for m = 1:100 % runs of Monte Carlo Simulation

        %% Batching (Monte Carlo Sampling)
        %Generate Orders (sample SKUs by frequency of access)
        %Combine orders 1..Equipment_Capacity

        stops=OrderBatching_v01(avg_order_lines,T,sd_sf(s));


        %% Routing - Create Tours
        %Serpentine and skipping

        tour=SerpentineSkipping(stops,sd_sf(s));


        %% Calculate travel time
        time = 0;
        for t = 1:length(tour)-1
            time = time + time_ij(I==tour(t),I==tour(t+1));
        end

        travel_time(m) = (time + penalty * length(stops))/length(stops);
    end
    mn(s) = mean(travel_time);
    e(s) = std(travel_time,1);
    aisle_count(s) = sd_sf(s).aisles;
    
    sd_sf(s).travel_time_per_stop = mn(s);
    
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
ylabel('Mean travel time per stop [s]')

hold on
scatter(aisles(:,1),aisles(:,2))
hold off

toc

