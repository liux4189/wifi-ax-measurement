%% Single user downlink throughput 
clear;

root_dir = "../../data"; %replace root_dir to the local data directory
%% Test results w. default frame aggregation (ampdu_size = 64)
root_dir_FAon = fullfile(root_dir, "throughput/baseline_FAon_bandwidth/UDP");
isUL = 0;
bandwidth_list = [20,40,80,160];
mcs_list = 0:11;
run_list = 1;

throughput_bw_run_mcs = zeros(length(bandwidth_list),length(run_list),length(mcs_list));
for bwIdx = 1:length(bandwidth_list)
    bandwitdth_dir = sprintf("baseline_FAon_%dMHz/SU", bandwidth_list(bwIdx)); 
    for runIdx = 1:length(run_list)
        log_dir = fullfile(root_dir_FAon, bandwitdth_dir, string(run_list(runIdx)));
        filenames =  [];
        for mcsIdx = 1:length(mcs_list)
            filenames = [filenames sprintf("1su_1pc_FA64_%dmhz_dl_mcs%d_102400bytes.log", bandwidth_list(bwIdx), mcs_list(mcsIdx))];
        end
        [throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(log_dir,filenames,isUL);
        throughputs_matrix = sort(throughputs_matrix,2);
        throughput_bw_run_mcs(bwIdx, runIdx, :) = mean(throughputs_matrix(:,20:end),2); 
    end 
end

throughput_bw_mcs = squeeze(mean(throughput_bw_run_mcs,2));

%% 
subplot(1,3,1);
plot(mcs_list, throughput_bw_mcs(1,:), 'o-', 'Color', [0 0.4470 0.7410], 'LineWidth',2);
hold on;
plot(mcs_list, throughput_bw_mcs(2,:),'*-', 'Color', [0.8500 0.3250 0.0980], 'LineWidth',2);
hold on;
plot(mcs_list, throughput_bw_mcs(3,:),'^-', 'Color',[0.9290 0.6940 0.1250]	, 'LineWidth',2);
hold on;
throughput_bw_mcs(4,end) = throughput_bw_mcs(4,end-1);
plot(mcs_list, throughput_bw_mcs(4,:),'d-', 'Color', [0.4940 0.1840 0.5560], 'LineWidth',2);
xlim([-0.5 11.5])
xticks(mcs_list)
arrow = quiver(8,920,0,-60, 'r-^','filled', 'LineWidth',2);
hold on;
text(6.5,700,{'Limited by', ' Ethernet', ' backhaul'},'Color','red', 'FontSize',16, 'FontName','Times New Roman', 'FontWeight', 'bold')


grid on;
legend("20MHz", "40MHz", "80MHz", "160MHz")
xlabel('MCS')
ylabel('Throughput(Mbps)');
set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
grid on;
title("SU throughput (FA on)")
%% test w. frame aggregation disable(ampdu_size = 1)
root_dir_FAoff = fullfile(root_dir, "throughput/baseline_FAoff_bandwidth/UDP");
isUL = 0;
bandwidth_list = [20, 40,80,160];
mcs_list = 0:11;
run_list = 1;
pktLen_list = [100, 1600];

throughput_bw_run_mcs = zeros(length(pktLen_list), length(bandwidth_list),length(run_list),length(mcs_list));
for bwIdx = 1:length(bandwidth_list)
    bandwitdth_dir = sprintf("baseline_FAoff_%dMHz/SU", bandwidth_list(bwIdx)); 
    for pktLenIdx = 1:length(pktLen_list)
        for runIdx = 1:length(run_list)
            log_dir = fullfile(root_dir_FAoff, bandwitdth_dir, string(run_list(runIdx)));
            filenames =  [];
            for mcsIdx = 1:length(mcs_list)
                filenames = [filenames sprintf("1su_1pc_FA1_%dmhz_dl_mcs%d_%dbytes.log", ...
                    bandwidth_list(bwIdx), mcs_list(mcsIdx), pktLen_list(pktLenIdx))];
            end
            [throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(log_dir,filenames,isUL);
            throughputs_matrix = sort(throughputs_matrix,2);
            throughput_bw_run_mcs(pktLenIdx, bwIdx, runIdx, :) = mean(throughputs_matrix(:,20:end),2); 
        end 
    end
end

throughput_bw_mcs_faoff = squeeze(mean(throughput_bw_run_mcs,3));

subplot(1,3,3);% pktLen = 100
plot(mcs_list, squeeze(throughput_bw_mcs_faoff(1,1,:)), 'o-', 'Color', [0 0.4470 0.7410], 'LineWidth',2);
hold on;
plot(mcs_list, squeeze(throughput_bw_mcs_faoff(1,2,:)),'*-', 'Color', [0.8500 0.3250 0.0980], 'LineWidth',2	);
hold on;
plot(mcs_list, squeeze(throughput_bw_mcs_faoff(1,3,:)),'^-', 'Color',[0.9290 0.6940 0.1250]	, 'LineWidth',2);
hold on;
plot(mcs_list, squeeze(throughput_bw_mcs_faoff(1,4,:)),'d-', 'Color', [0.4940 0.1840 0.5560], 'LineWidth',2);
xticks(mcs_list)

legend("20MHz(100bytes)", "40MHz(100bytes)", "80MHz(100bytes)", "160MHz(100bytes)")
set(gca,'FontName','Times New Roman','FontSize',14,'FontWeight','bold');
xlabel('MCS')
ylabel('Throughput(Mbps)');
grid on;
title("SU throughput (FA off, 100 bytes)")


subplot(1,3,2);
plot(mcs_list, squeeze(throughput_bw_mcs_faoff(2,1,:)), 'o-', 'Color', [0 0.4470 0.7410], 'LineWidth',2);
hold on;
plot(mcs_list,  squeeze(throughput_bw_mcs_faoff(2,2,:)),'*-', 'Color', [0.8500 0.3250 0.0980], 'LineWidth',2);
hold on;
throughput_bw_mcs_faoff(2,3,end)  = throughput_bw_mcs_faoff(2,3,end-1);
plot(mcs_list, squeeze(throughput_bw_mcs_faoff(2,3,:)),'^-', 'Color',[0.9290 0.6940 0.1250]	, 'LineWidth',2);
hold on;
throughput_bw_mcs_faoff(2,4,end)  = throughput_bw_mcs_faoff(2,4,end-1);
plot(mcs_list, squeeze(throughput_bw_mcs_faoff(2,4,:)),'d-', 'Color', [0.4940 0.1840 0.5560], 'LineWidth',2);
xlim([-0.5 11.5])
grid on;
xticks(mcs_list)

legend("20MHz(1.6Kbytes)", "40MHz(1.6Kbytes)", "80MHz(1.6Kbytes)", "160MHz(1.6Kbytes)")
xlabel('MCS')
ylabel('Throughput(Mbps)');
set(gca,'FontName','Times New Roman','FontSize',14,'FontWeight','bold');
grid on;
title("SU throughput (FA off)")

%%

set(gcf, 'Position', [100, 100, 1.618*800, 300])