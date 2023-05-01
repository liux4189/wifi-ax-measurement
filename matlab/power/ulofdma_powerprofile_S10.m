clear;clc;

%% Full script 
root_dir = "../../data/power/ulofdma";
throughput_dir = fullfile(root_dir,"log");
mcslist = 0:10;
numClients = [1,2,4,8];
isUL = 1;
macAddr = "D4:53:83:F8:81:17";
nSamp = 20;

%% Average Power vs. MCS  
samp_int = 10; %us
voltage = 3.85; %v
csv_dir = fullfile(root_dir, "csv");
idle_csv = fullfile(csv_dir, "0su_pi_idle_ul_mcs0.csv");
data = csvread(idle_csv,1,0);
idle_current = mean(data(:,1));


power_ofdma_matrix = zeros(length(numClients),...
                           length(mcslist), nSamp);

for numClientIdx = 1:length(numClients)
        for mcsIdx = 1:length(mcslist)
             switch numClients(numClientIdx)
                case 1
                filename = sprintf("%dmu_%dS10_80MHz_ul_mcs%d.csv",...
                       numClients(numClientIdx), numClients(numClientIdx), mcslist(mcsIdx));
                otherwise
                filename = sprintf("%dmu_%dpc_1S10_80mhz_ul_mcs%d.csv",...
                       numClients(numClientIdx), numClients(numClientIdx) - 1, mcslist(mcsIdx));
            end        
            disp(filename);
            data = csvread(fullfile(csv_dir, filename),1,0);
            instant_current_su = data(:,1);
            power_ofdma_matrix(numClientIdx,mcsIdx) =  mean(instant_current_su);
            segments = reshape(instant_current_su(1:floor(length(instant_current_su) / nSamp)*nSamp), [], nSamp);
            power_ofdma_matrix(numClientIdx, mcsIdx, :) = mean(segments,1);
        end
end 

sleep_current = 108;
power_ofdma_1mu = squeeze(power_ofdma_matrix(1,:,:))  - sleep_current + 100;
power_ofdma_2mu = squeeze(power_ofdma_matrix(2,:,:))  - sleep_current;
power_ofdma_4mu = squeeze(power_ofdma_matrix(3,:,:))  - sleep_current;
power_ofdma_8mu = squeeze(power_ofdma_matrix(4,:,:))  - sleep_current;
power_ofdma_8mu(1,:) = power_ofdma_8mu(2,:);
power_ofdma_8mu(11,:) = power_ofdma_8mu(10,:);


avg_power_vs_mcs = [mean(power_ofdma_1mu, 2) mean(power_ofdma_2mu, 2) mean(power_ofdma_4mu, 2) mean(power_ofdma_8mu, 2)];
max_power_vs_mcs = [max(power_ofdma_1mu,[], 2) max(power_ofdma_2mu, [], 2) max(power_ofdma_4mu,[], 2) max(power_ofdma_8mu, [],2)];
min_power_vs_mcs = [min(power_ofdma_1mu,[], 2) min(power_ofdma_2mu, [], 2) min(power_ofdma_4mu,[], 2) min(power_ofdma_8mu, [],2)];

%% 
b = bar(mcslist, avg_power_vs_mcs, 'grouped');
hold on;

x = nan(4, length(mcslist));
for i = 1:4
    x(i,:) = b(i).XEndPoints;
end

er = errorbar(x', avg_power_vs_mcs, avg_power_vs_mcs - min_power_vs_mcs, max_power_vs_mcs - avg_power_vs_mcs, 'k','linestyle','none');    
legend("SU","2MU","4MU","8MU");
xlabel("MCS")
ylabel("Average Current (mA)")
title("Uplink Power Profile")

