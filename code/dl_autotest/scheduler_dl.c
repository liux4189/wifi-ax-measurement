#include <stdio.h>
#include <stdlib.h>

#include <netdb.h>
#include <netinet/in.h>
#include <math.h>
#include <string.h>
#include <signal.h>

#define RED   "\x1B[31m"
#define GRN   "\x1B[32m"
#define YEL   "\x1B[33m"
#define BLU   "\x1B[34m"
#define MAG   "\x1B[35m"
#define CYN   "\x1B[36m"
#define WHT   "\x1B[37m"
#define RESET "\x1B[0m"

struct Config nextConfig(FILE *fp);
FILE* parseCofigCSV(char *filename);
void configure_5g_rate(char *ip, int dl_mcs);
void exec(char* command);
void configure_dl_ofdma_maxN(char *ip, int maxN);
void create_log_dir(char * apIP, int isOFDMA, int isDL);
void bs_data(char* apIP, int nSTA, int isOFDMA, char* devName, int mcs, int pktLen, int duration);
void exportCurrentConfig(int nSTA, int isOFDMA, int mcs, int pktLen, char* devName);

//addrPrefix	sPorts	5g_rate	pktLen	dataRate(mbps)	devname	ofdma	duration(s)
struct Config{
  int nSTA;
  char addrPrefix[13]; //prefix of wifi network
  int clients[8];
  int sPorts[8];//ports of iperf3 servers
  int dl_mcs;
  int pktLen_head;
  int pktLen_tail;
  int pktLen_intv;
  int dataRate;
  char devName[20];
  int ofdma;
  int duration;
};

#define MEASURE_DIR "/tmp/home/root/measurement/"
#define BS_DATA_SCRIPT "bs_data.sh"

int main(int argc, char *argv[]) {

   int res = 0;
   if (argc < 2) {
      fprintf(stderr,"usage %s config.csv\n", argv[0]);
      exit(0);
   }

   /*open cofigure file*/
   FILE* fp = parseCofigCSV(argv[1]);
   int configIdx = 0;
   while (1){
       printf("----------------------------------------------\n" );
       //read the next test configuration
       struct Config strConfig = nextConfig(fp);
       if (strConfig.nSTA == 0){
          printf("reach the end of config, exit\n");
          break;
       }
       printf("> Running the #%d Configuration: \nnSTA: %d, dl_mcs: %d, OFDMA: %d dataRate %d Mbps, pktLen(%d:%d:%d)\n", configIdx++, strConfig.nSTA, strConfig.dl_mcs,
       strConfig.ofdma, strConfig.dataRate, strConfig.pktLen_head, strConfig.pktLen_intv, strConfig.pktLen_tail);

       //configure max number of dl ofdma clients at the AP
       char apIP[16];
       printf("%s\n", strConfig.addrPrefix);
       sprintf(apIP, "%s1", strConfig.addrPrefix);

       printf("> Configure max number of dl ofdma clients at AP (%s)\n", apIP);
       configure_dl_ofdma_maxN(apIP,8);

       //global parameter
       double dataRate_per_user = ceil((double)strConfig.dataRate/(double)strConfig.nSTA);
       char strDataRate[6];
       sprintf(strDataRate, "%dm", (int)dataRate_per_user);

       //create log dir
       create_log_dir(apIP, strConfig.ofdma, 1);

       //start the test, iterate through each packet length
       for(int pktLen = strConfig.pktLen_head; pktLen <= strConfig.pktLen_tail; pktLen+=strConfig.pktLen_intv){
            //start iperf3 process with specific packet length
            int pids[8] = {0};
            char strPktLen[5];
            sprintf(strPktLen, "%d", pktLen);
            int iperf3serverIdx = 0;
            while(iperf3serverIdx < strConfig.nSTA){
                 int pid = fork();
                 pids[iperf3serverIdx] = pid;
                 if(pid == 0){ //it is a child process
                    char iperf3serverip[50];
                    sprintf(iperf3serverip,"%s%d", strConfig.addrPrefix, strConfig.clients[iperf3serverIdx]);
                    if(pktLen <= 1500){
                      execl("/usr/bin/iperf3",  "/usr/bin/iperf3", "-c", iperf3serverip, "-u", "-b", strDataRate, "-l", strPktLen, "-t", "12000", (char*) NULL);
                    }else{ // for AMPDU_size > 1, let the iperf3 decide the packet size
                      execl("/usr/bin/iperf3",  "/usr/bin/iperf3", "-c", iperf3serverip, "-u", "-b", strDataRate, "-t", "12000", (char*) NULL);
                    }
                    exit(EXIT_SUCCESS);
                 }
                 printf("Execute iperf3 to #%d server, IP = %s%d, pid = %d\n", iperf3serverIdx, strConfig.addrPrefix, strConfig.clients[iperf3serverIdx], pids[iperf3serverIdx]);
                 iperf3serverIdx++;
            }

            //iterate through each MCS and log the throughput
            for(int mcs = 0; mcs < 11; mcs++){
                  if(strConfig.dl_mcs != -1 && strConfig.dl_mcs != mcs){
                    continue;
                  }
                  printf("%s> Subsession start with pktlen =%d, mcs=%d %s\n", BLU, pktLen, mcs, RESET);
                  //update MCS
                  configure_5g_rate(apIP, mcs);
                  exportCurrentConfig(strConfig.nSTA, strConfig.ofdma, mcs, pktLen, strConfig.devName);
                  sleep(10); //wait for a while until the traffic becomes stable.
                  //log the throughput using bs_data
                  bs_data(apIP, strConfig.nSTA, strConfig.ofdma, strConfig.devName, mcs,  pktLen, strConfig.duration);
            }

            //stop all the iperf3 process
            iperf3serverIdx = 0;
            while(iperf3serverIdx < strConfig.nSTA){
                  printf("Kill iperf3 to #%d server, IP = %s%d, pid = %d\n", iperf3serverIdx, strConfig.addrPrefix, strConfig.clients[iperf3serverIdx], pids[iperf3serverIdx]);
                  kill(pids[iperf3serverIdx++], SIGINT);
            }
            sleep(10); //wait a while
       }
     }
}

