function [throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(dir,filenames, isUL)
    throughputs_matrix = [];
    phy_rates_matrix = [];
    for i = 1:length(filenames)
        filename = fullfile(dir,filenames(i));
        disp(filename)
        if isUL == 1
            [throughputs, phy_rates] =  parse_wl_rx_report(filename);
        else
            [throughputs, phy_rates] =  parse_wl_bs_data(filename);
        end
        throughputs_matrix = [throughputs_matrix; throughputs];
        phy_rates_matrix = [phy_rates_matrix; phy_rates];
    end
    % drop first record
    throughputs_matrix(:,1) = [];
    phy_rates_matrix(:,1) = [];
end 