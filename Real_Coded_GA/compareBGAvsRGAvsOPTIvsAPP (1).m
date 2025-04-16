function compareAllFourAlgorithms()
    % === File Paths ===
    greedyFile = 'gap_greedy_results.csv';
    optimalFile = 'gap_max_results.csv';
    binaryGaFile = 'gap12_binary_avg_results.csv';
    realGaFile = 'gap_rcga_results.csv';

    % === Load Tables ===
    greedyData = readtable(greedyFile);
    optimalData = readtable(optimalFile);
    binaryGaData = readtable(binaryGaFile);
    realGaData = readtable(realGaFile);

    % === Filter for GAP12 ===
    greedy12 = greedyData(greedyData.FileID == 12, :);
    optimal12 = optimalData(optimalData.FileNum == 12, :);
    realGa12 = realGaData(realGaData.FileIndex == 12, :);

    % === Determine Number of Instances ===
    numInstances = min([height(binaryGaData), height(greedy12), height(optimal12), height(realGa12)]);

    % === Extract Data ===
    greedyVals = greedy12.TotalUtility(1:numInstances);
    binaryGaVals = binaryGaData.AverageProfit(1:numInstances);
    realGaVals = realGa12.Cost(1:numInstances);
    optimalVals = optimal12.TotalScore(1:numInstances);
    instanceNames = realGa12.InstanceName(1:numInstances);

    % === Calculate Ratios (% of optimal) ===
    greedyPct = (greedyVals ./ optimalVals) * 100;
    binaryPct = (binaryGaVals ./ optimalVals) * 100;
    realPct = (realGaVals ./ optimalVals) * 100;

    %% === Bar Chart: Absolute Utility ===
    figure('Name', 'Utility Comparison', 'Position', [100, 100, 1100, 600]);
    barData = [greedyVals, binaryGaVals, realGaVals, optimalVals];
    b = bar(barData, 'grouped');

    % Custom Colors
    b(1).FaceColor = [0.1 0.7 0.6];   % Greedy - teal
    b(2).FaceColor = [1.0 0.5 0.1];   % Binary GA - orange
    b(3).FaceColor = [0.9 0.2 0.4];   % Real GA - red
    b(4).FaceColor = [0.2 0.4 1.0];   % Optimal - blue

    % Add labels on top of bars
    for i = 1:length(b)
        xData = b(i).XEndPoints;
        yData = b(i).YData;
        text(xData, yData, string(round(yData)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontWeight', 'bold', 'FontSize', 8);
    end

    xlabel('Instances');
    ylabel('Total Utility');
    title('Utility Comparison: Greedy vs Binary GA vs Real GA vs Optimal');
    legend({'Greedy', 'Binary GA', 'Real GA', 'Optimal'}, 'Location', 'best');
    set(gca, 'XTick', 1:numInstances, 'XTickLabel', instanceNames, 'XTickLabelRotation', 45);
    ylim([0, max(max(barData)) * 1.15]);
    grid on;

    % Save figure
    saveas(gcf, 'four_algo_utilities.png');

    %% === Line Plot: Performance Ratios ===
    figure('Name', 'Performance Ratios', 'Position', [100, 100, 1100, 450]);

    plot(greedyPct, '-o', 'LineWidth', 2, 'Color', [0.2 0.7 0.5]); hold on;
    plot(binaryPct, '-s', 'LineWidth', 2, 'Color', [1.0 0.4 0.1]);
    plot(realPct, '-^', 'LineWidth', 2, 'Color', [0.9 0.1 0.3]);
    yline(100, '--k', 'Optimal Baseline');

    legend('Greedy / Optimal', 'Binary GA / Optimal', 'Real GA / Optimal', 'Location', 'best');
    xticks(1:numInstances);
    xticklabels(instanceNames);
    xtickangle(45);
    ylabel('Performance Ratio (%)');
    title('Performance as Percentage of Optimal');
    ylim([min([greedyPct; binaryPct; realPct]) * 0.95, 110]);
    grid on;

    % Save figure
    saveas(gcf, 'four_algo_ratios.png');

    %% === Console Table ===
    fprintf('\n%-12s %-8s %-10s %-9s %-8s %-11s %-11s %-11s\n', ...
        'Instance', 'Greedy', 'Binary GA', 'Real GA', 'Optimal', 'Greedy %', 'Binary %', 'Real %');
    fprintf('-------------------------------------------------------------------------------\n');

    for i = 1:numInstances
        fprintf('%-12s %-8d %-10.2f %-9.0f %-8d %-10.2f%% %-10.2f%% %-10.2f%%\n', ...
            instanceNames{i}, greedyVals(i), binaryGaVals(i), realGaVals(i), ...
            optimalVals(i), greedyPct(i), binaryPct(i), realPct(i));
    end

    fprintf('-------------------------------------------------------------------------------\n');
    fprintf('Average:\t\t\t\t\t\t%.2f%%\t\t%.2f%%\t\t%.2f%%\n', ...
        mean(greedyPct), mean(binaryPct), mean(realPct));

    %% === Save Table to CSV ===
    resultTable = table(instanceNames, greedyVals, binaryGaVals, realGaVals, optimalVals, ...
        greedyPct, binaryPct, realPct, ...
        'VariableNames', {'Instance', 'Greedy', 'BinaryGA', 'RealGA', 'Optimal', ...
                          'GreedyPercent', 'BinaryGAPercent', 'RealGAPercent'});

    writetable(resultTable, 'four_algorithm_comparison.csv');

    fprintf('\n✅ Results saved to "four_algorithm_comparison.csv"\n');
    fprintf('✅ Graphs saved as "four_algo_utilities.png" and "four_algo_ratios.png"\n');
end
