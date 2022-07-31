//https://www.tutorialspoint.com/unix_sockets/socket_server_example.htm
#include <stdio.h>
#include <stdlib.h>

#include <netdb.h>
#include <netinet/in.h>
#include <math.h>
#include <string.h>

void exec(char* command);
void fixed_rate_client(char* ip, char* fixed_rate);
void fixed_rate_ap(char *ip, int mcs);
void configure_ul_ofdma_maxN(char *ip, int maxN);
FILE* parseCofigCSV(char *filename);
struct Config nextConfig(FILE *fp);
int remoteIperf3Test(char* cIP, int cPort, int sPort, int dataRate);
void rx_report(char* apIP, int nSTA, int isOFDMA, char* devName, int mcs, int duration);

int sendCMDPowerMonitor(char *pmIP, int pmPort, char* message);
void startPowerMonitor(char* pmIP, int pmPort, int nSTA, int isOFDMA, char* devName, int mcs);
void stopPowerMonitor(char* pmIP, int pmPort);

#define PM_IP "192.168.50.149"
#define PM_PORT 27015

//addrPrefix,cPort,server,clients,fixed_rate,ul_ofdma_mcs,dataRate
struct Config{
  int nSTA;
  char addrPrefix[13]; //prefix of wifi network
  int cPort;  //control port of wifi clients
  int server;
  int clients[8];
  int sPorts[8];//ports of iperf3 servers
  char fixed_rate[10];
  int ul_ofdma_mcs;
  int dataRate;
  char devName[10];
  int ofdma;
  int duration;
};

#define MEASURE_DIR "/tmp/home/root/measurement"
#define RX_REPORT_SCRIPT "rx_report.sh"

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
       printf("> Running the %d Configuration: \nnSTA: %d, fixed_rate: %s, UL OFDMA mcs: %d, OFDMA: %d dataRate %d Mbps\n", configIdx++, strConfig.nSTA, strConfig.fixed_rate, strConfig.ul_ofdma_mcs,
       strConfig.ofdma, strConfig.dataRate);

       //server ip
       char serverIP[16], apIP[16];
       sprintf(serverIP, "%s%d", strConfig.addrPrefix, strConfig.server);
       sprintf(apIP, "%s1", strConfig.addrPrefix);
       printf("Server IP %s, AP IP %s \n",serverIP, apIP);

       //fixed the rate at the AP (UL-OFDMA)*/
       fixed_rate_ap(apIP, strConfig.ul_ofdma_mcs);

       //configure max number of ul ofdma clients at the AP
       printf("> Configure max number of ul ofdma clients\n");
       configure_ul_ofdma_maxN(apIP,8);

       //start the test
       for(int cIdx = 0; cIdx < strConfig.nSTA; cIdx++){
         //fixed the rate at clients
         char clientIP[16];
         bzero(clientIP, sizeof(clientIP));
         sprintf(clientIP, "%s%d", strConfig.addrPrefix, strConfig.clients[cIdx]);
         printf("> Client IP %s, fixed_rate %s \n",clientIP, strConfig.fixed_rate);
         fixed_rate_client(clientIP, strConfig.fixed_rate);

         //trigger the iperf3
         double dataRate_per_user = ceil((double)strConfig.dataRate/(double)strConfig.nSTA);
         printf("> Trigger iperf3, sPort %d, dataRate %d Mbps \n", strConfig.sPorts[cIdx], (int)dataRate_per_user);
         res = remoteIperf3Test(clientIP,  strConfig.cPort, strConfig.sPorts[cIdx], (int)dataRate_per_user);
       }

       //sleep(strConfig.duration);
       sleep(5);

       //startPowerMonitor(PM_IP, PM_PORT,strConfig.nSTA, strConfig.ofdma, strConfig.devName, strConfig.ul_ofdma_mcs);
       rx_report(apIP, strConfig.nSTA, strConfig.ofdma, strConfig.devName, strConfig.ul_ofdma_mcs, strConfig.duration);
       //stopPowerMonitor(PM_IP, PM_PORT);

       printf("After rx_report\n");

       //stop the test
       for(int cIdx = 0; cIdx < strConfig.nSTA; cIdx++){
         char clientIP[16];
         bzero(clientIP, sizeof(clientIP));
         printf("Stop iperf3 %s\n", clientIP);
         sprintf(clientIP, "%s%d", strConfig.addrPrefix, strConfig.clients[cIdx]);
         res = remoteIperf3Test(clientIP,  strConfig.cPort, strConfig.sPorts[cIdx], 0);
       }

       printf("> Complete a test case, sleep for 5 seconds...\n");
       sleep(5);
   }

   return 0;

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

