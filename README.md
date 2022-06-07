# pingpong benchmark

## compilation

```bash
cmake -B build
cmake --build build --parallel
```

## usage
```bash
mpiexec -n 2 ./build/pingpong --help
```

## notes
The actual benchmark can be found in `benchmark/pingpong_benchmark.cpp`.
