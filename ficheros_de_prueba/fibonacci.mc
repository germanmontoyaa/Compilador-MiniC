fibonacci() {
	var int n,N,a,b,c;
	print("Introduce una n:"  );
	read(N);
	n = 2;
	c = 0;
	b = 1;
	for(n = 1; n < N; n = n + 1)
	{
		a = b + c;
		c = b;
		b = a;
	}
	/*
	Esto es un comentario
	*/
	//esto es otro
	print( a, "\n");
}