/*gcc poisson.c /usr/lib/libgsl.a /usr/lib/libm.a -o poisson.exe */

#include <stdio.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_rng.h>
#include <math.h>

int
main (int argc, char *argv[])
{
  if(argc < 2){
    printf("print probability of obtaining N from poisson distribution\n");
    printf("usage:  poisson.exe mean N\n");
    return 1;
  }


  const gsl_rng_type * T;
  gsl_rng * r;
	
  int billion = 1000000000;
  int i, n = billion;

  double mean = atof(argv[1]);
  unsigned int found = atoi(argv[2]);

  double prob = gsl_ran_poisson_pdf(found,mean);
  printf("probability %f of getting %d from mean %f\n",prob,found,mean);

  double totalprob = 0.0;
  for(i=0; i<found; i++){
    totalprob += gsl_ran_poisson_pdf(i,mean);
  }
  printf("probability %f of getting < %d from mean %f\n",
	 totalprob,found,mean);
  printf("probability %f of getting >= %d from mean %f\n",
	 1.0-totalprob,found,mean);
  

  /*
  gsl_rng_env_setup();

  T = gsl_rng_default;
  r = gsl_rng_alloc (T);

  for (i = 0; i < n; i++) 
    {
      double u = gsl_rng_uniform (r);
      if(i > billion-5) printf("%.5f\n", u);
    }

  gsl_rng_free (r);
  */
  return 0;
}
