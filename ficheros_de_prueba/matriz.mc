matriz() {
    var int c, d, i, j;
    d = 10;
    c = 10;
    for(i = 0; i < c; i = i + 1)
    {
        for(j=0; j < d; j = j + 1)
        {
            if(j == i)
            {
                print("1 ");
            }
            else
            {
                print("0 ");
            }
        }
        print("\n");
    }
    print("\n");
}