/*struct Config{
  int nSTA;
  char addrPrefix[13]; //prefix of wifi network
  int clients[8];
  int sPorts[8];//ports of iperf3 servers
  int dl_mcs;
  int pktLen[20];
  int dataRate;
  char devName[10];
  int ofdma;
  int duration;
};*/
struct Config nextConfig(FILE *fp){
    struct Config stConfig;
    if(!fp || feof(fp)){
      stConfig.nSTA = 0;
      return stConfig;
    }

    char row[300];
    memset(row, 0, 300);
    char *token;

    //read a row
    fgets(row, 300, fp);
    printf("Read the configuration: %s", row);

    if(!strlen(row)){
      stConfig.nSTA = 0;
      return stConfig;
    }

    //address prefix
    char* ptr = strtok(row, ",");
    bzero(stConfig.addrPrefix, sizeof(stConfig.addrPrefix));
    memcpy(stConfig.addrPrefix, ptr, strlen(ptr));

    //clients and iperf3 ports
    char *strClients = strtok(NULL, ",");

    //5g_rate
    stConfig.dl_mcs = atoi(strtok(NULL, ","));

    //pktLen
    char * strPktLen = strtok(NULL, ",");

    //Data Rate in Mbps
    stConfig.dataRate =  atoi(strtok(NULL, ","));

    //devName
    ptr = strtok(NULL, ",");
    bzero(stConfig.devName, sizeof(stConfig.devName));
    memcpy(stConfig.devName, ptr, strlen(ptr));

    //ofdma or csma
    stConfig.ofdma =  atoi(strtok(NULL, ","));

    //duration
    stConfig.duration = atoi(strtok(NULL, ","));

    //clients
    token = strtok(strClients, "/");
    int idx = 0;
    while(token != NULL) {
        //printf("%s\n", token);
        stConfig.clients[idx++] = atoi(token);
        token = strtok(NULL, "/");
    }
    stConfig.nSTA = idx;

