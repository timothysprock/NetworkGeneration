%% Screening capacity, speed, and fleet mix
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot,
% slotting most frequent<->most desirable, routing by serpentine and skipping

%% Initialize screening for shape factor
% avg_order_lines = 10;
% total_sku_count = 5000;
% 
% cross_aisle_width = 10;
% 
% [minT, idx] = min(aisles(:,2));
% sd_minT = sd_sf(aisles(idx,1));


%% Generate fleet mixes to be investigated 
%(homogenious fleets, latin hypercube fleet size, capacity, vertical and horizontal speed)

p = 100; % number of points
N = 4; % number of dimensions
lb = [1,1,55/60,200/60]; % lower bounds for variables
ub = [10,10,70/60,600/60]; % upper bounds for variables

X = lhsdesign(p,N);
mix = bsxfun(@plus,lb,bsxfun(@times,X,(ub-lb)));
mix(:,[1,2]) = round(mix(:,[1,2]));

sd_bh(p) = Storage_Department;
max_time = zeros(p,1);
var_cost = zeros(p,1);
cap_cost = zeros(p,1);

for b = 1:p
    sd_bh(b) = Storage_Department;
    sd_bh(b) = sd_minT;
    sd_bh(b).PickEquipment.fleet_size = mix(b,1);
    sd_bh(b).PickEquipment.capacity = mix(b,2);
    sd_bh(b).PickEquipment.vertical_velocity = mix(b,3);
    sd_bh(b).PickEquipment.horizontal_velocity = mix(b,4);

    [delta_ij, D, time_ij, T, I]=Distances_v01(sd_bh(b));

    %% Evaluate time it takes to clear out 100 orders
    % Generate 100 orders (without replacement within a group of orders (1
    % to capacity)) and calculate the times it takes to pick each batch
    
    travel_time = zeros(floor(100/sd_bh(b).PickEquipment.capacity),1);
    for o = 1:floor(100/sd_bh(b).PickEquipment.capacity)
        stops = OrderBatching_v01(avg_order_lines,T,sd_bh(b));
        tour = SerpentineSkipping(stops,sd_bh(b));
        time = 0;
        for t = 1:length(tour)-1
            time = time + time_ij(I==tour(t),I==tour(t+1));
        end
        travel_time(o) = time;
    end
    
    % Assign travel times to each member of the fleet
    time_assigned = zeros(length(travel_time),sd_bh(b).PickEquipment.fleet_size);
    for o = 1:length(travel_time)
        colum_sum = sum(time_assigned,1);
        [min_time,idx] = min(colum_sum);
        time_assigned(o,idx) = travel_time(o);
    end
    colum_sum = sum(time_assigned,1);
    max_time(b) = max(colum_sum);
    var_cost(b) = max_time(b)/3600 * sd_bh(b).PickEquipment.variable_cost * sd_bh(b).PickEquipment.fleet_size;
    cap_cost(b) = sd_bh(b).PickEquipment.fleet_size * sd_bh(b).PickEquipment.fixed_cost + sd_bh(b).StorageEquipment.fixed_cost;
    
    b
end


%% Plot duration vs. capital cost and variable cost for each fleet mixfigure
figure
scatter3(var_cost,cap_cost,max_time,'filled')
xlabel('Variable Cost')
ylabel('Capital Cost')
zlabel('Time required for clearing out 100 orders')