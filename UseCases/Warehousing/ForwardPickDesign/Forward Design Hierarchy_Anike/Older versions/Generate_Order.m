%% Batching
% Generate Orders (sample SKUs by frequency of access)
% Combine orders 1..Equipment_Capacity

avg_order_lines = 10;
batch_size = sd.PickEquipment.capacity;

for b = 1:batch_size
    if b == 1
        order = randsample(length(sd.StorageNetwork.NodeSetList), avg_order_lines); %, true, FoA);
    else
        order = [order, randsample(length(sd.StorageNetwork.NodeSetList), avg_order_lines)]; %, true, FoA);
    end
end

stops = unique(order);
stop_count = length(stops);