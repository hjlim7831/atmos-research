#include<stdio.h>
#include<string.h>
#include<math.h>
#include<stdlib.h>
#include<omp.h>

#define SIZE 20
#define STEP 0.02
#define ITERATION 20

// SCALE : dx, dy
#define SCALE 0.2
#define END 0.4
#define FORCE_RANGE 5

struct position
{
	double x;
	double y;
};

double p[SIZE][SIZE];
double u[SIZE][SIZE];
double v[SIZE][SIZE];
double ptmp[SIZE][SIZE];
double utmp[SIZE][SIZE];
double vtmp[SIZE][SIZE];


//advecting tracer
double r[SIZE][SIZE];
double rtmp[SIZE][SIZE];

void advect()
{
	int i,j;
	int x,y;
	double a,b;
	double dx,dy;
	struct position pos;
	
#pragma omp parallel for private(x,y,a,b,dx,dy,pos)
	for(i=1;i<SIZE-1;i++)
	{
		for(j=1;j<SIZE-1;j++)
		{
				pos.x=(double)i-u[i][j]*STEP/SCALE;
				pos.y=(double)j-v[i][j]*STEP/SCALE;
				x=(int)pos.x;
				y=(int)pos.y;
				dx=(pos.x-x);
				dy=(pos.y-y);

				a=dx*(u[x+1][y]-u[x][y])+u[x][y];
				b=dx*(u[x+1][y+1]-u[x][y+1])+u[x][y+1];
				utmp[i][j]=dy*(b-a)+a;

				a=dx*(v[x+1][y]-v[x][y])+v[x][y];
				b=dx*(v[x+1][y+1]-v[x][y+1])+v[x][y+1];
				vtmp[i][j]=dy*(b-a)+a;

				a=dx*(r[x+1][y]-r[x][y])+r[x][y];
				b=dx*(r[x+1][y+1]-r[x][y+1])+r[x][y+1];
				rtmp[i][j]=dy*(b-a)+a;
		}
	}
	for(i=0;i<SIZE;i++)
	{
		for(j=0;j<SIZE;j++)
		{
				r[i][j]=rtmp[i][j];
		}
	}
	printf("%.16lf ",r[10][10]);


// velocity boundary condition
	for(i=1;i<SIZE-1;i++)
	{
			utmp[i][0]=-utmp[i][1];
			vtmp[i][0]=-vtmp[i][1];
			utmp[i][SIZE-1]=-utmp[i][SIZE-2];
			vtmp[i][SIZE-1]=-vtmp[i][SIZE-2];
	}
	for(j=0;j<SIZE;j++)
	{
			utmp[0][j]=-utmp[1][j];
			vtmp[0][j]=-vtmp[1][j];
			utmp[SIZE-1][j]=-utmp[SIZE-2][j];
			vtmp[SIZE-1][j]=-vtmp[SIZE-2][j];
	}
}

void add_force()
{
	int i,j;
	double f=10;
	
		for(j=SIZE/2-FORCE_RANGE;j<SIZE/2+FORCE_RANGE;j++)
		{
			for(i=SIZE/2;i<SIZE/2+FORCE_RANGE;i++)
			{
				utmp[i][j]+=STEP*f;
			}
			for(i=SIZE/2-FORCE_RANGE;i<SIZE/2;i++)
			{
				utmp[i][j]+=STEP*f;
			}
		}
// additional
	  for(i=0;i<SIZE;i++)
  {
  	  for(j=0;j<SIZE;j++)
    {
        u[i][j]=utmp[i][j];
    }
  }


}


void solve_poisson()
{
	int i,j,t;
	double b;

	for(t=0;t<ITERATION;t++)
	{
#pragma omp parallel for private(b)
		for(i=1;i<SIZE-1;i++)
		{
			for(j=1;j<SIZE-1;j++)
			{
					b=(utmp[i+1][j]-utmp[i-1][j])/(2*SCALE)+(vtmp[i][j+1]-vtmp[i][j-1])/(2*SCALE);
					ptmp[i][j]=(p[i+1][j]+p[i-1][j]+p[i][j+1]+p[i][j-1]-SCALE*SCALE*b)/4.0;
			}
		}
	
    // boundary condition for pressure
		for(i=1;i<SIZE-1;i++)	
		{
				ptmp[i][0]=ptmp[i][1];
				ptmp[i][SIZE-1]=ptmp[i][SIZE-2];
		}
		for(j=0;j<SIZE;j++)
		{
				ptmp[0][j]=ptmp[1][j];		
				ptmp[SIZE-1][j]=ptmp[SIZE-2][j];
		}
		
    // update pressure
		for(i=0;i<SIZE;i++)
		{
			for(j=0;j<SIZE;j++)
			{
					p[i][j]=ptmp[i][j];
			}
		}
	}
	printf("%.16lf\n",p[10][10]);
}

void subtract_pressure_gradient()
{
	int i,j;

	for(i=1;i<SIZE-1;i++)
	{
		for(j=1;j<SIZE-1;j++)
		{
				u[i][j]=utmp[i][j]-(ptmp[i+1][j]-ptmp[i-1][j])/(2*SCALE);
				v[i][j]=vtmp[i][j]-(ptmp[i][j+1]-ptmp[i][j-1])/(2*SCALE);
		}
	}

// velocity boundary condition
	for(i=1;i<SIZE-1;i++)
	{
			u[i][0]=-u[i][1];
			v[i][0]=-v[i][1];
			u[i][SIZE-1]=-u[i][SIZE-2];
			v[i][SIZE-1]=-v[i][SIZE-2];
	}
	for(j=0;j<SIZE;j++)
	{
			u[0][j]=-u[1][j];
			v[0][j]=-v[1][j];
			u[SIZE-1][j]=-u[SIZE-2][j];
			v[SIZE-1][j]=-v[SIZE-2][j];
	}
}

void render(char *filename)
{
	int i,j,n1,n2,n3;
	FILE *fp=fopen(filename,"w");         // Write image to PPM file.
	fprintf(fp, "P3\n%d %d\n%d\n", SIZE, SIZE, 255);
	for(j=0;j<SIZE;j++)
	{
		for(i=0;i<SIZE;i++)
		{
			n1=(int)(r[i][j]*255);
			n2=(int)(r[i][j]*255);
			n3=(int)(r[i][j]*255);
			fprintf(fp,"%d %d %d ",n1,n2,n3);
		}
	}
	fclose(fp);
}

main()
{
	int i,j,k,a;
	int num;
	char str2[10];
	double t;


	// initial condition
	for(i=0;i<SIZE;i++)
	{
		for(j=0;j<SIZE;j++)
		{
				p[i][j]=pow(10.0,5);
				u[i][j]=(double)i/10.0;
				v[i][j]=(double)i/10.0;
				r[i][j]=0.0;
		}
	}
	for(i=SIZE/2-FORCE_RANGE;i<SIZE/2;i++)
	{
		for(j=SIZE/2-FORCE_RANGE;j<SIZE/2+FORCE_RANGE;j++)
		{
				r[i][j]=1.0;
		}
	}

	a=0;
	num=1;
	for(t=STEP;t<=END;t+=STEP)
	{
		advect();
		add_force();
		solve_poisson();
//		subtract_pressure_gradient();

		// make figure
		if(a>=5)
		{
			sprintf(str2,"%03d",num);
			strcat(str2,".ppm");
			render(str2);
			printf("%d  %.2lf\n",num,t);
			a=0;
			num++;
		}
		a++;
	}
}
