int wow (int a, float b)
{
	int ret;
	ret = 0;
	if (a == 2)
	{
		ret = b + 1;
	}
	
	return ret;
}

int main ()
{
	wow (10, 1.2);
	return 0;
}
