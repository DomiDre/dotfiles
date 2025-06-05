#!/bin/sh

output=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits)

# Extract the numbers
gpu_util=$(echo $output | cut -d',' -f1 | xargs)
vram_used=$(echo $output | cut -d',' -f2 | xargs)
vram_total=$(echo $output | cut -d',' -f3 | xargs)

# Format output (e.g., "GPU: 37% VRAM: 2543/8192MB")
echo "${gpu_util}% ${vram_used}/${vram_total}MB"
