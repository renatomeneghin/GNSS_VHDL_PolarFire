# Use the following syntax to add clock constraints
create_clock -name {CLK} -period 2.5 -waveform {0 1.25 } -add  [ get_ports { CLK } ]
create_clock -name {SLOWCLK} -period 10.0 -waveform {0 5.0 } -add  [ get_ports { SLOWCLK } ] 
# for streaming SLOWCLK freq. expected to be as divide by 4 of CLK
#create_clock -name {SLOWCLK} -period 20.0 -waveform {0 10.0 } -add  [ get_ports { SLOWCLK } ] # for Native SLOWCLK freq. expected to be as divide by 8 of CLK

# SLOWCLK, CLK boundaries are properly synchronized in the logic and false path timing exception need to be addeed as follows
set_false_path -from [ get_clocks { SLOWCLK } ] -to [ get_clocks { CLK } ]  
set_false_path -from [ get_clocks { CLK } ] -to [ get_clocks { SLOWCLK } ] 

#Note: The source clock name used in the above examples are for reference only. The source name may be different in your design and you must change the clock name in the constraint accordingly.


# For the streaming configuration the MCP is needed for the following paths to get proper timing
#Note:AXI4S handshaking input ports must be added for false path exception
#Synplify_pro_constrains of MCP 2 for the paths 
#i:COREFFT_C0_0.stream_native\.stream_unit_native.bitrev_0.reverse_bits\.wA_0.count[11:0]   to i:COREFFT_C0_0.stream_native\.stream_unit_native.bitrev_0.ovflow_latch
#i:COREFFT_C0_0.stream_native\.stream_unit_native.bitrev_0.reverse_bits\.wA_0.count[11:0]   to i:COREFFT_C0_0.stream_native\.stream_unit_native.bitrev_0.pong_read
#i:COREFFT_C0_0.stream_native\.stream_unit_native.bitrev_0.reverse_bits\.wA_0.count[11:0]   to i:COREFFT_C0_0.stream_native\.stream_unit_native.bitrev_0.reverse_bits\.rA_0.count[11:0]
#i:COREFFT_C0_0.stream_native\.stream_unit_native.radix22_section\.5\.radix2_1.sel_tick   to i:COREFFT_C0_0.stream_native\.stream_unit_native.radix22_section\.5\.radix2_1.pipe_difre_0.genDel\.delayLine_0[29:0]
