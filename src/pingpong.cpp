#include "pingpong.hpp"

// is in extra cpp file to avoid code reordering
void run_ping_pong(std::vector<char>& send_recv, const MPICtx& comm) {
  int tag = 444;
  if (comm.rank == 0) {
    MPI_Send(send_recv.data(), send_recv.size(), MPI_CHAR, 1, tag, comm.comm);
  } else {
    MPI_Recv(send_recv.data(), send_recv.size(), MPI_CHAR, 0, tag, comm.comm,
             MPI_STATUS_IGNORE);
  }
  if (comm.rank != 0) {
    MPI_Send(send_recv.data(), send_recv.size(), MPI_CHAR, 0, tag, comm.comm);
  } else {
    MPI_Recv(send_recv.data(), send_recv.size(), MPI_CHAR, 1, tag, comm.comm,
             MPI_STATUS_IGNORE);
  }
}
