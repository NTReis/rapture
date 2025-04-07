#!/bin/bash

#SBATCH --job-name=parallelization_engine    # Job name
#SBATCH --output="out.txt"                  # Standard output with job ID
#SBATCH --error="error.txt"                  # Standard error with job ID 
#SBATCH --cpus-per-task=128                  # Use all 128 AMD CPU threads
#SBATCH --nodes=1                            # Number of nodes
#SBATCH --time=00:20:00                      # Time limit hrs:min:sec
#SBATCH --mem=256G                           # Memory limit
#SBATCH --partition=normal-x86                    # Use AMD partition

# Clean up environment and load necessary modules
module purge
module load GCC/12.3.0
module load Boost/1.82.0-GCC-12.3.0
source /share/apps-x86/ohpc/pub/apps/intel/oneapi/setvars.sh

# Compile the code
echo "Compiling LockFree.cpp..."
g++ -g LockFree.cpp -O2 -ftree-vectorize -march=native -fno-math-errno -o engine -lpthread \
  -I$BOOST_ROOT/include -L$BOOST_ROOT/lib -DD_LOL


# Set the chunk size passed as parameter (default to 50 if not provided)
CHUNKSIZE=${1:-50}


# Check if input files exist
if [ ! -f 1workerDeuc.txt ] || [ ! -f tasksCM.txt ]; then
    echo "Warning: Input files not found. Make sure they exist in the current directory."
fi

# Run the executable with inputs
echo "Running engine with chunk size $CHUNKSIZE..."
./engine -f 1workerDeuc.txt tasksCM.txt << EOF
y
$CHUNKSIZE
EOF

echo "Job completed at $(date)"