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

height = 4;
batch_size = 30;

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
for h = 1:height
    
    % Storage dimensioning
    ground_slots(h) = ceil(slots / h);

    aisles(h) = 1;
    slots_per_aisle(h) = slots;
    aisle_length(h) = (slots_per_aisle(h) / h) * slot_length;        
    forward_length(h) = aisle_length(h) + 2 * cross_aisle_width;
    forward_width(h) = aisles(h) * aisle_module_width;

    while forward_length(h) > sf * forward_width(h)
        aisles(h) = aisles(h) + 1;
        slots_per_aisle(h) = slots / aisles(h);
        aisle_length(h) = (slots_per_aisle(h) / h) * slot_length;        
        forward_length(h) = aisle_length(h) + 2 * cross_aisle_width;
        forward_width(h) = aisles(h) * aisle_module_width;  
    end
    
    forward_area(h) = forward_length(h) * forward_width(h);
    final_slots(h) = aisles(h) * slots_per_aisle(h) * h;    
    
    for b = 1:batch_size        
        travel_distance(h,b) = 0.75 * sqrt(b * avg_oder_lines * forward_area(h)); % TSP approximation   
    end
    
end

figure
surfc(travel_distance)
xlabel('batch size')
ylabel('height')
zlabel('travel distance')