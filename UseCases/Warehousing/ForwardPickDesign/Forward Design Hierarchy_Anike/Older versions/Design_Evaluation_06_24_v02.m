%% Screening equiopments

% Product
%stackable hight

% Loading equipment (depends on product)
%length
%width
%hight


% Pick equipment
reachable_height = 4; % height in slots
aisle_width = 10; % in feet
%possible loading equipment
%velocity


% Storage equipment
storage_height = 4; % height in slots
slot_width = 3.33; % in feet
slot_length = 4; % in feet
%slot hight


% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot, random
% slotting, routing by TSP & complete serpentine

sf = 1; %shape factor (rectangle twice as long as wide)
cross_aisle_width = 15; % in feet
sku_percent = 0.2;
total_sku_count = 5000;

for height = 1:4
    for batch_size = 10:5:50

        % Storage dimensioning
        slots = ceil(sku_percent * total_sku_count);
        ground_slots = ceil(slots / height);
        
        aisle_module_width = 2 * slot_width + aisle_width; % aisle plus shelves on both sides
        aisles = 1;
        slots_per_aisle = slots;
        aisle_length = slots_per_aisle * slot_length;        
        forward_length = aisle_length + 2 * cross_aisle_width;
        forward_width = aisles * aisle_module_width;
        
        
        while forward_length > sf * forward_width
            
            
            
        end
        
        aisles = ceil((slot_length * ground_slots + 2 * cross_aisle_width) / (2 * sf * aisle_module_width));        
        slots_per_aisle = ceil((ground_slots * height) / aisles);
        final_slots = aisles * slots_per_aisle * height;
        
        PD_aisle = ceil(aisles/2);

        % Footprint
        aisle_length = slots_per_aisle * slot_length;        
        forward_length = aisle_length + 2 * cross_aisle_width;
        forward_width = aisles * aisle_module_width;
        
    end

end