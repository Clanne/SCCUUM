int main( void )
{
	int n = 10 ;
	int tmp , fib2 = 1 , fib1 = 1 , i ;

	for( i = 1 ; i < n ; i = i + 1 )
	{
		tmp = fib1 ;
		fib1 = fib2 ;
		fib2 = fib2 + tmp ;
	}

	printi( fib2 ) ;
	
	return 0 ;
}