    //parse pktlen
    stConfig.pktLen_head = atoi(strtok(strPktLen, ":"));
    stConfig.pktLen_intv = atoi(strtok(NULL, ":"));
    stConfig.pktLen_tail = atoi(strtok(NULL, ":"));

    return stConfig;
}

//https://stdin.top/posts/csv-in-c/
FILE* parseCofigCSV(char *filename){
    FILE *fp;
    char row[200];
    char *token;

    printf("read config file: %s\n", filename);
    fp = fopen(filename,"r");

    if (!fp || feof(fp))
      return NULL;

    fgets(row, 200, fp);
    printf("%s", row);
    return fp;
}

void exportCurrentConfig(int nSTA, int isOFDMA, int mcs, int pktLen, char* devName){
    FILE *fp = fopen("config/current_cfg", "w");
    fprintf(fp,"%d%s_%s_dl_mcs%d_%dbytes", nSTA, isOFDMA? "mu":"su", devName, mcs, pktLen);
    pclose(fp);
}

void exec(char* command) {
   char buffer[128];

   // Open pipe to file
   FILE* pipe = popen(command, "r");
   if (!pipe) {
      printf("popen failed!\n");
   }

   // read till end of process:
   while (!feof(pipe)) {

      // use buffer to read and add to result
      if (fgets(buffer, 128, pipe) != NULL)
         printf("%s", buffer);
   }
   printf("\n");
   pclose(pipe);
   return;
}


//wl -i eth6 5g_rate -e 9x2
void configure_5g_rate(char *ip, int dl_mcs){
  char fixed_5g_rate_cmd[50];
  sprintf(fixed_5g_rate_cmd, "ssh admin@%s wl -i eth6 5g_rate -e %dx2", ip, dl_mcs);
  exec(fixed_5g_rate_cmd);
  sprintf(fixed_5g_rate_cmd, "ssh admin@%s wl -i eth6 5g_rate", ip);
  exec(fixed_5g_rate_cmd);
}

//wl -i eth6 msched maxn 8
void configure_dl_ofdma_maxN(char *ip, int maxN){
  char fixe_rate_cmd[50];
  sprintf(fixe_rate_cmd, "ssh admin@%s wl -i eth6  msched maxn %d", ip, maxN);
  exec(fixe_rate_cmd);
  sprintf(fixe_rate_cmd, "ssh admin@%s wl -i eth6  msched maxn", ip);
  exec(fixe_rate_cmd);
}

void create_log_dir(char * apIP, int isOFDMA, int isDL){
  char logdir[50], create_dir_cmd[200];
  sprintf(logdir, "%s/%s/%s", MEASURE_DIR, isDL? "DL":"UL", isOFDMA? "MU":"SU");
  sprintf(create_dir_cmd, "ssh admin@%s mkdir %s", apIP, logdir);
  exec(create_dir_cmd);
}

//ssh admin@192.168.50.1 /tmp/home/root/measurement/bs_data.sh 60 > /tmp/home/root/measurement/DL/SU/1su_rasp_ul_mcs7.log
void bs_data(char* apIP, int nSTA, int isOFDMA, char* devName, int mcs, int pktLen, int duration){
  char script[50], logdir[50], logfile[50], create_dir_cmd[200], bs_data_cmd[200];
  sprintf(script, "%s/%s", MEASURE_DIR, BS_DATA_SCRIPT);
  sprintf(logdir, "%s/DL/%s", MEASURE_DIR, isOFDMA? "MU":"SU");
  sprintf(logfile, "%d%s_%s_dl_mcs%d_%dbytes.log", nSTA, isOFDMA? "mu":"su", devName, mcs, pktLen);
  sprintf(bs_data_cmd, "ssh admin@%s '%s %d > %s/%s'", apIP, script, duration, logdir, logfile);

  printf("%sWriting log into File %s %s\n", BLU, bs_data_cmd, RESET);
  exec(bs_data_cmd);
  printf("Log completed\n");
}
