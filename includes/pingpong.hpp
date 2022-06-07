#pragma once
#include <vector>

#include <mpi.h>

#define REORDERING_BARRIER asm volatile("" ::: "memory");

/// Wrapper around MPI_Communicator and rank/size information
struct MPICtx {
  MPICtx(MPI_Comm comm) : comm{comm} {
    MPI_Comm_rank(comm, &rank);
    MPI_Comm_size(comm, &size);
  }
  MPICtx() : MPICtx(MPI_COMM_WORLD) {}

  MPI_Comm comm;
  int rank;
  int size;
};

double get_time();

/// starts actual benchmark
void run_ping_pong(std::vector<char>& send_recv, const MPICtx& comm);
