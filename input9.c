int main ()
{
	int i;

	for (i = 0; i < 10; i = i + 1)
	{
		{
			int a;
			a = a + i;
		}
		a = 2;
	}

	return 0;
}
