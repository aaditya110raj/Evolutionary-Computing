function optimal_vs_approxin()
    % Read the greedy approximation results
    greedy_data = readtable('Approximation_value.csv');
    
    % Read the optimal results
    optimal_data = readtable('gap_max_results.csv');
    
    % Print the column names to debug
    disp('Greedy data column names:');
    disp(greedy_data.Properties.VariableNames);
    
    disp('Optimal data column names:');
    disp(optimal_data.Properties.VariableNames);
    
    % Rename columns for consistency
    optimal_data.Properties.VariableNames{1} = 'FileID';
    optimal_data.Properties.VariableNames{2} = 'InstanceID';
    % The utility column name might be 'Utility' not 'TotalUtility'
    optimal_data.Properties.VariableNames{3} = 'OptimalUtility';
    
    % Extract instance numbers from the instance names in optimal data
    for i = 1:height(optimal_data)
        instance_parts = split(optimal_data.InstanceID{i}, '-');
        optimal_data.InstanceID{i} = ['c', instance_parts{2}];
    end
    
    % Merge the datasets
    comparison_data = table();
    comparison_data.FileID = greedy_data.FileID;
    comparison_data.InstanceID = greedy_data.InstanceID;
    comparison_data.GreedyUtility = greedy_data.TotalUtility;
    
    % Find matching optimal values
    comparison_data.OptimalUtility = zeros(height(comparison_data), 1);
    for i = 1:height(comparison_data)
        idx = find(optimal_data.FileID == comparison_data.FileID(i) & ...
                   strcmp(optimal_data.InstanceID, comparison_data.InstanceID{i}));
        if ~isempty(idx)
            comparison_data.OptimalUtility(i) = optimal_data.OptimalUtility(idx);
        end
    end
    
    % Calculate approximation ratio (Greedy/Optimal)
    comparison_data.ApproxRatio = comparison_data.GreedyUtility ./ comparison_data.OptimalUtility;
    
    % Add performance gap percentage
    comparison_data.PerformanceGap = (1 - comparison_data.ApproxRatio) * 100;
    
    % Calculate summary statistics by file
    file_ids = unique(comparison_data.FileID);
    summary_stats = table();
    summary_stats.FileID = file_ids;
    summary_stats.AvgApproxRatio = zeros(length(file_ids), 1);
    summary_stats.MinApproxRatio = zeros(length(file_ids), 1);
    summary_stats.MaxApproxRatio = zeros(length(file_ids), 1);
    summary_stats.AvgPerformanceGap = zeros(length(file_ids), 1);
    
    for i = 1:length(file_ids)
        idx = comparison_data.FileID == file_ids(i);
        summary_stats.AvgApproxRatio(i) = mean(comparison_data.ApproxRatio(idx));
        summary_stats.MinApproxRatio(i) = min(comparison_data.ApproxRatio(idx));
        summary_stats.MaxApproxRatio(i) = max(comparison_data.ApproxRatio(idx));
        summary_stats.AvgPerformanceGap(i) = mean(comparison_data.PerformanceGap(idx));
    end
    
    % Save the comparison results
    writetable(comparison_data, 'gap_comparison_results.csv');
    writetable(summary_stats, 'gap_summary_stats.csv');
    
    % Display overall statistics
    fprintf('Overall Statistics:\n');
    fprintf('Average Approximation Ratio: %.4f\n', mean(comparison_data.ApproxRatio));
    fprintf('Min Approximation Ratio: %.4f\n', min(comparison_data.ApproxRatio));
    fprintf('Max Approximation Ratio: %.4f\n', max(comparison_data.ApproxRatio));
    fprintf('Average Performance Gap: %.2f%%\n', mean(comparison_data.PerformanceGap));
    
    % Create visualization for all files
    plot_comparison_all_files(comparison_data);
    
    % Create specific visualization for gap12
    plot_gap12_comparison(comparison_data);
end

