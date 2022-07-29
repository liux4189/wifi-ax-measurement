% clear;
% dir = "D:\Dropbox\5G\TWT\data\throughput\SUvsMU\SU\";
% filenames =  ["2su_s10_ul_FA_on_mcs7_2.log";...
%               "3su_s10_ul_FA_on_mcs7_2.log";...
%               "4su_s10_ul_FA_on_mcs7_2.log";...
%               "5su_s10_ul_FA_on_mcs7_2.log";...
%               "6su_s10_ul_FA_on_mcs7_2.log";...
%               "7su_s10_ul_FA_on_mcs7_2.log";...
%               "8su_s10_ul_FA_on_mcs7_2.log";];
% isUL = 1 ;
% macAddr = "D4:53:83:F8:81:17";

function [throughputs_matrix,phy_rates_matrix] = getThroughputsandPHYrates_macAddr(dir, filenames, macAddr, isUL)
    throughputs_matrix = [];
    phy_rates_matrix = [];

    for i = 1:length(filenames)
        filename = dir + filenames(i);
        disp(filename)
        if isUL == 1
            [throughputs, phy_rates] =  parse_rx_report_macAddr(filename,macAddr);
        else
            [throughputs, phy_rates] =  parse_bs_data_macAddr(filename,macAddr);
        end
        throughputs_matrix = [throughputs_matrix; throughputs];
        phy_rates_matrix = [phy_rates_matrix; phy_rates];
    end
    % drop first record
    throughputs_matrix(:,1) = [];
    phy_rates_matrix(:,1) = [];