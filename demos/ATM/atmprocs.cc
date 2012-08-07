/*
 * atmprocs.cc
 * 
 * External action procedures, updated to V4.2
 */

#include <stdio.h> 
#include <stdlib.h> 
#include <string.h>
#include <strings.h>
#include <netdb.h> 

#include "Lit.h"
#include "List.h"
#include "Action.h"
#include "ucsp_iostream.h"

using ucsp::cout;
using ucsp::cin;
using ucsp::endl;

#define THEIRPORT 4950		/* the port we will be sending to */
#define MYPORT 4951		/* the port we will be receiving from */

#define MAXBUFLEN 100

int sockfd;
struct sockaddr_in their_addr;  /* their address information */
struct hostent *he;
struct sockaddr_in my_addr;	/* our address information */
socklen_t addr_len;
int numbytes;
char buf[MAXBUFLEN];
char thehost[] = "127.0.0.1";


int transaction, card, pin, account, from, to, amount;

void machcash_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--mashcash--" << endl;
	int machcash;
	cout << "Operator, how much cash will the machine hold?" << endl;
	cout << "Please enter the amount -> ";
	cin >> machcash;
	*v = Lit(machcash);	// this is the input val
}

void insertcard_atomic( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--insertcard--" << endl;
	cout << "...listening and waiting for card to be inserted" << endl;
	/*
	 * put sensor wait here
	 */
	cout << "Card Inserted" << endl;
}

void readcard_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--readcard--" << endl;
	int cardnumber;
	cout << "Please enter your Card number -> ";
	cin >> cardnumber;
	*v = Lit(cardnumber);	// this is the input val
}

void readpin_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--readpin--" << endl;
	int pinnumber;
	cout << "Welcome to the CSP++ ATM" << endl;
	cout << "Please enter your PIN -> ";
	cin >> pinnumber;
	*v = Lit(pinnumber);	// this is the input val
}

void choose_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--choose--" << endl;
	int menu;
	cout << "What type of transaction would you like to do?" << endl;
	cout << "\n1) Cash Withdrawal\n2) Transfer\n3) Deposit\n4) Account Balance\n" << endl;
	cout << "Please enter your choice -> ";
	cin >> menu;
	*v = Lit(menu);	// this is the input val
}

void getacct_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--getacct--" << endl;
	int account;
	cout << "Which account would you like to use?" << endl;
	cout << "\n1) Checking\n2) Savings\n\n" << endl;
	cout << "Please enter your choice -> ";
	cin >> account;
	*v = Lit(account);	// this is the input val
}

void getamnt_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--getamnt--" << endl;
	int amount;
	cout << "Please enter the amount -> ";
	cin >> amount;
	/*
	 * note: this machine will allow any amount (not just multiples of $20 for withdrawals)
	 */
	*v = Lit(amount);	// this is the input val
}

void getfrom_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--getfrom--" << endl;
	int from;
	cout << "Which account would you like to transfer from?" << endl;
	cout << "\n1) Checking\n2) Savings\n\n" << endl;
	cout << "Please enter your choice -> ";
	cin >> from;
	*v = Lit(from);	// this is the input val
}

void getto_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--getto--" << endl;
	int to;
	cout << "Which account would you like to transfer to?" << endl;
	cout << "\n1) Checking\n2) Savings\n\n" << endl;
	cout << "Please enter your choice -> ";
	cin >> to;
	*v = Lit(to);	// this is the input val
}

