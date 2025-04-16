% Real-Coded Genetic Algorithm for sphere function optimization
% min f(x) = sum(x_i^2) where i=1 to 4 and x_i ∈ [-10, 10]

clear all;
close all;
clc;

% GA Parameters
pop_size = 100;        % Population size
max_generations = 100; % Maximum number of generations
p_crossover = 0.8;     % Crossover probability
p_mutation = 0.1;      % Mutation probability
num_vars = 4;          % Number of variables
domain = [-10, 10];    % Domain of each variable

% Initialize population with random real values within domain
population = zeros(pop_size, num_vars);
for i = 1:pop_size
    population(i, :) = domain(1) + (domain(2) - domain(1)) * rand(1, num_vars);
end

% For tracking convergence
best_fitness_history = zeros(max_generations, 1);

% Main GA loop
for generation = 1:max_generations
    % Calculate fitness (sphere function)
    fitness = zeros(pop_size, 1);
    for i = 1:pop_size
        % Sphere function f(x) = sum(x_i^2)
        fitness(i) = sum(population(i, :).^2);
    end
    
    % Track statistics
    [min_fitness, min_idx] = min(fitness);
    best_fitness_history(generation) = min_fitness;
    
    % Display progress
    if mod(generation, 10) == 0
        fprintf('Generation %d: Best fitness = %.10f\n', generation, min_fitness);
        best_solution = population(min_idx, :);
        fprintf('Best solution: [%.6f, %.6f, %.6f, %.6f]\n', best_solution);
    end
    
    % Create new population
    new_population = zeros(size(population));
    
    % Elitism: Keep the best individual
    new_population(1, :) = population(min_idx, :);
    
    % Fill the rest of new population
    for i = 2:2:pop_size
        % Tournament selection
        tournament_size = 3;
        parent1_idx = tournament_selection(fitness, tournament_size);
        parent2_idx = tournament_selection(fitness, tournament_size);
        
        parent1 = population(parent1_idx, :);
        parent2 = population(parent2_idx, :);
        
        % Crossover (BLX-alpha crossover)
        if rand() < p_crossover
            alpha = 0.3; % Parameter for BLX-alpha crossover
            offspring1 = zeros(1, num_vars);
            offspring2 = zeros(1, num_vars);
            
            for j = 1:num_vars
                % Calculate range
                range = abs(parent1(j) - parent2(j));
                min_val = min(parent1(j), parent2(j));
                max_val = max(parent1(j), parent2(j));
                
                % Extended range for BLX-alpha
                min_range = min_val - alpha * range;
                max_range = max_val + alpha * range;
                
                % Ensure within domain bounds
                min_range = max(min_range, domain(1));
                max_range = min(max_range, domain(2));
                
                % Generate offspring within extended range
                offspring1(j) = min_range + (max_range - min_range) * rand();
                offspring2(j) = min_range + (max_range - min_range) * rand();
            end
        else
            offspring1 = parent1;
            offspring2 = parent2;
        end
        
        % Mutation (Gaussian mutation)
        if rand() < p_mutation
            % Determine mutation strength (sigma)
            sigma = 0.1 * (domain(2) - domain(1)); % 10% of domain range
            
            % Apply mutation to random genes
            for j = 1:num_vars
                if rand() < 0.5 % 50% chance to mutate each gene
                    offspring1(j) = offspring1(j) + sigma * randn();
                    % Ensure within bounds
                    offspring1(j) = max(min(offspring1(j), domain(2)), domain(1));
                end
            end
        end
        
        if rand() < p_mutation
            sigma = 0.1 * (domain(2) - domain(1));
            for j = 1:num_vars
                if rand() < 0.5
                    offspring2(j) = offspring2(j) + sigma * randn();
                    offspring2(j) = max(min(offspring2(j), domain(2)), domain(1));
                end
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
    
    % Update population
    population = new_population;
end

% Find the best solution in the final population
fitness = zeros(pop_size, 1);
for i = 1:pop_size
    fitness(i) = sum(population(i, :).^2);
end

% Find the best solution
[best_fitness, best_idx] = min(fitness);
best_solution = population(best_idx, :);

% Display results
fprintf('\nFinal Results:\n');
fprintf('Best fitness (minimum): %.10f\n', best_fitness);
fprintf('Best solution (x): [%.6f, %.6f, %.6f, %.6f]\n', best_solution);

% Plot convergence
figure;
semilogy(1:max_generations, best_fitness_history, 'LineWidth', 2);
grid on;
xlabel('Generation');
ylabel('Fitness (log scale)');
title('Convergence of Real-Coded GA for Sphere Function');
legend('Best Fitness');

% Tournament selection function
function selected_idx = tournament_selection(fitness, tournament_size)
    pop_size = length(fitness);
    tournament_indices = randi(pop_size, 1, tournament_size);
    tournament_fitness = fitness(tournament_indices);
    [~, idx] = min(tournament_fitness);
    selected_idx = tournament_indices(idx);
end