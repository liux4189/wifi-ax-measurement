% clear;
% dir = "D:\Dropbox\5G\TWT\data\throughput\MU\4MU\FA\UL\";
% filename = dir +  '4mu_ul_FA_on_mcs1.log';

function [aggregated_throughputs, phy_rates] = parse_wl_rx_report(filename)

fileID = fopen(filename,'r');
aggregated_throughputs = []; %Mbps
phy_rates = [];
phy_rates_sta = [];
data_rates_sta = [];
hasOverall = false; 

tline = 0;
while 1
    tline = fgetl(fileID);
    if tline == -1
        break;
    end
    %disp(tline)
    tokens = strtrim(split(tline,' '));
    tokens(cellfun(@isempty,tokens)) = [];
    
    if ~length(tokens)
        continue;
    end
    % new record
    if strcmp(tokens{1}, 'Station')
        if ~hasOverall && length(data_rates_sta) > 0
             aggregated_throughputs = [aggregated_throughputs sum(data_rates_sta)];
             phy_rates = [phy_rates mean(phy_rates_sta)];
        end
        phy_rates_sta = [];
        data_rates_sta = [];
        continue;
    end
    
    % end of a record
    if strcmp(tokens{1}, '(overall)')
        aggregated_throughputs = [aggregated_throughputs str2double(tokens{5})];
        phy_rates = [phy_rates mean(phy_rates_sta)];
        hasOverall = true;
        continue;
    end
    
    % records
    if contains(tokens{1},':')%length(tokens) == 17 
        phy_rates_sta = [phy_rates_sta str2double(tokens{7})];
        data_rates_sta = [data_rates_sta  str2double(tokens{6})];
    else
        data_rates_sta = [data_rates_sta  str2double(tokens{4})];
    end
end

end