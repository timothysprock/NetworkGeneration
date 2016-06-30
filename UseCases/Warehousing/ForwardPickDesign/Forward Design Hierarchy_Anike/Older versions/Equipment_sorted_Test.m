n = 5; % number of equipments to be generated

% Pick equipment
peqSet(n) = Pick_Equipment;

for pe = 1:n
    
    peqSet(pe).ID = pe;
    peqSet(pe).reachable_height = pe;
    peqSet(pe).req_aisle_width = 5;
    peqSet(pe).cost = 1000;
    
end



% Storage equipment
seqSet(n) = Storage_Equipment;

for se = 1:n
    
    seqSet(se).ID = se;
    seqSet(se).storage_height = se;
    seqSet(se).cost = 1000;
    
end