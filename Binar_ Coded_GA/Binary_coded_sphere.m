% Binary-Coded Genetic Algorithm for sphere function optimization
% min f(x) = sum(x_i^2) where i=1 to 4 and x_i ∈ [-10, 10]

clear all;
close all;
clc;

% GA Parameters
pop_size = 100;        % Population size
max_generations = 100; % Maximum number of generations
p_crossover = 0.8;     % Crossover probability
p_mutation = 0.05;     % Mutation probability
bits_per_var = 16;     % Bits used to represent each variable
num_vars = 4;          % Number of variables
chromosome_length = bits_per_var * num_vars;  % Total chromosome length
domain = [-10, 10];    % Domain of each variable

% Initialize population with random binary values
population = rand(pop_size, chromosome_length) > 0.5;

% For tracking convergence
best_fitness_history = zeros(max_generations, 1);

% Main GA loop
for generation = 1:max_generations
    % Decode chromosomes to real values
    decoded_x = zeros(pop_size, num_vars);
    for i = 1:pop_size
        for j = 1:num_vars
            % Extract bits for this variable
            start_bit = (j-1) * bits_per_var + 1;
            end_bit = j * bits_per_var;
            var_bits = population(i, start_bit:end_bit);
            
            % Convert binary to decimal (0 to 2^bits_per_var - 1)
            decimal_value = 0;
            for k = 1:bits_per_var
                decimal_value = decimal_value + var_bits(k) * 2^(bits_per_var - k);
            end
            
            % Map to problem domain
            decoded_x(i, j) = domain(1) + (domain(2) - domain(1)) * decimal_value / (2^bits_per_var - 1);
        end
    end
    
    % Calculate fitness (sphere function)
    % For minimization, we use negative fitness or invert the function
    fitness = zeros(pop_size, 1);
    for i = 1:pop_size
        % Sphere function f(x) = sum(x_i^2)
        fitness(i) = sum(decoded_x(i, :).^2);
    end
    
    % Track statistics
    [min_fitness, min_idx] = min(fitness);
    best_fitness_history(generation) = min_fitness;
    
    % Display progress
    if mod(generation, 10) == 0
        fprintf('Generation %d: Best fitness = %.10f\n', generation, min_fitness);
        best_solution = decoded_x(min_idx, :);
        fprintf('Best solution: [%.6f, %.6f, %.6f, %.6f]\n', best_solution);
    end
    
    % Selection (tournament selection)
    new_population = zeros(size(population));
    for i = 1:2:pop_size
        % Select parents using tournament selection
        tournament_size = 3;
        parent1_idx = tournament_selection(fitness, tournament_size);
        parent2_idx = tournament_selection(fitness, tournament_size);
        
        parent1 = population(parent1_idx, :);
        parent2 = population(parent2_idx, :);
        
        % Crossover
        if rand() < p_crossover
            % Single-point crossover
            crossover_point = randi(chromosome_length - 1);
            offspring1 = [parent1(1:crossover_point), parent2(crossover_point+1:end)];
            offspring2 = [parent2(1:crossover_point), parent1(crossover_point+1:end)];
        else
            offspring1 = parent1;
            offspring2 = parent2;
        end
        
        % Mutation
        for j = 1:chromosome_length
            if rand() < p_mutation
                offspring1(j) = ~offspring1(j);
            end
            if rand() < p_mutation
                offspring2(j) = ~offspring2(j);
            end
        end
        
        % Add to new population
        if i < pop_size
            new_population(i, :) = offspring1;
            new_population(i+1, :) = offspring2;
        else
            new_population(i, :) = offspring1;
        end
    end
    
    % Elitism: Ensure the best solution survives to the next generation
    [~, worst_idx] = max(fitness);
    new_population(worst_idx, :) = population(min_idx, :);
    
    % Update population
    population = new_population;
end

% Find the best solution in the final population
% Decode chromosomes to real values
decoded_x = zeros(pop_size, num_vars);
for i = 1:pop_size
    for j = 1:num_vars
        % Extract bits for this variable
        start_bit = (j-1) * bits_per_var + 1;
        end_bit = j * bits_per_var;
        var_bits = population(i, start_bit:end_bit);
        
        % Convert binary to decimal (0 to 2^bits_per_var - 1)
        decimal_value = 0;
        for k = 1:bits_per_var
            decimal_value = decimal_value + var_bits(k) * 2^(bits_per_var - k);
        end
        
        % Map to problem domain
        decoded_x(i, j) = domain(1) + (domain(2) - domain(1)) * decimal_value / (2^bits_per_var - 1);
    end
end

% Calculate fitness
fitness = zeros(pop_size, 1);
for i = 1:pop_size
    fitness(i) = sum(decoded_x(i, :).^2);
end

% Find the best solution
[best_fitness, best_idx] = min(fitness);
best_solution = decoded_x(best_idx, :);

% Display results
fprintf('\nFinal Results:\n');
fprintf('Best fitness (minimum): %.10f\n', best_fitness);
fprintf('Best solution (x): [%.6f, %.6f, %.6f, %.6f]\n', best_solution);

% Plot convergence - only best fitness
figure;
semilogy(1:max_generations, best_fitness_history, 'LineWidth', 2);
grid on;
xlabel('Generation');
ylabel('Fitness (log scale)');
title('Convergence of Binary-Coded GA for Sphere Function');
legend('Best Fitness');

% Tournament selection function
function selected_idx = tournament_selection(fitness, tournament_size)
    pop_size = length(fitness);
    tournament_indices = randi(pop_size, 1, tournament_size);
    tournament_fitness = fitness(tournament_indices);
    [~, idx] = min(tournament_fitness);
    selected_idx = tournament_indices(idx);
end