void banksend_chanOutput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	if ((he=gethostbyname(thehost)) == NULL) {	/* get the host info */
		herror("gethostbyname");
		exit(1);
	}

	if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
		perror("socket");
		exit(1);
	}

	their_addr.sin_family = AF_INET;			/* host byte order */
	their_addr.sin_port = htons(THEIRPORT);	/* short, network byte order */
	their_addr.sin_addr = *((struct in_addr *)he->h_addr);
	bzero(&(their_addr.sin_zero), 8);		 /* zero the rest of the struct */

	// unpack the 7 elements of l's list of Lits
	Listiter<Lit> temp( *(l->getList()) );
	transaction = (temp.forward_iter(), (int)temp.get_cur());
	card = 	(temp.forward_iter(), (int)temp.get_cur());
	pin = 	(temp.forward_iter(), (int)temp.get_cur());
	account = (temp.forward_iter(), (int)temp.get_cur());
	from = 	(temp.forward_iter(), (int)temp.get_cur());
	to = 	(temp.forward_iter(), (int)temp.get_cur());
	amount = (temp.forward_iter(), (int)temp.get_cur());

	if( transaction == 2) // transfer
		account = from;

	sprintf(buf,"process,%d,%d,%d,%d,%d,%d,%d",
			transaction,card,pin,account,from,to,amount);

	if ((numbytes=sendto(sockfd, buf, strlen(buf), 0, 
			(struct sockaddr *)&their_addr, sizeof(struct sockaddr))) == -1) 
	{
		perror("sendto");
		exit(1);
	}
}

void bankstatus_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	addr_len = sizeof(struct sockaddr);
	if ((numbytes=recvfrom(sockfd, buf, MAXBUFLEN, 0,	\
			(struct sockaddr *)&their_addr, &addr_len)) == -1) 
	{
		perror("recvfrom");
		exit(1);
	}
	buf[numbytes] = '\0';

	// Create a datum to return to the CSP backbone
	DatumID tempID = "bankstatus_d";
	char *ptr;
	ptr = strtok(buf,",");
	Lit a1 = Lit(atoi(ptr));
	ptr = strtok(NULL,",");
	Lit a2 = Lit(atoi(ptr));
	ptr = strtok(NULL,",");
	Lit a3 = Lit(atoi(ptr));
	ptr = strtok(NULL,",");
	Lit a4 = Lit(atoi(ptr));

	*v = Lit(tempID, new List<Lit>(a1,a2,a3,a4) );	// this will be the value given to the channel input
}

void commit_atomic( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	sprintf(buf,"commit"); 

	if ((numbytes=sendto(sockfd, buf, strlen(buf), 0, \
			 (struct sockaddr *)&their_addr, sizeof(struct sockaddr))) == -1)
	{
		perror("sendto");
		exit(1);
	}

//	close(sockfd);
}

void rollback_atomic( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	sprintf(buf,"rollback"); 

	if ((numbytes=sendto(sockfd, buf, strlen(buf), 0,
			 (struct sockaddr *)&their_addr, sizeof(struct sockaddr))) == -1)
	{
		perror("sendto");
		exit(1);
	}

//	close(sockfd);
}

void again_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--again--" << endl;
	int yesorno;
	cout << "Would you like to make another transaction (0 - NO, 1 - YES) -> ";
	cin >> yesorno;
	*v = Lit(yesorno);	// this is the input val
}

void startenv_atomic( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--startenv--" << endl;
	cout << "Please insert your envelope" << endl;
}

void insertenv_atomic( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--insertenv--" << endl;
	cout << "Envelope inserted. Thankyou." << endl;
}

void exceedsMch_atomic( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--exceedsMch--" << endl;
	cout << "Sorry, there is not enough money in the machine to meet your withdrawal request." << endl;
}

void dispense_chanOutput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--dispense--" << endl;
	cout << "Dispensing $" << *l << endl;
}

void readnewpin_chanInput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--readnewpin--" << endl;
	int pinnumber;
	cout << "Try entering the correct PIN -> ";
	cin >> pinnumber;
	*v = Lit(pinnumber);	// this is the input val
}

void sameacct_atomic( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--sameacct--" << endl;
	cout << "Error, you are transfering to the same account. Please choose your accounts again." << endl;
}

void display_chanOutput( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--display--" << endl;
	cout << "The balance in your " << (account == 1 ? "Checking" : "Savings") << " account is $" << *l << endl;
}

void cancel_atomic( ActionType t, ActionRef* a, Var* v, Lit* l )
{
	cout << "--cancel--" << endl;
	cout << "Will you cancel?" << endl;
}
