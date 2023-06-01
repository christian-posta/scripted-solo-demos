# Requirements

Clang:
sudo apt install clang-9 --install-suggests

sudo ln -s /usr/bin/clang-9 /usr/bin/clang

sudo apt install libbpf-dev



## Install bpftools:
# https://github.com/lizrice/lb-from-scratch/issues/1

apt update && apt install -y file libbpf-dev make build-essential git

cd / && git clone --recurse-submodules https://github.com/libbpf/bpftool.git

cd bpftool/src

make install

ln -s /usr/local/sbin/bpftool /usr/sbin/bpftool


## Show all bfp prog

bpftool prog list  


## Show Cilium bpf 

bpftool prog list | grep cil_