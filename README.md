# SRAM FIFO example repository

This repository contains examples of SRAM based FIFO approaches.

## Exercise

Implement a FIFO based on pipelined SRAM behavioural model. Write your
implementation in `fifo_dualport_with_pipelined_sram`, then you can run a script
`run_tb.sh` to check your solution. If you are on Windows, just copy 2 commands
from the script to the terminal.

Bevare that by default testbench only runs 1000 tests. Such complicated FIFO design
might hide issues that are not covered by that basic test. I suggest to increase
that number to 1 000 000 to make sure that it *most likely* works correctly.

And if you want to *really* make sure that everything works, run formal verification
with `sby -f fifo_formal_check.sby bmc cover prove`. You'll have to change line
18 of `fifo_formal_check.sby` from `read -define DUALPORT` to
`read -define DUALPORT_LATENCY_5`.

Note that probably it won't be fast.

P.S. I suggest installing SBY and needed formal engines with
[OSS-CAD-SUITE](https://github.com/YosysHQ/oss-cad-suite-build).
