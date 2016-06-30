%% Screening equipments
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot, random
% slotting, routing by TSP


% Initialize screening for equipment
sf = 1; %shape factor (rectangle twice as long as wide)
cross_aisle_width = 15; % in feet

avg_order_lines = 10;
sku_percent = 0.2;
total_sku_count = 5000;

slots = ceil(sku_percent * total_sku_count);

c = 0; % counts number of combinations
travel_distance = zeros(length(seqSet),length(peqSet));
travel_distance_pick = zeros(length(seqSet),length(peqSet));
cycle_time = zeros(length(seqSet),length(peqSet));
cycle_time_pick = zeros(length(seqSet),length(peqSet));

% Screening
for s = 1:length(seqSet)

    slot_width = seqSet(s).slot_width; 
    slot_length = seqSet(s).slot_length;
    slot_height = seqSet(s).slot_height;
    
    sHeight = seqSet(s).storage_height;

    for p = 1:length(peqSet)
        
        pHeight = peqSet(p).reachable_height;
        
        % Check compatibility
        if sHeight > pHeight
            continue
        end
        
        c = c + 1;
        
        aisle_width = peqSet(p).req_aisle_width; 
        batch_size = peqSet(p).capacity;
        hVelocity = peqSet(p).horizontal_velocity;
        vVelocity = peqSet(p).vertical_velocity;
        
        % Initialize dimensioning
        aisle_module_width = 2 * slot_width + aisle_width; % aisle plus shelves on both sides
        ground_slots = ceil(slots / sHeight);
        
        aisles = 1;
        slots_per_aisle = slots;
        aisle_length = (slots_per_aisle / sHeight) * slot_length;        
        forward_length = aisle_length + 2 * cross_aisle_width;
        forward_width = aisles * aisle_module_width;

        while forward_length > sf * forward_width
            aisles = aisles + 1;
            slots_per_aisle = slots / aisles;
            aisle_length = (slots_per_aisle / sHeight) * slot_length;        
            forward_length = aisle_length + 2 * cross_aisle_width;
            forward_width = aisles * aisle_module_width;  
        end

        forward_area = forward_length * forward_width;  
        travel_distance(s,p) = 1.15 * sqrt(batch_size * avg_order_lines * forward_area); % TSP approximation on a grid, in feet (IMPLEMENTING VEHICLE ROUTING MODELS, 1989, Robuste, Daganzo, et al.)
        travel_distance_pick(s,p) = travel_distance(s,p) / (batch_size * avg_order_lines);
        cycle_time(s,p) = travel_distance(s,p) / hVelocity + (1/2 * sHeight * slot_height) / vVelocity; % in minutes
        cycle_time_pick(s,p) = cycle_time(s,p) / (batch_size * avg_order_lines);
        
        combination(c,1) = seqSet(s).ID;
        combination(c,2) = peqSet(p).ID;
        combination(c,3) = sHeight;
        combination(c,4) = batch_size;
        combination(c,5) = forward_area;
        combination(c,6) = travel_distance(s,p);
        combination(c,7) = travel_distance_pick(s,p);
        combination(c,8) = cycle_time(s,p);
        combination(c,9) = cycle_time_pick(s,p);
        
   end
end

% figure(1)
% surfc(travel_distance)
% xlabel('Pick Equipment (batch size)')
% ylabel('Storage Equipment (height)')
% zlabel('Travel Distance')
% 
% figure(2)
% scatter(combination(:,3),combination(:,6))
% xlabel('storage height')
% 
% figure(3)
% scatter(combination(:,4),combination(:,6))
% xlabel('capacity')

figure(1)
surfc(cycle_time_pick)
xlabel('Pick Equipment (batch size)')
ylabel('Storage Equipment (height)')
zlabel('Cycle Time per Pick')

figure(2)
scatter(combination(:,3),combination(:,9))
xlabel('storage height')

figure(3)
scatter(combination(:,4),combination(:,9))
xlabel('capacity')