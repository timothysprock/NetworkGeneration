%% Screening equipments
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot, random
% slotting, routing by TSP


% Initialize screening for equipment
sf = 2; %shape factor (rectangle twice as long as wide)
cross_aisle_width = 15; % in feet

avg_oder_lines = 10;
sku_percent = 0.2;
total_sku_count = 5000;

slots = ceil(sku_percent * total_sku_count);

c = 0; % counts number of combinations
travel_distance = zeros(length(seqSet),length(peqSet));

% Screening
for s = 1:length(seqSet)

    slot_width = seqSet(s).slot_width; 
    slot_length = seqSet(s).slot_length; 
    
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
        travel_distance(s,p) = 0.75 * sqrt(batch_size * avg_oder_lines * forward_area); % TSP approximation
        
        combination(c,1) = seqSet(s).ID;
        combination(c,2) = peqSet(p).ID;
        combination(c,3) = travel_distance(s,p);
        combination(c,4) = forward_area;
        
        
   end
end

figure
surfc(travel_distance)
xlabel('Pick Equipment (batch size)')
ylabel('Storage Equipment (height)')
zlabel('Travel Distance')