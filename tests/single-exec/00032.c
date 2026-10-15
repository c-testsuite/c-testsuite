int
main()
{
	int arr[3];
	int *p;
	
	arr[1] = 2;
	arr[2] = 3;
	p = &arr[1];
	if(*(p++) != 2)
		return 1;
	if(*(p++) != 3)
		return 2;
	
	p = &arr[2];
	if(*(p--) != 3)
		return 1;
	if(*(p--) != 2)
		return 2;
		
	p = &arr[1];
	if(*(++p) != 3)
		return 1;
	
	p = &arr[2];
	if(*(--p) != 2)
		return 1;

	return 0;
}
