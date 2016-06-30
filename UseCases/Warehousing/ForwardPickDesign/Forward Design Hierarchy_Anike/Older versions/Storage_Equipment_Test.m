seqSet(5) = Storage_Equipment;

for se = 1:5
    
    seqSet(se).ID = se;
    seqSet(se).storage_height = se;
    seqSet(se).slot_width = 3.33;
    seqSet(se).slot_length = 4;
    seqSet(se).slot_height = 6;
    seqSet(se).cost = 1000;
    
end

%seqSet = seqSet.sort;