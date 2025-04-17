function process_large_gap_ga()
    num_files = 12;
    aggregated_results = cell(num_files, 1);

    % Open file to save all results
    outputFile = 'gap_ga_results.csv';
    fidOut = fopen(outputFile, 'w');
    fprintf(fidOut, 'FileIndex,InstanceName,Cost\n');

    for file_idx = 12:num_files
        filename = sprintf('/MATLAB Drive/Assignments/gap%d.txt', file_idx);
        fid = fopen(filename, 'r');
        if fid == -1
            error('Cannot open file: %s', filename);
        end

        num_instances = fscanf(fid, '%d', 1);
        instance_results = cell(num_instances, 1);

        for instance = 1:num_instances
            num_servers = fscanf(fid, '%d', 1);
            num_users = fscanf(fid, '%d', 1);
            cost_matrix = fscanf(fid, '%d', [num_users, num_servers])';
            resource_matrix = fscanf(fid, '%d', [num_users, num_servers])';
            capacity_vector = fscanf(fid, '%d', [num_servers, 1]);

            assignment_matrix = optimize_gap_ga(num_servers, num_users, cost_matrix, resource_matrix, capacity_vector);
            total_profit = sum(sum(cost_matrix .* assignment_matrix));

            instance_id = sprintf('c%d-%d', num_servers*100 + num_users, instance);
            instance_results{instance} = sprintf('%s %d', instance_id, round(total_profit));

            % Save to CSV
            fprintf(fidOut, '%d,%s,%d\n', file_idx, instance_id, round(total_profit));
        end
        fclose(fid);
        aggregated_results{file_idx} = instance_results;
    end
    run_gap12_binary_ga_average_profits()

    fclose(fidOut);  % Close output file
    display_results(aggregated_results, num_files);
end


function assignment_matrix = optimize_gap_ga(num_servers, num_users, cost_matrix, resource_matrix, capacity_vector)
    population_size = 200;
    max_generations = 300;
    crossover_rate = 0.9;
    mutation_rate = 0.15;

    population = initialize_population(population_size, num_servers, num_users, cost_matrix, resource_matrix, capacity_vector);
    best_solution = population(1, :);
    best_fitness = -Inf;

    for generation = 1:max_generations
        fitness = evaluate_fitness(population, num_servers, num_users, cost_matrix, resource_matrix, capacity_vector);
        [max_fit, best_idx] = max(fitness);
        if max_fit > best_fitness
            best_fitness = max_fit;
            best_solution = population(best_idx, :);
        end
        
        population = evolve_population(population, fitness, crossover_rate, mutation_rate);
    end
    
    assignment_matrix = reshape(best_solution, [num_servers, num_users]);
end

function population = initialize_population(pop_size, num_servers, num_users, cost_matrix, resource_matrix, capacity_vector)
    population = zeros(pop_size, num_servers * num_users);
    for i = 1:pop_size
        assignment = feasible_initialization(num_servers, num_users, resource_matrix, capacity_vector);
        population(i, :) = assignment(:)';
    end
end

function assignment = feasible_initialization(num_servers, num_users, resource_matrix, capacity_vector)
    assignment = zeros(num_servers, num_users);
    remaining_capacity = capacity_vector;
    
    % Create a random order of users
    user_order = randperm(num_users);
    
    % Assign each user to a feasible server
    for u = user_order
        % Find all feasible servers for this user
        feasible_servers = [];
        for s = 1:num_servers
            if resource_matrix(s, u) <= remaining_capacity(s)
                feasible_servers = [feasible_servers, s];
            end
        end
        
        % If feasible servers exist, randomly choose one
        if ~isempty(feasible_servers)
            chosen_server = feasible_servers(randi(length(feasible_servers)));
            assignment(chosen_server, u) = 1;
            remaining_capacity(chosen_server) = remaining_capacity(chosen_server) - resource_matrix(chosen_server, u);
        end
        % If no feasible server exists, the user remains unassigned (assignment remains 0)
    end
    
    % Try to assign any remaining unassigned users
    for u = 1:num_users
        if sum(assignment(:, u)) == 0
            % Find server with maximum remaining capacity
            [~, max_cap_server] = max(remaining_capacity);
            
            % Try to assign to this server if possible
            if resource_matrix(max_cap_server, u) <= remaining_capacity(max_cap_server)
                assignment(max_cap_server, u) = 1;
                remaining_capacity(max_cap_server) = remaining_capacity(max_cap_server) - resource_matrix(max_cap_server, u);
            end
        end
    end
