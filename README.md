## Here are the commands to run the project:
### GUI Waveform: 
~~~

../../launch_cadence_xrun.sh -v93 -top cache_tb and2.vhd and3.vhd and4.vhd and5.vhd or2.vhd or3.vhd or7.vhd nor2.vhd xnor2.vhd inverter.vhd mux2to1.vhd mux2to1_2bit.vhd mux4to1.vhd decoder2to4.vhd tri_buffer.vhd dff.vhd dlatch.vhd tx.vhd latch_at_negedge.vhd latch_cache_address.vhd latch_cache_data.vhd latch_rd_wr.vhd select_write_data.vhd byte_selector.vhd cache_cell.vhd cache_block.vhd cache_array.vhd fsm_states.vhd set_curr_state.vhd set_curr_states.vhd cache_fsm.vhd cache.vhd cache_tb.vhd -gui -access rwc

~~~
### No GUI Waveform:
~~~

../../launch_cadence_xrun.sh -v93 -top cache_tb and2.vhd and3.vhd and4.vhd and5.vhd or2.vhd or3.vhd or7.vhd nor2.vhd xnor2.vhd inverter.vhd mux2to1.vhd mux2to1_2bit.vhd mux4to1.vhd decoder2to4.vhd tri_buffer.vhd dff.vhd dlatch.vhd tx.vhd latch_at_negedge.vhd latch_cache_address.vhd latch_cache_data.vhd latch_rd_wr.vhd select_write_data.vhd byte_selector.vhd cache_cell.vhd cache_block.vhd cache_array.vhd fsm_states.vhd set_curr_state.vhd set_curr_states.vhd cache_fsm.vhd cache.vhd cache_tb.vhd -input ncsim.run -access rwc

~~~

### Link to Public Github Repo for Easy File Download
~~~
https://github.com/RichardLu5647/cmpe413_final.git
~~~

### Testbenches
cache_cell_tb is the testbench for the cache cell.\
cache_block_tb is the testbench for the cache block.\
cache_array_tb is the testbench for the cache array.\
cache_tb is the testbench for the full cache implementation.\
cache_tb is also the test bench for cache_fsm because the cache_tb\
heavily relies on the functionality of the fsm. And cache_tb simulates\ 
fsm inputs aswell.
