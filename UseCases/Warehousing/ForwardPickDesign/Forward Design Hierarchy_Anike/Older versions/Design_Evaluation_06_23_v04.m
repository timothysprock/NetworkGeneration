%% Data

% Technology
aisle_width = 30;
slot_length = 10;
slot_width = 5;
cross_aisle_width = 30;
k = 50; %slots per aisle
height = 1;
v = 1; % velocity in m/s
a = 2; % acceleration in m/s^2
capacity = 6;

% Products
total_sku_count = 5000;
avg_order_lines = 7;
%FoA
%demand_pick
%demand_pallet

% Reserve Area
%travel_time_res
%cost_replenishment



%% Sizing and Dimensioning
for sku_percent = 0.15:0.05:0.25    
    % Assumptions: ladder structure

    % Storage dimensioning
    slots = ceil(sku_percent * total_sku_count);
    ground_slots = ceil(slots / height);
    aisles = ceil(ground_slots / (2 * k));
    final_slots = aisles * 2 * k * height;
    PD_aisle = ceil(aisles/2);

    % Footprint
    aisle_length = k * slot_length;
    aisle_module_width = 2 * slot_width + aisle_width;
    forward_length = aisle_length + 2 * cross_aisle_width;
    forward_width = aisles * aisle_module_width;


    %% SKU Selection
    % % Assumptions: complete serpentine, central base
    % 
    % % Travel time
    % if mod(aisles,2) == 0
    % 	travel_distance = 2 * ((2 * slot_width + aisle_width) * (aisles - 1)) + aisles * (2 * cross_aisle_width + (1/2) * k * slot_length);
    % else
    % 	travel_distance = 2 * ((2 * slot_width + aisle_width) * (aisles - 1)) + (aisles + 1) * (2 * cross_aisle_width + (1/2) * k * slot_length);
    % end
    % 
    % if travel_distance / avg_order_lines >= v / a
    % 	travel_time_fw = travel_distance / v + (avg_order_lines + 1) * v / a;
    % else
    % 	travel_time_fw = (avg_order_lines + 1) * 2 * sqrt(travel_distance / (avg_order_lines * a));
    % end
    % 
    % % Savings desity
    % savings = 1/avg_order_lines * (travel_time_res - travel_time_fw);
    % savings_density = (savings * demand_pick - cost_replenishment * demand_pallet) / lanes;
    % 
    % savings_sort = sort(savings_density, 'descend');
    % 
    % % Assignment
    % for assign = 1:final_slot_count
    % 	assigned_SKU(assign) = savings_sort(assign);
    % end







    %% Generate Layout

    fw = Storage_Department;
    fw.aisles = aisles;
    fw.aisle_width = aisle_width;
    fw.k = 50;
    fw.orientation = 0;
    fw.offset = [0, 0];
    fw.aisle_length = aisle_length * ones(1, aisles);
    fw.GeneratePickerNetwork;
    
    % Generate Movement Network!!
    
    
    %% Calculate Relative Value of Each Storage Location.
    A = list2adj([MovementNetwork.EdgeSetList(:, 2:end); StorageNetwork.EdgeSetList(:, 2:end)]);
    tic
    %PD = find(NodeSetList(:,2) == 0.5*aisle_width+PD_aisle*aisle_width & NodeSetList(:,3) == 0);
    PD = findobj(MovementNetwork.NodeSet, 'Type', 'P&D');
    D = dijk(A, PD.Node_ID, StorageNetwork.NodeSetList(:,1));
    N = length(StorageNetwork.NodeSetList(:,1));
    if N > 200
        delta_ij = zeros(N);
            parfor i= 1:N
                delta_ij(i, :) = dijk(A, StorageNetwork.NodeSetList(i,1), StorageNetwork.NodeSetList(:,1));
            end
    else
        delta_ij = dijk(A, StorageNetwork.NodeSetList(:,1), StorageNetwork.NodeSetList(:,1));
    end
    toc


