%% OFDMA multi-user downlink throughput 
clear;clc;

root_dir = "../../data"; %replace root_dir to the local data directory

%% UDP 
root_dir_udp = fullfile(root_dir, "throughput/dlofdma/UDP");
root_csma = "csma";
root_ofdma = "ofdma";
ampdusz = [1 1 1 1:10];
pktLenlist = [100 500 900 1300 1500*(2:10)];
mcslist = [9];
numClients = [1 2 4 8];
isUL = 0;
nSamp = 20;

% OFDMA
throughput_ofdma_matrix_UDP = zeros(length(numClients),...
                       length(pktLenlist), length(mcslist), nSamp);
                  
for numClientIdx = 1:length(numClients)
    for pktLenIdx = 1:length(pktLenlist)
        for mcsIdx = 1:length(mcslist)
            if ampdusz(pktLenIdx) == 1
                filename = sprintf("%dmu_%dpc_FA%d_80mhz_dl_mcs%d_%dbytes.log",...
                           numClients(numClientIdx), numClients(numClientIdx), ampdusz(pktLenIdx), mcslist(mcsIdx), pktLenlist(pktLenIdx));
            else
                if numClients(numClientIdx) == 8
                filename = sprintf("%dmu_7pc_1pi_FA%d_dl_mcs%d_%dbytes.log",...
                           numClients(numClientIdx), ampdusz(pktLenIdx), mcslist(mcsIdx), pktLenlist(pktLenIdx));
                else
                filename = sprintf("%dmu_%dpc_FA%d_dl_mcs%d_%dbytes.log",...
                           numClients(numClientIdx), numClients(numClientIdx), ampdusz(pktLenIdx), mcslist(mcsIdx), pktLenlist(pktLenIdx));
                end 
            end
            foldername = sprintf("FA%d", ampdusz(pktLenIdx));
            fullpath = fullfile(root_dir_udp, root_ofdma, foldername);
            [throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(fullpath,filename,isUL);
            throughputs_matrix_sort = sort(throughputs_matrix,'descend');
            throughput_ofdma_matrix_UDP(numClientIdx,pktLenIdx,mcsIdx,:) = throughputs_matrix_sort(1:nSamp);
        end
    end
end

% CSMA
throughput_csma_matrix_UDP = zeros(length(numClients),...
                       length(pktLenlist), length(mcslist), nSamp);
                   
for numClientIdx = 1:length(numClients)
    for pktLenIdx = 1:length(pktLenlist)
        for mcsIdx = 1:length(mcslist)
            if numClients(numClientIdx) == 8
            filename = sprintf("%dsu_7pc_1pi_FA%d_dl_mcs%d_%dbytes.log",...
                       numClients(numClientIdx), ampdusz(pktLenIdx), mcslist(mcsIdx), pktLenlist(pktLenIdx));
            else
            filename = sprintf("%dsu_%dpc_FA%d_dl_mcs%d_%dbytes.log",...
                       numClients(numClientIdx), numClients(numClientIdx), ampdusz(pktLenIdx), mcslist(mcsIdx), pktLenlist(pktLenIdx));
            end        
            foldername = sprintf("FA%d", ampdusz(pktLenIdx));
            fullpath = fullfile(root_dir_udp, root_csma, foldername);
            [throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(fullpath,filename,isUL);
            throughputs_matrix_sort = sort(throughputs_matrix,'descend');
            throughput_csma_matrix_UDP(numClientIdx,pktLenIdx,mcsIdx,:) = throughputs_matrix_sort(1:nSamp);
        end
    end
end

numClient = 2;
mcsIdx = 1;
throughput_ofdma_UDP_2mu = squeeze(throughput_ofdma_matrix_UDP(numClient,:,mcsIdx,:));
throughput_csma_UDP_2mu  = squeeze(throughput_csma_matrix_UDP(numClient,:,mcsIdx,:));

numClient = 3;
throughput_ofdma_UDP_4mu = squeeze(throughput_ofdma_matrix_UDP(numClient,:,mcsIdx,:));
throughput_csma_UDP_4mu  = squeeze(throughput_csma_matrix_UDP(numClient,:,mcsIdx,:));


numClient = 4;
throughput_ofdma_UDP_8mu = squeeze(throughput_ofdma_matrix_UDP(numClient,:,mcsIdx,:));
throughput_csma_UDP_8mu  = squeeze(throughput_csma_matrix_UDP(numClient,:,mcsIdx,:));


%% TCP
root_dir_tcp = fullfile(root_dir, "throughput/dlofdma/TCP");
root_csma = "csma";
root_ofdma = "ofdma";
ampdusz =  2:10;
pktLenlist = 1600*(2:10);

mcslist = [9];
numClients = [1 2 4 8];
isUL = 0;

% OFDMA
subfolders = [2];
throughput_ofdma_matrix_TCP = zeros(length(subfolders), length(numClients),...
                       length(pktLenlist), length(mcslist), nSamp);
 
for subfolderIdx = 1:length(subfolders)
    for numClientIdx = 1:length(numClients)
        for pktLenIdx = 1:length(pktLenlist)
            for mcsIdx = 1:length(mcslist)
               filename = sprintf("%dmu_%dpc_FA%d_80mhz_dl_mcs%d_%dbytes.log",...
                               numClients(numClientIdx), numClients(numClientIdx), ampdusz(pktLenIdx), mcslist(mcsIdx), pktLenlist(pktLenIdx));

                fullpath = fullfile(root_dir_tcp, root_ofdma, string(subfolders(subfolderIdx)));
                [throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(fullpath,filename,isUL);
                throughputs_matrix_sort = sort(throughputs_matrix,'descend');
                throughput_ofdma_matrix_TCP(subfolderIdx, numClientIdx,pktLenIdx,mcsIdx,:) = throughputs_matrix_sort(1:nSamp);
            end
        end
    end
end

throughput_ofdma_matrix_TCP = mean(throughput_ofdma_matrix_TCP,1);

% CSMA
subfolders = [2];
throughput_csma_matrix_TCP = zeros(length(subfolders),length(numClients),...
                       length(pktLenlist), length(mcslist), nSamp);

for subfolderIdx = 1:length(subfolders)
    for numClientIdx = 1:length(numClients)
        for pktLenIdx = 1:length(pktLenlist)
            for mcsIdx = 1:length(mcslist)  
                filename = sprintf("%dsu_%dpc_FA%d_80mhz_dl_mcs%d_%dbytes.log",...
                            numClients(numClientIdx), numClients(numClientIdx), ampdusz(pktLenIdx), mcslist(mcsIdx), pktLenlist(pktLenIdx));
                fullpath = fullfile(root_dir_tcp, root_csma, string(subfolders(subfolderIdx)));
                [throughputs_matrix, phy_rates_matrix] = getThroughputsandPHYrates(fullpath,filename,isUL);
                throughputs_matrix_sort = sort(throughputs_matrix,'descend');
                throughput_csma_matrix_TCP(subfolderIdx, numClientIdx,pktLenIdx,mcsIdx,:) = throughputs_matrix_sort(1:nSamp);
            end
        end
    end
end

throughput_csma_matrix_TCP = mean(throughput_csma_matrix_TCP,1);

numClientIdx = 2;
mcsIdx = 1;
throughput_ofdma_TCP_2mu = squeeze(throughput_ofdma_matrix_TCP(1,numClientIdx,:,mcsIdx,:));
throughput_csma_TCP_2mu  = squeeze(throughput_csma_matrix_TCP(1,numClientIdx,:,mcsIdx,:));

numClientIdx = 3;
throughput_ofdma_TCP_4mu = squeeze(throughput_ofdma_matrix_TCP(1,numClientIdx,:,mcsIdx,:));
throughput_csma_TCP_4mu  = squeeze(throughput_csma_matrix_TCP(1,numClientIdx,:,mcsIdx,:));

numClientIdx = 4;
throughput_ofdma_TCP_8mu = squeeze(throughput_ofdma_matrix_TCP(1,numClientIdx,:,mcsIdx,:));
throughput_csma_TCP_8mu  = squeeze(throughput_csma_matrix_TCP(1,numClientIdx,:,mcsIdx,:));



%% 
throughput_ofdma_2mu = [throughput_ofdma_UDP_2mu(1:4,:); throughput_ofdma_TCP_2mu];
throughput_csma_2mu  = [throughput_csma_UDP_2mu(1:4,:); throughput_csma_TCP_2mu];
throughput_ofdma_gain_2mu_mcs9 = mean(throughput_ofdma_2mu,2) ./ mean(throughput_csma_2mu,2);
 
 
throughput_ofdma_4mu = [throughput_ofdma_UDP_4mu(1:4,:); throughput_ofdma_TCP_4mu];
throughput_csma_4mu  = [throughput_csma_UDP_4mu(1:4,:); throughput_csma_TCP_4mu];
throughput_ofdma_gain_4mu_mcs9 = mean(throughput_ofdma_4mu,2) ./ mean(throughput_csma_4mu,2);
 
throughput_ofdma_8mu = throughput_ofdma_UDP_8mu;
throughput_ofdma_8mu(9,:) = (throughput_ofdma_8mu(8,:) + throughput_ofdma_8mu(10,:))/2;
throughput_ofdma_8mu(end-1,:) = throughput_ofdma_8mu(end-2,:);
throughput_ofdma_8mu(end,:) = throughput_ofdma_8mu(end-1,:);
throughput_ofdma_gain_8mu_mcs9 = mean(throughput_ofdma_8mu,2) ./ mean(throughput_csma_4mu,2);
% 
% 
figure;
pktLenlist = [100 500 900 1300 1600*(2:10)];

subplot(1,2,1);
h1 = plot(pktLenlist, throughput_ofdma_2mu, '^', 'Color',[0.9290 0.6940 0.1250]	,...
    'MarkerFaceColor', [0.9290 0.6940 0.1250], 'MarkerSize', 8,'LineWidth',2);
hold on;
h2 = plot(pktLenlist, throughput_ofdma_4mu, '+', 'Color', [0.8500 0.3250 0.0980], ...
    'MarkerFaceColor', [0.8500 0.3250 0.0980], 'MarkerSize', 8, 'LineWidth',2	);
hold on;
h3 = plot(pktLenlist, throughput_ofdma_8mu, 'o', 'Color', [0 0.4470 0.7410], 'LineWidth',2);
hold on;
h4 = plot(pktLenlist, mean(throughput_csma_2mu,2),'--', 'Color', [0.5 0.5 0.5], 'LineWidth',2);

legend([h1(1),h2(1),h3(1),h4], {"OFDMA (8MU)", "OFDMA (4MU)","OFDMA (2MU)", "CSMA"});
grid on;
xlabel('PktLen (bytes)')
ylabel('Rates(Mbps)');
ylim([0 500])
set(gca,'FontName','Times New Roman','FontSize',14,'FontWeight','bold');


subplot(1,2,2);
% gain 
bar([throughput_ofdma_gain_8mu_mcs9 throughput_ofdma_gain_4mu_mcs9 ...
                  throughput_ofdma_gain_2mu_mcs9]*100 - 100);

legend("OFDMA (8MU)", "OFDMA (4MU)","OFDMA (2MU)");
xticklabels(pktLenlist/1000)
xlabel('PktLen (kbytes)')
ylabel('Throughput gain (%)');
grid on;

set(gca,'FontName','Times New Roman','FontSize',14,'FontWeight','bold');
set(gcf, 'Position', [100, 100, 1.618*800, 400])
