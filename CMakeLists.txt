cmake_minimum_required(VERSION 3.10)

project(PingPongBench)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(MPI REQUIRED)
add_subdirectory(external/tlx)

set(sources ${sources}
  ${CMAKE_SOURCE_DIR}/src/pingpong.cpp
  ${CMAKE_SOURCE_DIR}/src/timer.cpp
  )

add_executable(pingpong benchmark/pingpong_benchmark.cpp ${sources})
target_compile_options(pingpong PRIVATE -O3 -march=native)
target_include_directories(pingpong PRIVATE ${CMAKE_SOURCE_DIR}/includes)
target_link_libraries(pingpong PRIVATE MPI::MPI_CXX tlx)

