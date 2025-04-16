function executeGapProcessing()
    numFiles = 12;
    allResults = cell(numFiles, 1);

    % Create and open results CSV
    resultsPath = 'gap_max_results.csv';
    outputHandle = fopen(resultsPath, 'w');
    if outputHandle == -1
        error('Unable to write to file: %s', resultsPath);
    end

    % Write header row
    fprintf(outputHandle, 'FileNum,CaseLabel,TotalScore\n');

    % Process each gap file
    for fileNum = 1:numFiles
        inputPath = sprintf('/MATLAB Drive/Assignments/gap%d.txt', fileNum);
        inputHandle = fopen(inputPath, 'r');
        if inputHandle == -1
            error('Could not open data file: %s', inputPath);
        end

        % Read number of test scenarios
        numScenarios = fscanf(inputHandle, '%d', 1);
        scenarioResults = cell(numScenarios, 1);

        for scenarioIdx = 1:numScenarios
            % Read server and user counts
            sizes = fscanf(inputHandle, '%d', 2);
            servers = sizes(1);
            users = sizes(2);

            % Read utility matrix
            utilityTable = zeros(servers, users);
            for s = 1:servers
                utilityTable(s, :) = fscanf(inputHandle, '%d', [1, users]);
            end

            % Read resource matrix
            resourceTable = zeros(servers, users);
            for s = 1:servers
                resourceTable(s, :) = fscanf(inputHandle, '%d', [1, users]);
            end

            % Read server capacity values
            capacityVec = fscanf(inputHandle, '%d', [servers, 1]);

            % Call solver
            assignment = solveAssignment(servers, users, utilityTable, resourceTable, capacityVec);

            % Compute total utility
            utilityScore = sum(sum(utilityTable .* assignment));

            % Construct case identifier
            label = sprintf('c%d-%d', servers * 100 + users, scenarioIdx);
            scenarioResults{scenarioIdx} = sprintf('%s\t%d', label, round(utilityScore));

            % Write to CSV
            fprintf(outputHandle, '%d,%s,%d\n', fileNum, label, round(utilityScore));
        end

        fclose(inputHandle);
        allResults{fileNum} = scenarioResults;
    end

    fclose(outputHandle);
    fprintf('All results have been written to %s\n', resultsPath);

    % Display results neatly
    displayCols = 4;
    for start = 1:displayCols:numFiles
        stop = min(start + displayCols - 1, numFiles);

        % Print header row
        for idx = start:stop
            fprintf('gap%d\t\t', idx);
        end
        fprintf('\n');

        % Get the max number of rows to print
        maxRows = max(cellfun(@length, allResults(start:stop)));

        % Print each row
        for row = 1:maxRows
            for idx = start:stop
                if idx <= length(allResults) && row <= length(allResults{idx})
                    fprintf('%s\t', allResults{idx}{row});
                else
                    fprintf('\t\t');
                end
            end
            fprintf('\n');
        end
        fprintf('\n');
    end
end

function allocation = solveAssignment(machines, tasks, utilities, requirements, limits)
    % Objective vector (maximize utility by minimizing the negative)
    obj = -reshape(utilities, [], 1);

    % Constraint 1: One server per user
    userConstraint = zeros(tasks, machines * tasks);
    for u = 1:tasks
        for s = 1:machines
            userConstraint(u, (u - 1) * machines + s) = 1;
        end
    end
    userDemand = ones(tasks, 1);

    % Constraint 2: Server resource capacities
    serverConstraint = zeros(machines, machines * tasks);
    for s = 1:machines
        for u = 1:tasks
            serverConstraint(s, (u - 1) * machines + s) = requirements(s, u);
        end
    end
    serverLimit = limits;

    % Bounds and integer constraints
    lb = zeros(machines * tasks, 1);
    ub = ones(machines * tasks, 1);
    integerVars = 1:(machines * tasks);

    % Solve the integer programming problem
    solverOpts = optimoptions('intlinprog', 'Display', 'off');
    solution = intlinprog(obj, integerVars, serverConstraint, serverLimit, ...
                          userConstraint, userDemand, lb, ub, solverOpts);

    % Convert to matrix form
    allocation = reshape(solution, [machines, tasks]);
end
