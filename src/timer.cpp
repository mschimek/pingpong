#include "pingpong.hpp"

double get_time() {
  REORDERING_BARRIER
  const double time = MPI_Wtime();
  REORDERING_BARRIER
  return time;
}
