clear
clc
%% Screening equipments
% Assume: ladder structure, SKU assignment by FoA, allocation 1 SKU per slot, random
% slotting, routing by TSP


% Initialize screening for equipment
aisle_width = 10; % in feet
slot_width = 3.33; % in feet
slot_length = 4; % in feet
sf = 2; %shape factor (rectangle twice as long as wide)
cross_aisle_width = 15; % in feet

avg_oder_lines = 10;
sku_percent = 0.2;
total_sku_count = 5000;

aisle_module_width = 2 * slot_width + aisle_width; % aisle plus shelves on both sides
slots = ceil(sku_percent * total_sku_count);

ground_slots = zeros(height, 1);
aisles = zeros(height,1);
slots_per_aisle = zeros(height,1);
aisle_length = zeros(height,1);
forward_length = zeros(height,1);
forward_width = zeros(height,1);
forward_area = zeros(height,1);
final_slots = zeros(height,1);
travel_distance = zeros(height, batch_size);


% Screening
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
    
    forward_area(height) = forward_length(height) * forward_width(height);
    final_slots(height) = aisles(height) * slots_per_aisle(height) * height;    
    
    b = 1;
    
    for batch_size = 1:30        
        travel_distance(height,b) = 0.75 * sqrt(batch_size * avg_oder_lines * forward_area(height)); % TSP approximation
        b = b + 1;        
    end
    
end

figure
surfc(travel_distance)
xlabel('batch size')
ylabel('height')
zlabel('travel distance')