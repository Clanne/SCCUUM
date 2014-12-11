int main( void )
{
	int n = 10 , i = 1 , res = 1 ;

	while( i <= n )
	{
		res = res * i ;
		++ i ;
	}

	printi( res );
	return 0 ;
}
