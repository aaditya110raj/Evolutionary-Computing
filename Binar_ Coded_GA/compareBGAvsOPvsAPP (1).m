function compareAllAlgorithms()
    % File paths
    greedyFile = 'gap_greedy_results.csv';
    optimalFile = 'gap_max_results.csv';
    gaFile = 'gap12_binary_avg_results.csv';

    % Read all files
    greedyData = readtable(greedyFile);
    optimalData = readtable(optimalFile);
    gaData = readtable(gaFile);

    % Filter for file index 12
    greedyFiltered = greedyData(greedyData.FileID == 12, :);
    optimalFiltered = optimalData(optimalData.FileNum == 12, :);

    % Number of GA instances
    numGaInstances = height(gaData);

    % Extract and align data
    greedyUtil = greedyFiltered.TotalUtility(1:numGaInstances);
    optimalUtil = optimalFiltered.TotalScore(1:numGaInstances);
    gaUtil = gaData.AverageProfit;
    instanceNames = greedyFiltered.InstanceID(1:numGaInstances);

    % Calculate performance ratios
    greedyRatios = (greedyUtil ./ optimalUtil) * 100;
    gaRatios = (gaUtil ./ optimalUtil) * 100;

    %% --- First Plot: Grouped Bar Chart ---
    figure('Name', 'Utility Comparison', 'Position', [100, 100, 950, 500]);

    barData = [greedyUtil, gaUtil, optimalUtil];
    b = bar(barData);

    % Set NEW Colors
    b(1).FaceColor = [0.2 0.8 0.7];   % Teal for Greedy
    b(2).FaceColor = [1.0 0.5 0.2];   % Coral for GA
    b(3).FaceColor = [0.5 0.3 0.9];   % Purple for Optimal

    % Data labels on top of bars
    for i = 1:length(b)
        xData = b(i).XEndPoints;
        yData = b(i).YData;
        labels = string(round(yData));
        text(xData, yData, labels, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
    end

    % Labels & formatting
    legend('Greedy', 'GA', 'Optimal', 'Location', 'best');
    xlabel('Instances');
    ylabel('Total Utility');
    title('Comparison of Algorithm Utilities for GAP File 12');
    set(gca, 'XTick', 1:numGaInstances, 'XTickLabel', instanceNames, 'XTickLabelRotation', 45);
    grid on;
    ylim([0, max(max(barData)) * 1.15]);

    saveas(gcf, 'utility_comparison.png');

    %% --- Second Plot: Performance Ratios Line Chart ---
    figure('Name', 'Performance Ratios', 'Position', [100, 100, 950, 400]);

    plot(1:numGaInstances, greedyRatios, '-o', 'LineWidth', 2, 'Color', [0.2 0.6 1]);
    hold on;
    plot(1:numGaInstances, gaRatios, '-s', 'LineWidth', 2, 'Color', [1 0.4 0.4]);
    yline(100, '--k', 'Optimal Baseline');

    legend('Greedy / Optimal (%)', 'GA / Optimal (%)', 'Location', 'best');
    xlabel('Instance Index');
    ylabel('Performance Ratio (%)');
    title('Algorithm Performance Ratios Compared to Optimal');
    xticks(1:numGaInstances);
    xticklabels(instanceNames);
    xtickangle(45);
    grid on;
    ylim([min([greedyRatios; gaRatios]) * 0.95, 110]);

    saveas(gcf, 'performance_ratios.png');

    %% --- Console Summary Table ---
    fprintf('Instance\tGreedy\t\tGA\t\tOptimal\t\tGreedy/Opt\tGA/Opt\n');
    fprintf('-------------------------------------------------------------------\n');
    for i = 1:numGaInstances
        fprintf('%s\t%d\t\t%.2f\t\t%d\t\t%.2f%%\t\t%.2f%%\n', ...
            instanceNames{i}, greedyUtil(i), gaUtil(i), optimalUtil(i), ...
            greedyRatios(i), gaRatios(i));
    end
    fprintf('-------------------------------------------------------------------\n');
    fprintf('Average:\t\t\t\t\t\t\t%.2f%%\t\t%.2f%%\n', mean(greedyRatios), mean(gaRatios));

    %% --- Save to CSV ---
    summaryTable = table(instanceNames, greedyUtil, gaUtil, optimalUtil, greedyRatios, gaRatios, ...
        'VariableNames', {'Instance', 'Greedy', 'GA', 'Optimal', 'GreedyRatio', 'GARatio'});
    writetable(summaryTable, 'algorithm_comparison.csv');

    fprintf('Charts and CSV summary saved.\n');
end