//ssh root@192.168.50.243 /home/lrf/workspace/fixed_rate.sh 0x11D417
void fixed_rate_client(char* ip, char* fixed_rate){
  char fixe_rate_cmd[100];
  sprintf(fixe_rate_cmd, "ssh root@%s /home/lrf/workspace/ul_autotest/fixed_rate.sh %s", ip, fixed_rate);
  printf("%s\n", fixe_rate_cmd);
  exec(fixe_rate_cmd);
}

//wl -i eth6  umsched mcs 9
void fixed_rate_ap(char *ip, int mcs){
  char fixe_rate_cmd[50];
  sprintf(fixe_rate_cmd, "ssh admin@%s wl -i eth6  umsched mcs %d", ip, mcs);
  exec(fixe_rate_cmd);
}

//wl -i eth6 umsched  maxn 8
void configure_ul_ofdma_maxN(char *ip, int maxN){
  char fixe_rate_cmd[50];
  sprintf(fixe_rate_cmd, "ssh admin@%s wl -i eth6  umsched maxn %d", ip, maxN);
  exec(fixe_rate_cmd);
  sprintf(fixe_rate_cmd, "ssh admin@%s wl -i eth6  umsched maxn", ip);
  exec(fixe_rate_cmd);
}

//ssh admin@192.168.50.1 /tmp/home/root/measurement/rx_report.sh 60 > /tmp/home/root/measurement/SU/1su_rasp_ul_mcs7.log
void rx_report(char* apIP, int nSTA, int isOFDMA, char* devName, int mcs, int duration){
  char script[50], logdir[50], logfile[50], create_dir_cmd[200], rx_report_cmd[200];
  sprintf(script, "%s/%s", MEASURE_DIR, RX_REPORT_SCRIPT);
  sprintf(logdir, "%s/%s", MEASURE_DIR, isOFDMA? "MU":"SU");
  sprintf(logfile, "%d%s_%s_ul_mcs%d.log", nSTA, isOFDMA? "mu":"su", devName, mcs);
  sprintf(create_dir_cmd, "ssh admin@%s mkdir %s", apIP, logdir);
  sprintf(rx_report_cmd, "ssh admin@%s '%s %d > %s/%s'", apIP, script, duration, logdir, logfile);

  printf("Writing log into File %s\n", rx_report_cmd);
  exec(create_dir_cmd);
  exec(rx_report_cmd);
  printf("Log completed\n");
}
/*
struct Config{
  int nSTA;
  char addrPrefix[12];
  int cPort;
  int server;
  int clients[8];
  char fixed_rate[10];
  int ul_ofdma_mcs;
  int dataRate;
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
    memcpy(stConfig.addrPrefix, ptr, strlen(ptr));

    //client control channel port
    stConfig.cPort = atoi(strtok(NULL, ","));

    //server
    stConfig.server = atoi(strtok(NULL, ","));

    //clients and iperf3 ports
    char *strClients = strtok(NULL, ",");
    char *strsPorts  = strtok(NULL, ",");

    //fixed_rate
    ptr = strtok(NULL, ",");
    bzero(stConfig.fixed_rate, sizeof(stConfig.fixed_rate));
    memcpy(stConfig.fixed_rate, ptr, strlen(ptr));

    //OFDMA MCS
    stConfig.ul_ofdma_mcs = atoi(strtok(NULL, ","));

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

    //sPorts
    token = strtok(strsPorts, "/");
    idx = 0;
    while(token != NULL) {
        stConfig.sPorts[idx++] = atoi(token);
        token = strtok(NULL, "/");
    }
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

int remoteIperf3Test(char* cIP, int cPort, int sPort, int dataRate){
     int sockfd, portno, n;
     struct sockaddr_in serv_addr;
     struct hostent *server;

     /* Create a socket point */
     sockfd = socket(AF_INET, SOCK_STREAM, 0);

     if (sockfd < 0) {
        perror("remoteIperf3Test - ERROR opening socket");
        return -1;
     }

     server = gethostbyname(cIP);

     if (server == NULL) {
        fprintf(stderr,"remoteIperf3Test - ERROR, no such host\n");
        return -1;
     }

     bzero((char *) &serv_addr, sizeof(serv_addr));
     serv_addr.sin_family = AF_INET;
     bcopy((char *)server->h_addr, (char *)&serv_addr.sin_addr.s_addr, server->h_length);
     serv_addr.sin_port = htons(cPort);

     /* Now connect to the server */
     if (connect(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0) {
        perror("remoteIperf3Test - ERROR connecting");
        return -1;
     }

     char txBuffer[5], rxBuffer[5];
     bzero(txBuffer,5);
     sprintf(txBuffer, "%d %d", sPort, dataRate);

     /* Send message to the server */
     n = write(sockfd, txBuffer, strlen(txBuffer));

     if (n < 0) {
        perror("remoteIperf3Test - ERROR writing to socket");
        return -1;
     }

     /* Now read server response */
     bzero(rxBuffer,5);
     n = read(sockfd, rxBuffer, 5);

     if (n < 0) {
        perror("remoteIperf3Test - ERROR reading from socket");
        return -1;
     }

     printf("response from %s: %s\n",cIP, rxBuffer);
     return 0;
}

