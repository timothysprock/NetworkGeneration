peqSet(10) = Pick_Equipment;

for pe = 1:10
    
    peqSet(pe).ID = pe;
    peqSet(pe).reachable_height = ceil(0.5*pe);
    peqSet(pe).req_aisle_width = 2 * pe;
    peqSet(pe).capacity = 2 * pe;
    peqSet(pe).vertical_velocity = 62;
    peqSet(pe).horizontal_velocity = 502;
    peqSet(pe).cost = 1000;
    
end

%peqSet = peqSet.sort;