end

function fitness = evaluate_fitness(population, num_servers, num_users, cost_matrix, resource_matrix, capacity_vector)
    fitness = zeros(size(population, 1), 1);
    for i = 1:size(population, 1)
        assignment_matrix = reshape(population(i, :), [num_servers, num_users]);
        total_profit = sum(sum(cost_matrix .* assignment_matrix));
        penalty = sum(abs(sum(assignment_matrix, 1) - 1)) * 10000;
        capacity_violation = sum(resource_matrix .* assignment_matrix, 2) - capacity_vector;
        capacity_penalty = sum(max(0, capacity_violation)) * 5000;
        fitness(i) = total_profit - penalty - capacity_penalty;
    end
end

function new_population = evolve_population(population, fitness, crossover_rate, mutation_rate)
    pop_size = size(population, 1);
    new_population = zeros(size(population));
    tournament_size = 4;
    for i = 1:pop_size
        candidates = randperm(pop_size, tournament_size);
        [~, best_idx] = max(fitness(candidates));
        new_population(i, :) = population(candidates(best_idx), :);
    end
    for i = 1:2:pop_size-1
        if rand < crossover_rate
            points = sort(randi([1, numel(population(1, :))], 1, 2));
            temp = new_population(i, points(1):points(2));
            new_population(i, points(1):points(2)) = new_population(i+1, points(1):points(2));
            new_population(i+1, points(1):points(2)) = temp;
        end
    end
    for i = 1:pop_size
        if rand < mutation_rate
            idx = randi(numel(population(i, :)), 1, 2);
            new_population(i, idx) = ~new_population(i, idx);
        end
    end
    new_population(1, :) = population(1, :);
end

function display_results(results, num_files)
    files_per_row = 4;
    for start = 1:files_per_row:num_files
        stop = min(start + files_per_row - 1, num_files);
        for file_idx = start:stop
            fprintf('gap%d ', file_idx);
        end
        fprintf('\n');
        max_instances = max(cellfun(@length, results(start:stop)));
        for instance = 1:max_instances
            for file_idx = start:stop
                if instance <= length(results{file_idx})
                    fprintf('%s\t', results{file_idx}{instance});
                else
                    fprintf('\t\t');
                end
            end
            fprintf('\n');
        end
        fprintf('\n');
    end
end
function run_gap12_binary_ga_average_profits()
    % Input and output
    gap_file = '/MATLAB Drive/Assignments/gap12.txt';
    output_csv = 'gap12_binary_avg_results.csv';
    num_runs = 10;

    % Open file
    fid = fopen(gap_file, 'r');
    if fid == -1
        error('Cannot open file: %s', gap_file);
    end

    % Read number of instances
    num_instances = fscanf(fid, '%d', 1);
    avg_results = zeros(num_instances, 1);

    for instance = 1:num_instances
        % Read one instance
        num_servers = fscanf(fid, '%d', 1);
        num_users = fscanf(fid, '%d', 1);
        cost_matrix = fscanf(fid, '%d', [num_users, num_servers])';
        resource_matrix = fscanf(fid, '%d', [num_users, num_servers])';
        capacity_vector = fscanf(fid, '%d', [num_servers, 1]);

        % Run 10 iterations
        profits = zeros(num_runs, 1);
        for run = 1:num_runs
            assignment_matrix = optimize_gap_ga(num_servers, num_users, cost_matrix, resource_matrix, capacity_vector);
            profits(run) = sum(sum(cost_matrix .* assignment_matrix));
        end

        avg_results(instance) = mean(profits);
        fprintf('Binary GA - Instance %d: Average Profit = %.2f\n', instance, avg_results(instance));
    end
    fclose(fid);

    % Write CSV
    fidOut = fopen(output_csv, 'w');
    fprintf(fidOut, 'Instance,AverageProfit\n');
    for i = 1:num_instances
        fprintf(fidOut, '%d,%.2f\n', i, avg_results(i));
    end
    fclose(fidOut);

    fprintf('Binary GA average results saved to %s\n', output_csv);
end