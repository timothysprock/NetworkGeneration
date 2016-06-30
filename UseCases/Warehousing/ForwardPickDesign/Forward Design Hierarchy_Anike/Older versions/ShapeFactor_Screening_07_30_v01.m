%% Screening shape factor
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot,
% slotting most frequent<->most desirable, routing by serpentine and skipping

%% Initialize screening for shape factor

% Find storage department with minimum time per stop
[minT, idx] = min(mn);
sd_minT = sd(idx);

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
    sd_sf(s).Dimensioning
    sd_sf(s).GeneratePickerNetwork
    sd_sf(s).GenerateStorageNetwork
    %sd_sf(s).PlotNetworks

    %% Distances and times between storage locations
    sd_sf(s).Distances
    
    %% Simulation to determine mean time per stop
    [mn_time_per_stop,variance] = sd_sf(s).getMeanTimePerStop;
    
    %% Create arrays for plot
    mn(s) = mn_time_per_stop;
    e(s) = sqrt(variance);
    aisle_count(s) = sd_sf(s).aisles;
    
    if (s>1 && aisle_count(s-1)>aisle_count(s))
        aisles(a,1)=s;
        aisles(a,2)=mn(s);
        a=a+1;
    end
    
    s = s +1;

end

%% Plot
figure
errorbar(mn,e)
title('Screening Shape Factor')
xlabel('Shape Factor')
ylabel('Mean travel time per stop [s]')

hold on
scatter(aisles(:,1),aisles(:,2))
hold off

toc

