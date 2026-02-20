#!/bin/bash

iverilog -g2012                  \
         ../fifo_tb.sv           \
         ../dff_fifo/fifo_dff.sv \
         ../sram_fifo/*          \
         ./*.sv                  \
         -DDUALPORT_LATENCY_5
vvp a.out