function plot_comparison_all_files(comparison_data)
    % Group by file ID
    file_ids = unique(comparison_data.FileID);
    
    figure('Position', [100, 100, 1200, 800]);
    
    % Plot approximation ratios by file
    subplot(2, 1, 1);
    boxplot(comparison_data.ApproxRatio, comparison_data.FileID);
    title('Approximation Ratio by File ID (Greedy/Optimal)', 'FontSize', 14);
    xlabel('File ID (gap#)', 'FontSize', 12);
    ylabel('Approximation Ratio', 'FontSize', 12);
    grid on;
    
    % Plot performance gap by file
    subplot(2, 1, 2);
    boxplot(comparison_data.PerformanceGap, comparison_data.FileID);
    title('Performance Gap by File ID (%)', 'FontSize', 14);
    xlabel('File ID (gap#)', 'FontSize', 12);
    ylabel('Performance Gap (%)', 'FontSize', 12);
    grid on;
    
    % Save the figure
    saveas(gcf, 'gap_comparison_all_files.png');
    saveas(gcf, 'gap_comparison_all_files.fig');
end

function plot_gap12_comparison(comparison_data)
    % Filter data for gap12
    gap12_data = comparison_data(comparison_data.FileID == 12, :);
    
    % Format instance labels for x-axis
    instance_labels = cell(height(gap12_data), 1);
    for i = 1:height(gap12_data)
        instance_labels{i} = gap12_data.InstanceID{i};
    end
    
    % Create figure
    figure('Position', [100, 100, 900, 600]);
    
    % Create bar chart comparing greedy vs optimal for gap12
    bar_data = [gap12_data.GreedyUtility, gap12_data.OptimalUtility];
    bar_handle = bar(bar_data);
    
    % Set colors for the bars
    bar_handle(1).FaceColor = [0.2, 0.6, 1.0];  % Blue for greedy
    bar_handle(2).FaceColor = [0.8, 0.2, 0.2];  % Red for optimal
    
    % Add labels and title
    title('GAP12: Greedy vs Optimal Solution Comparison', 'FontSize', 16, 'FontWeight', 'bold');
    xlabel('Instance ID', 'FontSize', 14);
    ylabel('Utility Value', 'FontSize', 14);
    set(gca, 'XTickLabel', instance_labels);
    grid on;
    legend('Greedy Approximation', 'Optimal Solution', 'Location', 'best');
    
    % Add approximation ratio text
    for i = 1:height(gap12_data)
        ratio = gap12_data.ApproxRatio(i);
        x_pos = i;
        y_pos = max(bar_data(i,:)) + 50;
        text(x_pos, y_pos, sprintf('Ratio: %.2f', ratio), ...
             'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % Add another visualization - line plot showing the gap
    figure('Position', [100, 100, 900, 400]);
    
    % Plot lines
    plot(1:height(gap12_data), gap12_data.GreedyUtility, 'o-', 'LineWidth', 2, ...
         'Color', [0.2, 0.6, 1.0], 'MarkerFaceColor', [0.2, 0.6, 1.0], 'MarkerSize', 8);
    hold on;
    plot(1:height(gap12_data), gap12_data.OptimalUtility, 'o-', 'LineWidth', 2, ...
         'Color', [0.8, 0.2, 0.2], 'MarkerFaceColor', [0.8, 0.2, 0.2], 'MarkerSize', 8);
    
    % Add gap visualization
    for i = 1:height(gap12_data)
        x = [i, i];
        y = [gap12_data.GreedyUtility(i), gap12_data.OptimalUtility(i)];
        plot(x, y, '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1.5);
        
        % Add gap percentage
        gap_percent = gap12_data.PerformanceGap(i);
        text(i+0.1, mean(y), sprintf('%.1f%%', gap_percent), ...
             'FontWeight', 'bold', 'FontSize', 10);
    end
    
    title('GAP12: Performance Gap Between Greedy and Optimal Solutions', 'FontSize', 16, 'FontWeight', 'bold');
    xlabel('Instance ID', 'FontSize', 14);
    ylabel('Utility Value', 'FontSize', 14);
    set(gca, 'XTick', 1:height(gap12_data));
    set(gca, 'XTickLabel', instance_labels);
    grid on;
    legend('Greedy Approximation', 'Optimal Solution', 'Performance Gap', 'Location', 'best');
    
    % Save the figures
    saveas(gcf, 'gap12_comparison_gap.png');
    saveas(gcf, 'gap12_comparison_gap.fig');
end