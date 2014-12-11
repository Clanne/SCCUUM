int main( void )
{
	int n ;
	int res ;
	int i ;
	n = 10 ;
	res = 1 ;
	i = 1 ;
	while( i <= n )
	{
		res = res * i ;
		++ i ;
	}
	printi( res );
	return 0 ;
}
