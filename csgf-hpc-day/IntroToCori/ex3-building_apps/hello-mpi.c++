#include <iostream>
#include <mpi.h>
using namespace std;

int main(int argc, char**argv)
{
  // do a vectorised loop:
  int myid, p, ierr;

  ierr = MPI_Init(&argc,&argv);          /* starts MPI */
  MPI_Comm_rank(MPI_COMM_WORLD, &myid);  /* get current process id */
  MPI_Comm_size(MPI_COMM_WORLD, &p);     /* get number of processes */

  cout << "Hello world from process " << myid << " of " << p << endl; 
  MPI_Finalize();                       /* let MPI finish up ... */
  return 0;
}
