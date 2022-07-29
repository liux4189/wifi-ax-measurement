clear;

root_dir = "D:\Dropbox\5G\TWT\data\throughput\SU\SU_baseline";
fa_on_dir = "baseline_FAon"; % test w. default frame aggregation (ampdu_size = 64)
fa_off_dir = "baseline_FAoff_1600bytes";  %test when frame aggregation is disabled% 
fa_off_200bytes = "baseline_FAoff_200bytes";
fa_off_various_length = "baseline_FAoff_various_length";

%% DL, NSS = 2
% FA on
dir = fullfile(root_dir, fa_on_dir);
filenames =  ["su_dl_mcs1.log"; 
              'su_dl_mcs2.log';
              'su_dl_mcs3.log';
              'su_dl_mcs4.log';
              'su_dl_mcs5.log';
              'su_dl_mcs6.log';
              'su_dl_mcs7.log';
              'su_dl_mcs8.log';
              'su_dl_mcs9.log';
              'su_dl_mcs10.log';
              'su_dl_mcs11.log'];
isUL = 0;
[throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(dir,filenames,isUL );

subplot(2,4,1);
plot(mean(throughputs_matrix,2), 'o-')
hold on;
plot(mean(phy_rates_matrix,2), '*--')
hold on;
xlabel('MCS')
ylabel('Rates(Mbps)');
grid on;
title('DL, NSS = 2 FA')
legend('Throughputs (Frame aggr)', 'PHY rates (Frame aggr)')
xlabel('MCS')
ylabel('Rates(Mbps)');


% FA off
dir = fullfile(root_dir, fa_off_dir);
filenames =  ["su_dl_FA_off_mcs1.log"; 
              'su_dl_FA_off_mcs2.log';
              'su_dl_FA_off_mcs3.log';
              'su_dl_FA_off_mcs4.log';
              'su_dl_FA_off_mcs5.log';
              'su_dl_FA_off_mcs6.log';
              'su_dl_FA_off_mcs7.log';
              'su_dl_FA_off_mcs8.log';
              'su_dl_FA_off_mcs9.log';
              'su_dl_FA_off_mcs10.log';
              'su_dl_FA_off_mcs11.log'];
          
subplot(2,4,2);
[throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(dir,filenames,isUL);
plot(mean(throughputs_matrix,2), 'd-')
hold on;

dir = fullfile(root_dir, fa_off_200bytes);
filenames =  ["su_dl_FA_off_200bytes_mcs1.log"; 
              'su_dl_FA_off_200bytes_mcs2.log';
              'su_dl_FA_off_200bytes_mcs3.log';
              'su_dl_FA_off_200bytes_mcs4.log';
              'su_dl_FA_off_200bytes_mcs5.log';
              'su_dl_FA_off_200bytes_mcs6.log';
              'su_dl_FA_off_200bytes_mcs7.log';
              'su_dl_FA_off_200bytes_mcs8.log';
              'su_dl_FA_off_200bytes_mcs9.log';
              'su_dl_FA_off_200bytes_mcs10.log';
              'su_dl_FA_off_200bytes_mcs11.log'];
[throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(dir,filenames,isUL);
plot(mean(throughputs_matrix,2), '^-')
title('DL, NSS = 2 No Frame aggr')
legend('Max UDP (No Frame aggr)', '200 Bytes (No Frame aggr)')
xlabel('MCS')
ylabel('Rates(Mbps)');
grid on;

%% DL, FA, NSS = 1
dir = fullfile(root_dir, fa_on_dir);
filenames =  ["su_dl_mcs1_nss1.log"; 
              'su_dl_mcs2_nss1.log';
              'su_dl_mcs3_nss1.log';
              'su_dl_mcs4_nss1.log';
              'su_dl_mcs5_nss1.log';
              'su_dl_mcs6_nss1.log';
              'su_dl_mcs7_nss1.log';
              'su_dl_mcs8_nss1.log';
              'su_dl_mcs9_nss1.log';
              'su_dl_mcs10_nss1.log';
              'su_dl_mcs11_nss1.log'];

[throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(dir,filenames,isUL);
subplot(2,4,3);
plot(mean(throughputs_matrix,2), 'o-')
hold on;
plot(mean(phy_rates_matrix,2), '*--')
legend('Throughputs', 'PHY rates')
xlabel('MCS')
ylabel('Rates(Mbps)');
title('DL, NSS = 1 (Frame aggr)')
grid on;

%% DL, Impact of packet length
subplot(2,4,4);
dir = fullfile(root_dir, fa_off_various_length);
filenames =  ["su_dl_FA_off_100bytes_mcs1.log"; 
              'su_dl_FA_off_300bytes_mcs1.log';
              'su_dl_FA_off_500bytes_mcs1.log';
              'su_dl_FA_off_700bytes_mcs1.log';
              'su_dl_FA_off_900bytes_mcs1.log';
              'su_dl_FA_off_1100bytes_mcs1.log';
              'su_dl_FA_off_1300bytes_mcs1.log'];
          
lengths = 100:200:1300;
[throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(dir,filenames,isUL);
plot(lengths, mean(throughputs_matrix,2), 'o-')
hold on;

filenames =  ["su_dl_FA_off_100bytes_mcs5.log"; 
              'su_dl_FA_off_300bytes_mcs5.log';
              'su_dl_FA_off_500bytes_mcs5.log';
              'su_dl_FA_off_700bytes_mcs5.log';
              'su_dl_FA_off_900bytes_mcs5.log';
              'su_dl_FA_off_1100bytes_mcs5.log';
              'su_dl_FA_off_1300bytes_mcs5.log'];
          
[throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(dir,filenames,isUL);
plot(lengths, mean(throughputs_matrix,2), '*-')
hold on;


filenames =  ["su_dl_FA_off_100bytes_mcs11.log"; 
              'su_dl_FA_off_300bytes_mcs11.log';
              'su_dl_FA_off_500bytes_mcs11.log';
              'su_dl_FA_off_700bytes_mcs11.log';
              'su_dl_FA_off_900bytes_mcs11.log';
              'su_dl_FA_off_1100bytes_mcs11.log';
              'su_dl_FA_off_1300bytes_mcs11.log'];
          
[throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(dir,filenames,isUL);
plot(lengths, mean(throughputs_matrix,2), '^-')

legend('MCS 1', 'MCS 5', 'MCS 11')
xlabel('length(bytes)')
ylabel('Rates(Mbps)');
title('DL, Impact of packet length')
grid on;

%% UL, NSS = 2
% UL FA
dir = fullfile(root_dir, fa_on_dir);
filenames =  ["su_ul_mcs0.log";
              "su_ul_mcs1.log"; 
              'su_ul_mcs2.log';
              'su_ul_mcs3.log';
              'su_ul_mcs4.log';
              'su_ul_mcs5.log';
              'su_ul_mcs6.log';
              'su_ul_mcs7.log';
              'su_ul_mcs8.log';
              'su_ul_mcs9.log';
              'su_ul_mcs10.log';
              'su_ul_mcs11.log'];
isUL = 1;
[throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(dir,filenames,isUL);

subplot(2,4,5);
plot(0:11, mean(throughputs_matrix,2), 'o-')
hold on;
plot(0:11, mean(phy_rates_matrix,2)*4, '*--')
hold on;
xlabel('MCS')
ylabel('Rates(Mbps)');
grid on;
title('UL, NSS = 2 Frame aggr')
legend('Throughputs (Frame aggr)', 'PHY rates (Frame aggr)')
xlabel('MCS')
ylabel('Rates(Mbps)');


% UL no FA
dir = fullfile(root_dir, fa_off_dir);
filenames =  ["su_ul_FA_off_mcs0.log";
              "su_ul_FA_off_mcs1.log"; 
              'su_ul_FA_off_mcs2.log';
              'su_ul_FA_off_mcs3.log';
              'su_ul_FA_off_mcs4.log';
              'su_ul_FA_off_mcs5.log';
              'su_ul_FA_off_mcs6.log';
              'su_ul_FA_off_mcs7.log';
              'su_ul_FA_off_mcs8.log';
              'su_ul_FA_off_mcs9.log';
              'su_ul_FA_off_mcs10.log';
              'su_ul_FA_off_mcs11.log'];
isUL = 1;
[throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(dir,filenames,isUL);

subplot(2,4,6);
plot(0:11, mean(throughputs_matrix,2), 'o-')
% hold on;
% plot(0:11, mean(phy_rates_matrix,2)*4, '*--')
% hold on;
xlabel('MCS')
ylabel('Rates(Mbps)');
grid on;
title('UL, NSS = 2 No Frame aggr')
legend('Throughputs (No Frame aggr)')
xlabel('MCS')
ylabel('Rates(Mbps)');




