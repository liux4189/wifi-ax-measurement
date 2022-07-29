%clear;
%dir = "D:\Dropbox\5G\TWT\data\throughput\";
%filename = dir +  'su_dl_mcs11.log';
function [aggregated_throughputs, phy_rates] = parse_wl_bs_data(filename)
    fileID = fopen(filename,'r');
    aggregated_throughputs = []; %Mbps
    phy_rates = [];
    phy_rates_sta = [];
  
    tline = 0;
    while 1
        tline = fgetl(fileID);
        if tline == -1
            break;
        end
        %disp(tline)
        tokens = strtrim(split(tline,'   '));
        tokens(cellfun(@isempty,tokens)) = [];

        if ~length(tokens)
            continue;
        end
        % new record
        if strcmp(tokens{1}, 'Station Address')
            phy_rates_sta = [];
            continue;
        end

        % end of a record
        if strcmp(tokens{1}, '(overall)')
            aggregated_throughputs = [aggregated_throughputs str2double(tokens{3})];
            phy_rates = [phy_rates mean(phy_rates_sta)];
            continue;
        end
        
        % records
        phy_rates_sta = [phy_rates_sta str2double(tokens{2})];
    end 
end