%% Set up Experiment



    %% Batching
    for batch_size = 1:capacity
        
        % Generate Orders (sample SKUs by frequency of access)
        % Combine orders 1..Equipment_Capacity

        for b = 1:batch_size
            if b == 1
                order = randsample(final_slots(1), avg_order_lines); %, true, FoA);
            else
                order = [order, randsample(final_slots(1), avg_order_lines)]; %, true, FoA)];
            end
        end

        stops = unique(order);
        stop_count = length(stops);

        %% Slotting Policies
        for slotting = 1:2
            % pair up storage nodes and SKUs

            % most frequent <-> most desirable
            % random



            %% Routing Algorithms
            for routing = 1:6

                % TSP
                idxs = nchoosek(stops,2);
                dist = zeros(stop_count);

                for i = 1:stop_count
                    for j = 1:stop_count
                        if j > i
                            dist(i,j) = delta_ij(stops(i), stops(j));
                        end
                    end
                end
                dist = nonzeros(dist(:))';
                lendist = length(dist);

                Aeq = spones(1:length(idxs));
                beq = stop_count;

                Aeq = [Aeq;spalloc(stop_count,length(idxs),stop_count*(stop_count-1))]; % allocate a sparse matrix
                for ii = 1:stop_count
                    whichIdxs = (idxs == ii); % find the trips that include stop ii
                    whichIdxs = sparse(sum(whichIdxs,2)); % include trips where ii is at either end
                    Aeq(ii+1,:) = whichIdxs'; % include in the constraint matrix
                end
                beq = [beq; 2*ones(stop_count,1)];

                intcon = 1:lendist;
                lb = zeros(lendist,1);
                ub = ones(lendist,1);

                opts = optimoptions('intlinprog','Display','off');
                [x_tsp,costopt,exitflag,output] = intlinprog(dist,intcon,[],[],Aeq,beq,lb,ub,opts);

                tours = detectSubtours(x_tsp,idxs);
                numtours = length(tours); % number of subtours
                fprintf('# of subtours: %d\n',numtours);

                A2 = spalloc(0,lendist,0); % Allocate a sparse linear inequality constraint matrix
                b = [];
                while numtours > 1 % repeat until there is just one subtour
                    % Add the subtour constraints
                    b = [b;zeros(numtours,1)]; % allocate b
                    A2 = [A2;spalloc(numtours,lendist,stop_count)]; % a guess at how many nonzeros to allocate
                    for ii = 1:numtours
                        rowIdx = size(A2,1)+1; % Counter for indexing
                        subTourIdx = tours{ii}; % Extract the current subtour
                %         The next lines find all of the variables associated with the
                %         particular subtour, then add an inequality constraint to prohibit
                %         that subtour and all subtours that use those stops.
                        variations = nchoosek(1:length(subTourIdx),2);
                        for jj = 1:length(variations)
                            whichVar = (sum(idxs==subTourIdx(variations(jj,1)),2)) & ...
                                       (sum(idxs==subTourIdx(variations(jj,2)),2));
                            A2(rowIdx,whichVar) = 1;
                        end
                        b(rowIdx) = length(subTourIdx)-1; % One less trip than subtour stops
                    end

                    % Try to optimize again
                    [x_tsp,costopt,exitflag,output] = intlinprog(dist,intcon,A2,b,Aeq,beq,lb,ub,opts);

                    % How many subtours this time?
                    tours = detectSubtours(x_tsp,idxs);
                    numtours = length(tours); % number of subtours
                    fprintf('# of subtours: %d\n',numtours);
                end



                % Complete serpentine
                td = 2 * ((2 * slot_width + aisle_width) * (aisles - 1)) + aisles * (2 * cross_aisle_width + (1/2) * k * slot_length);


                % Serpentine and skipping
                % Return
                % Split return
                % Largest gap
            end
        end
    end




    %% Evaluation
    % Calculate distance based on different routing policies
    % Convert distance into travel time? Pick time? (to evaluate longer picking
    % times for bigger batches)
    % Evaluate combination of Slotting, Routing, Batching



    % Travel time vs. computational effort???
    % 3D plot of travel time / travel distance?
end