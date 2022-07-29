% clear;
% dir = "D:\Dropbox\5G\TWT\data\throughput\MU\4MU\FA\DL\S10\new\";
% filename = dir +  '4mu_s10_dl_FA_on_mcs0.log';
% macAddr = "D4:53:83:F8:81:17";

function [throughputs,phy_rates_sta] = parse_bs_data_macAddr(filename,macAddr)
    fileID = fopen(filename,'r');
    throughputs = []; %Mbps
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

        % matched macAddr
        if strcmp(tokens{1}, macAddr)
            throughputs = [throughputs str2double(tokens{3})];
            phy_rates_sta = [phy_rates_sta str2double(tokens{2})];
        end
    end
end