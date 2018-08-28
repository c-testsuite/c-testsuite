/*
 *  Disgusting, no?  But it compiles and runs just fine.  I feel a
 *  combination of pride and revulsion at this discovery.  If no one's
 *  thought of it before, I think I'll name it after myself.  It amazes
 *  me that after 10 years of writing C there are still little corners
 *  that I haven't explored fully.
 *  - Tom Duff
 */
send(to, from, count)
        register short *to, *from;
        register count;
{
        register n=(count+7)/8;
        switch(count%8){
        case 0:      do{*to = *from++;
        case 7:           *to = *from++;
        case 6:           *to = *from++;
        case 5:           *to = *from++;
        case 4:           *to = *from++;
        case 3:           *to = *from++;
        case 2:           *to = *from++;
        case 1:           *to = *from++;
                            }while(--n>0);
        }
}

int
main()
{
	short a, b[40];

	send(&a, b, 40);

	return (a == b[39]) ? 0 : 1;
}
