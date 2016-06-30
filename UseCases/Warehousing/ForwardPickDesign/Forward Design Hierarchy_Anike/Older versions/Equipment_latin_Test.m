n = 40; % number of equipments to be generated

% Latin hypercube sampling
n_sample = lhsdesign(n,2);
sample = bsxfun(@plus,[1,1],bsxfun(@times,n_sample,[4,4]));
sample = round(sample);


% Pick equipment
peqSet(n) = Pick_Equipment;

for pe = 1:n
    
    peqSet(pe).ID = pe;
    peqSet(pe).reachable_height = sample(pe,1);
    peqSet(pe).req_aisle_width = unifrnd(5,n);
    peqSet(pe).capacity = unidrnd(10);
    peqSet(pe).vertical_velocity = unifrnd(55,70)/60;
    peqSet(pe).vertical_acc = 6;
    peqSet(pe).horizontal_velocity = unifrnd(200,600)/60;
    peqSet(pe).horizontal_acc = 10;
    peqSet(pe).cost = 1000;
    
end

peqSet = peqSet.sort;



% Storage equipment
seqSet(n) = Storage_Equipment;

for se = 1:n
    
    seqSet(se).ID = se;
    seqSet(se).storage_height = sample(se,2);
    seqSet(se).bay_width = 3.33;
    seqSet(se).bay_length = 4;
    seqSet(se).bay_height = 4;
    seqSet(se).cost = 1000;
    
end

seqSet = seqSet.sort;