void startPowerMonitor(char* pmIP, int pmPort, int nSTA, int isOFDMA, char* devName, int mcs){
    char  logfile[50], message[100];
    bzero(logfile,50);
    bzero(message, 100);
    sprintf(logfile, "%d%s_%s_ul_mcs%d.csv", nSTA, isOFDMA? "mu":"su", devName, mcs);
    //sprintf(message, "0,%s/%s'",  isOFDMA? "MU":"SU", logfile);
    sprintf(message, "0,%s", logfile);
    sendCMDPowerMonitor(pmIP, pmPort, message);
}

void stopPowerMonitor(char* pmIP, int pmPort){
  sendCMDPowerMonitor(pmIP, pmPort, "1");
}

int sendCMDPowerMonitor(char *pmIP, int pmPort, char* message){
  int sockfd, portno, n;
  struct sockaddr_in serv_addr;
  struct hostent *server;

  /* Create a socket point */
  sockfd = socket(AF_INET, SOCK_STREAM, 0);

  if (sockfd < 0) {
     perror("sendCMDPowerMonitor - ERROR opening socket");
     return -1;
  }

  server = gethostbyname(pmIP);

  if (server == NULL) {
     fprintf(stderr,"sendCMDPowerMonitor - ERROR, no such host\n");
     return -1;
  }

  bzero((char *) &serv_addr, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  bcopy((char *)server->h_addr, (char *)&serv_addr.sin_addr.s_addr, server->h_length);
  serv_addr.sin_port = htons(pmPort);

  /* Now connect to the server */
  if (connect(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0) {
     perror("sendCMDPowerMonitor - ERROR connecting");
     return -1;
  }

  char rxBuffer[100];

  /* Send message to the server */
  n = write(sockfd, message, strlen(message));

  if (n < 0) {
     perror("sendCMDPowerMonitor - ERROR writing to socket");
     return -1;
  }

  /* Now read server response */
  bzero(rxBuffer,100);
  n = read(sockfd, rxBuffer, 100);

  if (n < 0) {
     perror("sendCMDPowerMonitor - ERROR reading from socket");
     return -1;
  }

  printf("response from Power Monitor %s\n", rxBuffer);
  return 0;
}
