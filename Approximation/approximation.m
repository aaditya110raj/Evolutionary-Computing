function run_gap_greedy_solver()
    % Store final outcomes
    all_utilities = [];
    case_labels = {};

    % Loop through dataset files
    for dataset_idx = 1:12
        filepath = sprintf('/MATLAB Drive/Assignments/gap%d.txt', dataset_idx);
        fid = fopen(filepath, 'r');
        
        if fid < 0
            error('Unable to open file: %s', filepath);
        end

        % Read total number of test cases in current file
        total_cases = fscanf(fid, '%d', 1);
        fprintf('\nProcessing: %s\n', filepath(1:end-4));

        % Iterate over all test cases
        for case_idx = 1:total_cases
            agents = fscanf(fid, '%d', 1);
            tasks = fscanf(fid, '%d', 1);

            % Benefit and requirement matrices
            benefits = fscanf(fid, '%d', [tasks, agents])';
            requirements = fscanf(fid, '%d', [tasks, agents])';
            capacities = fscanf(fid, '%d', [agents, 1]);

            % Solve using greedy approach
            assignment = greedy_assignment_solver(agents, tasks, benefits, requirements, capacities);
            total_benefit = sum(sum(benefits .* assignment));

            % Generate unique ID for the test case
            case_id = sprintf('gap%d-%d', dataset_idx, case_idx);

            % Display progress
            fprintf('Instance: %s | Utility: %d\n', case_id, total_benefit);

            % Save results
            all_utilities(end + 1) = total_benefit;
            case_labels{end + 1} = case_id;
        end

        fclose(fid);
    end

    % Generate results table
    write_results_to_csv(case_labels, all_utilities);

    % Visualize the results
    visualize_results(case_labels, all_utilities);
end

function assignment = greedy_assignment_solver(agents, tasks, benefits, requirements, capacities)
    assignment = zeros(agents, tasks);
    remaining = capacities;

    for task = 1:tasks
        worst_agent = -1;
        min_gain = inf;

        for agent = 1:agents
            if requirements(agent, task) <= remaining(agent)
                gain = benefits(agent, task);
                if gain < min_gain
                    min_gain = gain;
                    worst_agent = agent;
                end
            end
        end

        if worst_agent > 0
            assignment(worst_agent, task) = 1;
            remaining(worst_agent) = remaining(worst_agent) - requirements(worst_agent, task);
        end
    end
end


function write_results_to_csv(ids, utilities)
    num_cases = numel(ids);
    file_ids = zeros(num_cases, 1);
    instance_ids = cell(num_cases, 1);
    values = zeros(num_cases, 1);

    for i = 1:num_cases
        parts = split(ids{i}, '-');
        file_ids(i) = str2double(extractAfter(parts{1}, 'gap'));
        instance_ids{i} = ['c', parts{2}];
        values(i) = utilities(i);
    end

    result_table = table(file_ids, instance_ids, values, ...
        'VariableNames', {'FileID', 'InstanceID', 'TotalUtility'});
    
    writetable(result_table, 'gap_greedy_results.csv');
    fprintf('Results saved to gap_greedy_results.csv\n');
end

function visualize_results(ids, utilities)
    figure;
    plot(utilities, '-o', 'LineWidth', 1.5);
    title('Greedy Heuristic: GAP Solutions');
    xlabel('Problem Instance');
    ylabel('Total Utility');
    legend('Greedy Heuristic', 'Location', 'best');
    xticks(1:length(ids));
    xticklabels(ids);
    xtickangle(45);
    grid on;
end
