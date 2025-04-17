function process_large_gap_rcga()
    num_files = 12;
    aggregated_results = cell(num_files, 1);
    outputFile = 'gap_rcga_results.csv';
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

            assignment_matrix = optimize_gap_rcga(num_servers, num_users, cost_matrix, resource_matrix, capacity_vector);
            total_profit = sum(sum(cost_matrix .* assignment_matrix));

            instance_id = sprintf('c%d-%d', num_servers*100 + num_users, instance);
            instance_results{instance} = sprintf('%s %d', instance_id, round(total_profit));

            fprintf(fidOut, '%d,%s,%d\n', file_idx, instance_id, round(total_profit));
        end
        fclose(fid);
        aggregated_results{file_idx} = instance_results;
    end
    run_gap12_average_profits();
    fclose(fidOut);
    display_results(aggregated_results, num_files);
end

% ----------------- Real-Coded GA Core Function -----------------
function assignment_matrix = optimize_gap_rcga(num_servers, num_users, cost_matrix, resource_matrix, capacity_vector)
    population_size = 200;
    max_generations = 300;
    crossover_rate = 0.9;
    mutation_rate = 0.15;

    population = rand(population_size, num_users);  % real-coded: [0,1]
    best_solution = population(1, :);
    best_fitness = -Inf;

    for generation = 1:max_generations
        fitness = evaluate_real_fitness(population, num_servers, num_users, cost_matrix, resource_matrix, capacity_vector);
        [max_fit, best_idx] = max(fitness);

        if max_fit > best_fitness
            best_fitness = max_fit;
            best_solution = population(best_idx, :);
        end

        population = evolve_real_population(population, fitness, crossover_rate, mutation_rate);
    end

    assignment_matrix = decode_chromosome(best_solution, num_servers, num_users, resource_matrix, capacity_vector);
end

% ----------------- Improved Fitness Evaluation -----------------
function fitness = evaluate_real_fitness(population, num_servers, num_users, cost_matrix, resource_matrix, capacity_vector)
    fitness = zeros(size(population, 1), 1);
    for i = 1:size(population, 1)
        assignment = decode_chromosome(population(i, :), num_servers, num_users, resource_matrix, capacity_vector);
        total_profit = sum(sum(cost_matrix .* assignment));

        % Penalty if any user is not assigned (sum ≠ 1 for a column)
        penalty = sum(abs(sum(assignment, 1) - 1)) * 1e6;

        % Penalty if server capacity is violated
        used_capacity = sum(resource_matrix .* assignment, 2);
        cap_violation = max(0, used_capacity - capacity_vector);
        capacity_penalty = sum(cap_violation) * 1e5;

        fitness(i) = total_profit - penalty - capacity_penalty;
    end
end

% ----------------- Proper Decoding of Real Chromosome -----------------
function assignment = decode_chromosome(chromosome, num_servers, num_users, resource_matrix, capacity_vector)
    assignment = zeros(num_servers, num_users);
    remaining_capacity = capacity_vector;

    for u = 1:num_users
        % Gene u ∈ [0, 1] → preference over servers
        server_scores = linspace(0, 1, num_servers);
        [~, sorted_servers] = sort(abs(server_scores - chromosome(u)));

        for s = sorted_servers
            if resource_matrix(s, u) <= remaining_capacity(s)
                assignment(s, u) = 1;
                remaining_capacity(s) = remaining_capacity(s) - resource_matrix(s, u);
                break;
            end
        end
    end
end

% ----------------- Real-Coded Selection, Crossover, Mutation -----------------
function new_pop = evolve_real_population(pop, fitness, crossover_rate, mutation_rate)
    [pop_size, num_genes] = size(pop);
    new_pop = zeros(size(pop));
    tournament_size = 4;

    % Tournament Selection
    for i = 1:pop_size
        candidates = randperm(pop_size, tournament_size);
        [~, best_idx] = max(fitness(candidates));
        new_pop(i, :) = pop(candidates(best_idx), :);
    end

    % Crossover (BLX-α)
    for i = 1:2:pop_size-1
        if rand < crossover_rate
            alpha = 0.5;
            parent1 = new_pop(i, :);
            parent2 = new_pop(i+1, :);
            new_pop(i, :) = alpha * parent1 + (1 - alpha) * parent2;
            new_pop(i+1, :) = alpha * parent2 + (1 - alpha) * parent1;
        end
    end

    % Mutation (Gaussian)
    for i = 1:pop_size
        if rand < mutation_rate
            mutation_vector = 0.1 * randn(1, num_genes);
            new_pop(i, :) = new_pop(i, :) + mutation_vector;
            new_pop(i, :) = min(max(new_pop(i, :), 0), 1);  % clamp [0,1]
        end
    end
end

% ----------------- Results Display -----------------
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
function run_gap12_average_profits()
    % File and output setup
    gap_file = '/MATLAB Drive/Assignments/gap12.txt';
    output_csv = 'gap12_avg_results.csv';
    num_runs = 2;

    fid = fopen(gap_file, 'r');
    if fid == -1
        error('Cannot open file: %s', gap_file);
    end

    num_instances = fscanf(fid, '%d', 1);  % GAP12 has 5 instances
    avg_results = zeros(num_instances, 1);

    for instance = 1:num_instances
        num_servers = fscanf(fid, '%d', 1);
        num_users = fscanf(fid, '%d', 1);
        cost_matrix = fscanf(fid, '%d', [num_users, num_servers])';
        resource_matrix = fscanf(fid, '%d', [num_users, num_servers])';
        capacity_vector = fscanf(fid, '%d', [num_servers, 1]);

        profits = zeros(num_runs, 1);
        for run = 1:num_runs
            assignment_matrix = optimize_gap_rcga(num_servers, num_users, cost_matrix, resource_matrix, capacity_vector);
            profits(run) = sum(sum(cost_matrix .* assignment_matrix));
        end

        avg_results(instance) = mean(profits);
        fprintf('Instance %d: Average Profit = %.2f\n', instance, avg_results(instance));
    end
    fclose(fid);

    % Write average results to CSV
    fidOut = fopen(output_csv, 'w');
    fprintf(fidOut, 'Instance,AverageProfit\n');
    for i = 1:num_instances
        fprintf(fidOut, '%d,%.2f\n', i, avg_results(i));
    end
    fclose(fidOut);

    fprintf('Average results saved to %s\n', output_csv);
end


