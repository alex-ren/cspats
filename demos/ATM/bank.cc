/*
bank.cc

This program runs with the atm program generated from CSP++. It listens for messages from the atm user coded functions and makes mysql database connections to the bank database.

Notes:

bank.cc can be compiled as follows (depending on your system setup):
g++ bank.cc -o bank -I/usr/local/mysql/include -L/usr/local/mysql/lib/ -lmysqlclient -lz

You may need to change the mysql database information that is listed just above the main method.

You may also need to change the thehost listed at the beginning of the main method depending on your configuration.   
*/

#include <mysql.h>
#include <stdio.h>
#include <stdlib.h> 
#include <errno.h> 
#include <string.h> 
#include <strings.h>
#include <sys/types.h> 
#include <netinet/in.h> 
#include <netdb.h> 
#include <sys/socket.h> 
#include <sys/wait.h> 

#define THEIRPORT 4951    /* the port we will be sending to */
#define MYPORT 4950    /* the port we will be receiving from */

#define MAXBUFLEN 100

// mysql database information
char *server = "localhost";
char *user = "root";
char *password = "YOUR PASSWORD HERE";
char *database = "mydb";

int main(int argc, char *argv[])
{
	char thehost[] = "127.0.0.1";
	int transaction, card, pin, account, from, to, amount;

	int sockfd;
	struct sockaddr_in my_addr;    /* our address information */
	struct sockaddr_in their_addr; /* their address information */
	socklen_t addr_len;
	int numbytes;
	char buf[MAXBUFLEN];
	struct hostent *he;

	if ((he=gethostbyname(thehost)) == NULL) {  /* get the host info */
		herror("gethostbyname");
		exit(1);
	}

	if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
		perror("socket");
		exit(1);
	}

	their_addr.sin_family = AF_INET;      /* host byte order */
	their_addr.sin_port = htons(THEIRPORT);  /* short, network byte order */
	their_addr.sin_addr = *((struct in_addr *)he->h_addr);
	bzero(&(their_addr.sin_zero), 8);     /* zero the rest of the struct */

	my_addr.sin_family = AF_INET;         // host byte order
	my_addr.sin_port = htons(MYPORT);     // short, network byte order
	my_addr.sin_addr.s_addr = INADDR_ANY; // auto-fill with my IP
	bzero(&(my_addr.sin_zero), 8);        // zero the rest of the struct

	if (bind(sockfd, (struct sockaddr *)&my_addr, sizeof(struct sockaddr)) == -1) {
		perror("bind");
		exit(1);
	}

		MYSQL *conn;
		MYSQL_RES *res;
		MYSQL_ROW row;
 	
		conn = mysql_init(NULL);

		/* Connect to database */
		if (!mysql_real_connect(conn, server,
				user, password, database, 0, NULL, 0)) {
			fprintf(stderr, "%s\n", mysql_error(conn));
			exit(0);
		}

		/* send SQL query */
		if (mysql_query(conn, "set autocommit=0")) {
			fprintf(stderr, "%s\n", mysql_error(conn));
			exit(0);
		}

		/* send SQL query */
		if (mysql_query(conn, "begin")) {
			fprintf(stderr, "%s\n", mysql_error(conn));
			exit(0);
		}

	while(1) 
	{
        addr_len = sizeof(struct sockaddr);
        if ((numbytes=recvfrom(sockfd, buf, MAXBUFLEN, 0,
				(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
		}
        buf[numbytes] = '\0';

		// PROCESS QUERIES FROM atmprocs.cc (user-coded function "send")

		char *ptr;
		ptr = strtok(buf,",");
		if( strcmp(ptr,"process") == 0 )
		{		
			ptr = strtok(NULL,",");
			transaction = atoi(ptr);
			ptr = strtok(NULL,",");
			card = atoi(ptr);
			ptr = strtok(NULL,",");
			pin = atoi(ptr);
			ptr = strtok(NULL,",");
			account = atoi(ptr);
			ptr = strtok(NULL,",");
			from = atoi(ptr);
			ptr = strtok(NULL,",");
			to = atoi(ptr);
			ptr = strtok(NULL,",");
			amount = atoi(ptr);
	
			/* send SQL query */
			sprintf(buf,"select * from CA where card=%d",card);
			if (mysql_query(conn, buf)) {
				fprintf(stderr, "%s\n", mysql_error(conn));
				exit(0);
			}
	
			res = mysql_use_result(conn);
	
			int dbchecking, dbsavings, dbpin;
			int pinStatus, approved;
			if ((row = mysql_fetch_row(res)) != NULL) {
				pinStatus = 1;
				approved = 1;	// assume all is good
				if( pin != atoi(row[2]) ) {
					pinStatus = 0; // invalid pin
				}
				if( transaction == 1 || transaction == 2 ) {
					//account 1 is checking
					if( (account == 1) && (amount > atoi(row[3]) )) {
						approved = 0; // over account balance	
					}
					// account 2 is savings
					else if( (account == 2) && (amount > atoi(row[4]) )) {	
						approved = 0;	// over account balance
					}
				}
				dbchecking = atoi(row[3]);
				dbsavings = atoi(row[4]);
				dbpin = atoi(row[2]);
	
				mysql_free_result(res);
				buf[0] = '\0';
				switch( transaction ) {
					case 1: //withdrawal
						if( approved )	
						{
							if( account == 1 ) // Checking
							{
								dbchecking -= amount;
								sprintf(buf,
										"update CA set Checking=%d where Card=%d",
										dbchecking,card);
							}
							else
							{
								dbsavings -= amount;
								sprintf(buf,
										"update CA set Savings=%d where Card=%d",
										dbsavings,card);
							}
							if (mysql_query(conn, buf)) {
    							fprintf(stderr, "%s\n", mysql_error(conn));
    							exit(0);
							}
						}
//						else
//							; // do nothing
						break;
					case 2: //transfer between savings and checking account
						if( approved )	
						{
							if (from == 1 && to == 2) 
							{
								dbchecking -= amount;
								dbsavings += amount;
							}
							else if (from == 2 && to == 1) 
							{
								dbchecking += amount;
								dbsavings -= amount;
							}
							else
							{
								printf("transfer problem\n");
								break;
							}							
							sprintf(buf,
									"update CA set Checking=%d where Card=%d",
									dbchecking,	card);
							if (mysql_query(conn, buf)) {
   								fprintf(stderr, "%s\n", mysql_error(conn));
   								exit(0);
							}
							sprintf(buf,
									"update CA set Savings=%d where Card=%d",
									dbsavings, card);
							if (mysql_query(conn, buf)) {
    							fprintf(stderr, "%s\n", mysql_error(conn));
    							exit(0);
							}
						}
						break;
					case 3: //deposit
						if( approved )	
						{
							if( account == 1 ) // Checking
							{
								dbchecking += amount;
								sprintf(buf,
										"update CA set Checking=%d where Card=%d",
										dbchecking,card);
							}
							else
							{
								dbsavings += amount;
								sprintf(buf,
										"update CA set Savings=%d where Card=%d",
										dbsavings+amount,card);
							}
							if (mysql_query(conn, buf)) {
    							fprintf(stderr, "%s\n", mysql_error(conn));
    							exit(0);
							}
						}
//						else
//							; // do nothing
						break;
					case 4: //inquiry
						break;
					default:
						printf("problemo");
				}
	
				sprintf(buf,"%d,%d,%d,%d",approved,pinStatus,dbpin,
						account==1?
							dbchecking:
							dbsavings);	
				if ((numbytes=sendto(sockfd, buf, strlen(buf), 0,
						(struct sockaddr *)&their_addr, 
						sizeof(struct sockaddr))) == -1) 
				{
					perror("sendto");
					exit(1);
				}
			}
			else
				printf("bad mysql read\n");			
		}
		else if(strcmp(ptr,"commit") == 0)
		{
			/* send SQL query */
			sprintf(buf,"commit");
			if (mysql_query(conn, buf)) {
				fprintf(stderr, "%s\n", mysql_error(conn));
				exit(0);
			}
		}
		else if(strcmp(ptr,"rollback") == 0)
		{
			/* send SQL query */
			sprintf(buf,"rollback");
			if (mysql_query(conn, buf)) {
				fprintf(stderr, "%s\n", mysql_error(conn));
				exit(0);
			}
		}
		else
		{
			printf("bank: Unexpected query from client: %s\n", ptr);
		}
	}	
		mysql_close(conn);	
	//close(sockfd);
	return 0;
}
