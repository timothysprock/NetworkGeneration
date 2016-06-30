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

sf = 2; %shape factor (rectangle twice as long as wide)
cross_aisle_width = 15; % in feet
sku_percent = 0.2;
total_sku_count = 5000;

aisle_module_width = 2 * slot_width + aisle_width; % aisle plus shelves on both sides
slots = ceil(sku_percent * total_sku_count);

for height = 1:4
    
    % Storage dimensioning
    ground_slots(height) = ceil(slots / height);

    aisles(height) = 1;
    slots_per_aisle(height) = slots;
    aisle_length(height) = (slots_per_aisle(height) / height) * slot_length;        
    forward_length(height) = aisle_length(height) + 2 * cross_aisle_width;
    forward_width(height) = aisles(height) * aisle_module_width;

    while forward_length(height) > sf * forward_width(height)
        aisles(height) = aisles(height) + 1;
        slots_per_aisle(height) = slots / aisles(height);
        aisle_length(height) = (slots_per_aisle(height) / height) * slot_length;        
        forward_length(height) = aisle_length(height) + 2 * cross_aisle_width;
        forward_width(height) = aisles(height) * aisle_module_width;  
    end

    final_slots(height) = aisles(height) * slots_per_aisle(height) * height;

    PD_aisle(height) = floor(aisles(height)/2);
    
    
    for batch_size = 10:5:50

        
        
    end

end