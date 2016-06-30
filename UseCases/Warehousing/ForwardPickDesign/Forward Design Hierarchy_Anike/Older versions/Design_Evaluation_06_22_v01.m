%% Data

% Technology
aisle_width = 30;
slot_length = 10;
slot_width = 5;
cross_aisle_width = 30;
k = 50; %slots per aisle
height = 1;
v = 1; % velocity in m/s
a = 2; % acceleration in m/s^2

% Products
total_sku_count = 5000;
avg_order_lines = 7;

% Experiment
sku_percent = [0.15, 0.20, 0.25];
batch_size = 2;




%% Sizing and Dimensioning
% Assumptions: ladder structure

% Storage dimensioning
slots = ceil(sku_percent * total_sku_count);
ground_slots = ceil(slots / height);
aisles = ceil(ground_slots / (2 * k));
final_slots = aisles * 2 * k * height;

% Footprint
aisle_length = k * slot_length;
aisle_module_width = 2 * slot_width + aisle_width;
forward_length = aisle_length + 2 * cross_aisle_width;
forward_width = aisles * aisle_module_width;


%% SKU Selection
% % Assumptions: complete serpentine, central base
% 
% % Travel time
% if mod(aisles,2) == 0
% 	travel_distance = 2 * ((2 * slot_width + aisle_width) * (aisles - 1)) + aisles * (2 * cross_aisle_width + (1/2) * k * slot_length);
% else
% 	travel_distance = 2 * ((2 * slot_width + aisle_width) * (aisles - 1)) + (aisles + 1) * (2 * cross_aisle_width + (1/2) * k * slot_length);
% end
% 
% if travel_distance / avg_order_lines >= v / a
% 	travel_time_fw = travel_distance / v + (avg_order_lines + 1) * v / a;
% else
% 	travel_time_fw = (avg_order_lines + 1) * 2 * sqrt(travel_distance / (avg_order_lines * a));
% end
% 
% % Savings desity
% savings = 1/avg_order_lines * (travel_time_res - travel_time_fw);
% savings_density = (savings * demand_pick - cost_replenishment * demand_pallet) / lanes;
% 
% savings_sort = sort(savings_density, 'descend');
% 
% % Assignment
% for assign = 1:final_slot_count
% 	assigned_SKU(assign) = savings_sort(assign);
% end




%% Set up Experiment

%% Batching
% Generate Orders (sample SKUs by frequency of access)
% Combine orders 1..Equipment_Capacity

for b = 1:batch_size
    if b == 1
        order = randsample(final_slots(1), avg_order_lines); %, true, FoA);
    else
        order = [order, randsample(final_slots(1), avg_order_lines)]; %, true, FoA);
    end
end

stops = unique(order);
stop_count = length(stops);



%% Slotting Algorithms

% most frequent <-> most desirable
% random



%% Routing Algorithms


% TSP
m = 1;
for i = 1:stop_count
    for j = 1:stop_count
        dist(i,j) = delta_ij(stops(i), stops(j));
    end
end

Aeq = spones(1:length(dist));
beq = stop_count;


% Complete serpentine
td = 2 * ((2 * slot_width + aisle_width) * (aisles - 1)) + aisles * (2 * cross_aisle_width + (1/2) * k * slot_length);


% Serpentine and skipping
% Return
% Split return
% Largest gap





%% Evaluation
% Calculate distance based on different routing policies
% Convert distance into travel time? Pick time? (to evaluate longer picking
% times for bigger batches)
% Evaluate combination of Slotting, Routing, Batching



% Travel time vs. computational effort???
% 3D plot of travel time / travel distance?