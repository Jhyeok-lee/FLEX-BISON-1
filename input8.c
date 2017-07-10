int set_zero_i (int num[4])
{
	int i;

	for (i = 0; i < 4; i = i + 1) 
	{
		num[i] = 0;
	}

	return i;
}

int set_zero_f (float num[4])
{
	int i;

	for (i = 0; i < 4; i = i + 1)
	{
		num[i] = 0.0;
	}

	return i;
}

int main ()
{
	float input[500];
	float means[4];
	float new_means[4];
	int num[4];
	int i, j, k;

	k = 0;
	while (k < 10000)
	{
		set_zero_i (num);
		set_zero_f (new_means);

		for (i = 0; i < 500; i = i + 1) 
		{
			float less;
			int idx;
			less = 1000.0;
			idx = -1;
	
			for (j = 0; j < 4; j = j + 1) 
			{
				float tmp;
				tmp = input[i] - means[j];
				if (tmp < 0)
				{
					tmp = tmp * -1.0;
				}
				if (less > tmp)
				{
					float one;
					one = 1;
					less = tmp * one;
					idx = j;
				}
			}
			new_means[idx] = new_means[idx] + input[i];
			num[idx] = num[idx] + 1;
		}
		i = 0;
		while (i < 4)
		{
			means[i] = new_means[i] / num[i];
			i = i + 1;
		}
		k = k + 1;
	}

	i = 0;
	while (i < 4)
	{
		int cat;
		cat = 1;
		means[i] = new_means[i] / num[i] * cat;
		i = i + 1;
	}

	return 0;
}
