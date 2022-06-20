#include <algorithm>
#include <iostream>
#include <random>
#include <vector>

#include <mpi.h>
#include "tlx/cmdline_parser.hpp"

#include "pingpong.hpp"

/// bundles parameters for the experiment
struct ExperimentConfig {
  std::size_t num_bytes_start = 1;    /// first message length to be sent
  std::size_t num_bytes_stop = 1000;  /// last message length to be sent
  std::size_t step_size =
      10;  /// additional constant by which the message length will be increased
  std::size_t num_iterations = 5;
  std::string id = "ompi";
};

/// generate data which can be sent (use a constant value instead randomly
/// generated value should currently also be fine)
std::vector<char> gen_data(std::size_t num_elements) {
  std::mt19937 gen(5);
  std::uniform_int_distribution<char> distrib(-128, 127);
  std::vector<char> data;
  std::generate_n(std::back_inserter(data), num_elements,
                  [&]() { return distrib(gen); });
  return data;
}

/// outer loop for the ping pong benchmark. The actual call to MPI_Send/MPI_Recv
/// is in another compilation unit to prevent reordering.
void run_ping_pong(std::size_t num_elements, std::size_t num_iterations,
                   MPICtx comm, const std::string& id) {
  const std::vector<char> data =
      comm.rank == 0 ? gen_data(num_elements) : std::vector<char>(num_elements);
  std::vector<double> durations(num_iterations);
  for (std::size_t i = 0; i < num_iterations; ++i) {
    auto send_recv = data;
    // MPI_Barrier(comm.comm);
    REORDERING_BARRIER
    double time_start = get_time();
    REORDERING_BARRIER

    run_ping_pong(send_recv, comm);

    REORDERING_BARRIER
    double time_stop = get_time();
    REORDERING_BARRIER
    // MPI_Barrier(comm.comm);
    const double time_in_ns = (time_stop - time_start) * 1'000'000'000;
    durations[i] = time_in_ns;

    // MPI_Barrier(comm.comm);
  }
  if (comm.rank == 0) {
    for (std::size_t i = 0; i < num_iterations; ++i) {
      std::cout << "RESULT iteration=" << i << " num_bytes=" << num_elements
                << " time=" << durations[i] << " id=" << id << std::endl;
    }
  }
}

void run_ping_pong(const ExperimentConfig& config) {
  MPICtx comm;
  if (comm.rank == 0) {
    std::cout << "Resolution of WTime: " << MPI_Wtick() << std::endl;
  }
  for (std::size_t i = config.num_bytes_start; i < config.num_bytes_stop;
       i += config.step_size) {
    run_ping_pong(i, config.num_iterations, comm, config.id);
  }
}

int main(int argc, char* argv[]) {
  MPI_Init(nullptr, nullptr);
  ExperimentConfig config;
  tlx::CmdlineParser cp;
  cp.set_description("ping pong benchmark");
  cp.set_author("Matthias Schimek");
  cp.add_size_t("iterations", config.num_iterations,
                "number of iterations to perform");
  cp.add_size_t("num_bytes_start", config.num_bytes_start,
                "start value for number of bytes to send");
  cp.add_size_t("num_bytes_stop", config.num_bytes_stop,
                "end value for number of bytes to send");
  cp.add_size_t("stepsize", config.step_size, "stepsize");
  cp.add_string("id", config.id,
                "id tag to differentiate between multiple setups");
  cp.process(argc, argv);
  MPI_Barrier(MPI_COMM_WORLD);
  MPICtx ctx;
  if (ctx.size != 2) {
    std::cout << "not exactly 2 PEs in total -> abort!" << std::endl;
    MPI_Abort(ctx.comm, 1);
  }
  run_ping_pong(config);
  MPI_Finalize();
}
