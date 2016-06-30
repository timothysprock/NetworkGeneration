%% Screening capacity, speed, and fleet mix
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot,
% slotting most frequent<->most desirable, routing by serpentine and skipping

%% Initialize screening for shape factor

% Find storage department with minimum time per stop
[minT, idx] = min(aisles(:,2));
sd_minT = sd_sf(aisles(idx,1));

sd_bh(p) = Storage_Department;
mn_max_time = zeros(p,1);
mn_time = zeros(p,1);
var_cost = zeros(p,1);
cap_cost = zeros(p,1);

%% Generate fleet mixes to be investigated 

%(homogenious fleets, latin hypercube fleet size, capacity, vertical and horizontal speed)
p = 100; % number of points
N = 4; % number of variables
lb = [1,1,55/60,200/60]; % lower bounds for variables
ub = [20,10,70/60,600/60]; % upper bounds for variables

X = lhsdesign(p,N);
mix = bsxfun(@plus,lb,bsxfun(@times,X,(ub-lb)));
mix(:,[1,2]) = round(mix(:,[1,2]));


%% Screening
for b = 1:p % points in latin hypercube design
    sd_bh(b) = Storage_Department;
    sd_bh(b) = sd_minT;
    sd_bh(b).fleet_size = mix(b,1);
    sd_bh(b).PickEquipment.capacity = mix(b,2);
    sd_bh(b).PickEquipment.vertical_velocity = mix(b,3);
    sd_bh(b).PickEquipment.horizontal_velocity = mix(b,4);

    sd_bh(b).time_ij = sd_bh(b).delta_ij./sd_bh(b).PickEquipment.horizontal_velocity;
    
    time_ij = sd_bh(b).time_ij;
    T = sd_bh(b).T;
    I = sd_bh(b).I;
    
    %% Evaluate time it takes to clear out 100 orders
    % Generate 100 orders (without replacement within a group of orders (1
    % to capacity)) and calculate the times it takes to pick each batch
    max_time = zeros(50,1);
    mn_travel_time = zeros(50,1);
    tours = floor(100/sd_bh(b).PickEquipment.capacity);
    for m = 1:50
        travel_time = zeros(tours,1);
        for o = 1:tours
            % Batching (Monte Carlo Sampling)
            stops = sd_bh(b).OrderBatching;

            % Routing - Create Tours
            tour = sd_bh(b).NearestNeighbor(stops);

            % Calculate travel time
            time = sd_bh(b).TourTravelTime(tour);
            
            travel_time(o) = time + penalty * length(stops);
        end
        
        if tours * sd_bh(b).PickEquipment.capacity < 100
            % Batching (Monte Carlo Sampling)
            stops = OrderBatching_v02(100-(length(travel_time)*sd_bh(b).PickEquipment.capacity),T,sd_bh(b));
            
            % Routing - Create Tours
            tour = sd_bh(b).NearestNeighbor(stops);

            % Calculate travel time
            time = sd_bh(b).TourTravelTime(tour);
            
            travel_time(end+1) = time + penalty * length(stops);  
        end
        
        
        % Assign travel times to each member of the fleet
        time_assigned = zeros(length(travel_time),sd_bh(b).fleet_size);
        for o = 1:length(travel_time)
            colum_sum = sum(time_assigned,1);
            [min_time,idx] = min(colum_sum);
            time_assigned(o,idx) = travel_time(o);
        end
        colum_sum = sum(time_assigned,1);
        max_time(m) = max(colum_sum);
        mn_travel_time(m) = mean(travel_time);
    end
    
    %% Calculate metrics (time to clear ou 100 orders, mean time per tour, variable and capital cost)
    mn_max_time(b) = mean(max_time);
    mn_time(b) = mean(mn_travel_time);
    
    var_cost(b) = mn_max_time(b)/3600 * sd_bh(b).PickEquipment.variable_cost * sd_bh(b).PickEquipment.fleet_size;
    cap_cost(b) = sd_bh(b).PickEquipment.fleet_size * sd_bh(b).PickEquipment.fixed_cost + sd_bh(b).StorageEquipment.fixed_cost;
    
    sd_bh(b).time100 = mn_max_time(b);
    sd_bh(b).time_per_tour = mn_time(b);
    
    b
end


%% Plot duration vs. capital cost and variable cost for each fleet mixfigure
figure
scatter3(var_cost,cap_cost,mn_max_time,'filled')
title('Screening Forward Behavior (capacity, speed, fleet size)')
xlabel('Variable Cost')
ylabel('Capital Cost')
zlabel('Time required to clear out 100 orders [s]')

figure
scatter3(var_cost,cap_cost,mn_time,'filled')
title('Screening Forward Behavior (capacity, speed, fleet size)')
xlabel('Variable Cost')
ylabel('Capital Cost')
zlabel('Avg time per tour [s]')