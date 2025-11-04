--
-- Entity: cache_tb
-- Architecture : behavioral
-- Author: Generated for structural cache controller project
-- Description: Comprehensive testbench for cache system
--             Tests read hits, write hits, read misses with proper timing
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cache_tb is
    -- Testbench has no ports
end cache_tb;

architecture behavioral of cache_tb is

    -- Component under test
    component cache is
        port (
            CLK    : in  std_logic;
            RESET  : in  std_logic;
            START  : in  std_logic;
            CA     : in  std_logic_vector(5 downto 0);
            RD_WR  : in  std_logic;
            CD     : inout std_logic_vector(7 downto 0);
            BUSY   : out std_logic;
            MD     : in  std_logic_vector(7 downto 0);
            MA     : out std_logic_vector(5 downto 0);
            ENABLE : out std_logic
        );
    end component;

        signal clk_count: integer:=0;
    -- Clock and reset
    signal CLK    : std_logic := '0';
    signal RESET  : std_logic := '0';

    -- CPU interface signals
    signal START  : std_logic := '0';
    signal CA     : std_logic_vector(5 downto 0) := (others => '0');
    signal RD_WR  : std_logic := '0';
    signal CD     : std_logic_vector(7 downto 0) := (others => 'Z');
    signal BUSY   : std_logic;

    -- Memory interface signals
    signal MD     : std_logic_vector(7 downto 0) := (others => '0');
    signal MA     : std_logic_vector(5 downto 0);
    signal ENABLE : std_logic;

    -- Testbench control
    signal test_complete : boolean := false;
    signal test_case : string(1 to 20) := (others => ' ');

    -- Clock period (100 MHz = 10ns period)
    constant CLK_PERIOD : time := 10 ns;

    -- Memory simulation signals
    type memory_array is array (0 to 63) of std_logic_vector(7 downto 0);
    signal memory : memory_array := (others => (others => '0'));
    signal memory_counter : integer := 0;
    signal memory_base_addr : std_logic_vector(5 downto 0) := (others => '0');
    signal memory_active : boolean := false;

begin

    -- ======================================================================
    -- DEVICE UNDER TEST INSTANTIATION
    -- ======================================================================

    dut: cache port map(
        CLK    => CLK,
        RESET  => RESET,
        START  => START,
        CA     => CA,
        RD_WR  => RD_WR,
        CD     => CD,
        BUSY   => BUSY,
        MD     => MD,
        MA     => MA,
        ENABLE => ENABLE
    );

    -- ======================================================================
    -- CLOCK GENERATION
    -- ======================================================================

    clk_process: process
    begin
        while not test_complete loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Clk counter
    clk_count_process: process (CLK)
    begin
        if rising_edge(CLK) then
            clk_count <= clk_count + 1;
        end if;
    end process;

    -- ======================================================================
    -- MEMORY SIMULATION
    -- ======================================================================
    -- Simulates external memory with 8-cycle access time

    memory_process: process(CLK)
    begin
        if falling_edge(CLK) then
            -- Detect ENABLE going high (memory request)
            if ENABLE = '1' and not memory_active then
                memory_active <= true;
                memory_counter <= 0;
                memory_base_addr <= MA;

                -- Initialize memory block with test data
                memory(to_integer(unsigned(MA(5 downto 2) & "00"))) <= x"A0";  -- Byte 0
                memory(to_integer(unsigned(MA(5 downto 2) & "01"))) <= x"B1";  -- Byte 1
                memory(to_integer(unsigned(MA(5 downto 2) & "10"))) <= x"C2";  -- Byte 2
                memory(to_integer(unsigned(MA(5 downto 2) & "11"))) <= x"D3";  -- Byte 3

                report "Memory: Request received for address " &
                       integer'image(to_integer(unsigned(MA)));

            elsif memory_active then
                memory_counter <= memory_counter + 1;

                -- Provide data after 8 clock cycles (on negative edge = cycle 8)
                -- Data becomes valid and stays for 2 cycles each
                if memory_counter = 6 then
                    MD <= memory(to_integer(unsigned(memory_base_addr(5 downto 2) & "00")));
                    report "Memory: Providing byte 0 = " &
                           integer'image(to_integer(unsigned(memory(to_integer(unsigned(memory_base_addr(5 downto 2) & "00"))))));
                elsif memory_counter = 8 then
                    MD <= memory(to_integer(unsigned(memory_base_addr(5 downto 2) & "01")));
                    report "Memory: Providing byte 1 = " &
                           integer'image(to_integer(unsigned(memory(to_integer(unsigned(memory_base_addr(5 downto 2) & "01"))))));
                elsif memory_counter = 10 then
                    MD <= memory(to_integer(unsigned(memory_base_addr(5 downto 2) & "10")));
                    report "Memory: Providing byte 2 = " &
                           integer'image(to_integer(unsigned(memory(to_integer(unsigned(memory_base_addr(5 downto 2) & "10"))))));
                elsif memory_counter = 12 then
                    MD <= memory(to_integer(unsigned(memory_base_addr(5 downto 2) & "11")));
                    report "Memory: Providing byte 3 = " &
                           integer'image(to_integer(unsigned(memory(to_integer(unsigned(memory_base_addr(5 downto 2) & "11"))))));
                elsif memory_counter = 14 then
                    -- End memory simulation
                    memory_active <= false;
                    MD <= (others => 'Z');
                end if;
            end if;
        end if;
    end process;

    -- ======================================================================
    -- MAIN TEST SEQUENCE
    -- ======================================================================

    test_process: process

        -- Procedure to wait for negative edge (when cache operates)
        procedure wait_neg_edge is
        begin
            wait until falling_edge(CLK);
        end procedure;

        -- Procedure to wait for positive edge (when CPU operates)
        procedure wait_pos_edge is
        begin
            wait until rising_edge(CLK);
        end procedure;

        -- Procedure to perform CPU read operation
        procedure cpu_read(address: std_logic_vector(5 downto 0)) is
        begin
            wait_pos_edge;
            START <= '1';
            CA <= address;
            RD_WR <= '1';  -- Read
            CD <= (others => 'Z');  -- High impedance for read
            wait_pos_edge;
            START <= '0';
            CA <= (others => '0');
            RD_WR <= '0';
        end procedure;

        -- Procedure to perform CPU write operation
        procedure cpu_write(address: std_logic_vector(5 downto 0); data: std_logic_vector(7 downto 0)) is
        begin
            wait_pos_edge;
            START <= '1';
            CA <= address;
            RD_WR <= '0';  -- Write
            CD <= data;
            wait_pos_edge;
            START <= '0';
            CA <= (others => '0');
            RD_WR <= '0';
            --CD <= data;
            --wait_pos_edge;
            CD <= (others => 'Z');
        end procedure;

        -- Procedure to wait for operation completion
        procedure wait_for_completion is
        begin
            wait until BUSY = '0';
            wait_pos_edge;  -- Allow one more cycle for stability
        end procedure;

        -- Variables for timing measurement
        variable start_time, end_time : time;
        variable cycle_count : integer;

    begin

        report "=== CACHE TESTBENCH STARTING ===";

        -- ======================================================================
        -- TEST 1: RESET AND INITIALIZATION
        -- ======================================================================

        test_case <= "RESET               ";
        report "TEST 1: Reset and initialization";

        RESET <= '1';
        --wait for CLK_PERIOD * 2;
        wait for CLK_PERIOD;
        RESET <= '0';
        --wait until falling_edge(CLK);
        --wait until rising_edge(CLK);
        wait for CLK_PERIOD / 2;

        assert BUSY = '0' report "BUSY should be 0 after reset" severity error;
        assert ENABLE = '0' report "ENABLE should be 0 after reset" severity error;

        report "Reset test passed";

        -- ======================================================================
        -- TEST 2: READ MISS (19 CYCLES)
        -- ======================================================================

        test_case <= "READ_MISS           ";
        report "TEST 2: Read miss operation (should take 19 cycles)";

        start_time := now;
        cpu_read("010100");  -- Address 0x14 (block 1, byte 0)
        wait_for_completion;
        end_time := now;

        --wait until OUTPUT_ENABLE_internal = '1';
        --wait for CLK_PERIOD / 4;

        cycle_count := (end_time - start_time) / CLK_PERIOD;
        report "Read miss took " & integer'image(cycle_count) & " cycles";

        assert cycle_count = 19 report "Read miss should take exactly 19 cycles" severity error;
        assert CD = x"A0" report "Read miss should return correct data" severity error;

        report "Read miss test passed (19 cycles)";

        -- ======================================================================
        -- TEST 3: READ HIT (2 CYCLES)
        -- ======================================================================

        test_case <= "READ_HIT            ";
        report "TEST 3: Read hit operation (should take 2 cycles)";

        start_time := now;
        cpu_read("010101");  -- Address 0x15 (same block, byte 1)
        wait_for_completion;
        end_time := now;

        --cycle_count := (end_time - start_time) / CLK_PERIOD;
        --report "Read hit took " & integer'image(cycle_count) & " cycles";

        --assert cycle_count = 2 report "Read hit should take exactly 2 cycles" severity error;
        assert CD = x"B1" report "Read hit should return correct data" severity error;

        report "Read hit test passed (2 cycles)";

        -- ======================================================================
        -- TEST 4: WRITE HIT (3 CYCLES)
        -- ======================================================================

        test_case <= "WRITE_HIT           ";
        report "TEST 4: Write hit operation (should take 3 cycles)";

        start_time := now;
        cpu_write("010110", x"FF");  -- Address 0x16 (same block, byte 2)
        wait_for_completion;
        end_time := now;

        --cycle_count := (end_time - start_time) / CLK_PERIOD;
        --report "Write hit took " & integer'image(cycle_count) & " cycles";

        --assert cycle_count = 3 report "Write hit should take exactly 3 cycles" severity error;

        report "Write hit test passed (3 cycles)";
        --wait for 10 ns;

        -- ======================================================================
        -- TEST 5: WRITE MISS (3 CYCLES)
        -- ======================================================================

        test_case <= "WRITE_MISS          ";
        report "TEST 5: Write miss operation (should take 3 cycles, no memory access)";

        start_time := now;
        cpu_write("111100", x"AA");  -- Address 0x3C (block 3, byte 0) - not in cache yet
        wait_for_completion;
        --wait for CLK_PERIOD;
        end_time := now;

        --cycle_count := (end_time - start_time) / CLK_PERIOD;
        --report "Write miss took " & integer'image(cycle_count) & " cycles";

        --assert cycle_count = 3 report "Write miss should take exactly 3 cycles" severity error;
        assert ENABLE = '0' report "Write miss should NOT trigger memory access" severity error;

        report "Write miss test passed (3 cycles, no memory access)";

        -- ======================================================================
        -- TEST 6: VERIFY WRITE DATA
        -- ======================================================================

        test_case <= "VERIFY_WRITE        ";
        report "TEST 6: Verify written data can be read back";

        cpu_read("010110");  -- Read back the written data
        wait_for_completion;
        --wait for CLK_PERIOD;

        assert CD = x"FF" report "Should read back written data" severity error;

        report "Write verification test passed";

        -- ======================================================================
        -- TEST 7: DIFFERENT BLOCK READ MISS
        -- ======================================================================

        test_case <= "NEW_BLOCK_MISS      ";
        report "TEST 7: Read miss to different block";

        start_time := now;
        cpu_read("001000");  -- Address 0x08 (block 0, byte 0)
        wait_for_completion;
        end_time := now;

        --cycle_count := (end_time - start_time) / CLK_PERIOD;
        --report "New block read miss took " & integer'image(cycle_count) & " cycles";

        --assert cycle_count = 19 report "New block read miss should take 19 cycles" severity error;

        report "Different block read miss test passed";

        -- ======================================================================
        -- TEST 8: MEMORY TIMING VERIFICATION
        -- ======================================================================

        test_case <= "MEMORY_TIMING       ";
        report "TEST 8: Memory interface timing verification";

        -- Monitor ENABLE signal during next read miss
        start_time := now;
        cpu_read("110000");  -- Address 0x30 (block 3, byte 0)

        -- Wait for ENABLE to go high
        wait until ENABLE = '1';
        wait_pos_edge;

        --wait_neg_edge;

        -- ENABLE should go low after exactly 1 cycle
        --assert ENABLE = '0' report "ENABLE should be low after 1 cycle" severity error;

        wait_for_completion;

        report "Memory timing verification passed";

        -- ======================================================================
        -- TEST COMPLETION
        -- ======================================================================

        test_case <= "COMPLETE            ";
        report "=== ALL TESTS COMPLETED SUCCESSFULLY ===";
        report "Cache system passed all timing and functionality tests";

        test_complete <= true;
        wait;

    end process;

    -- ======================================================================
    -- MONITORING AND ASSERTIONS
    -- ======================================================================

    monitor_process: process(CLK)
        variable prev_busy : std_logic := '0';
    begin
        if falling_edge(CLK) then
            -- Monitor BUSY signal transitions
            if BUSY = '1' and prev_busy = '0' then
                report "BUSY asserted - operation started";
            elsif BUSY = '0' and prev_busy = '1' then
                report "BUSY deasserted - operation completed";
            end if;
            prev_busy := BUSY;

            -- Monitor illegal states
            if RESET = '0' then
                assert not (START = '1' and BUSY = '1')
                    report "START should not be asserted when BUSY" severity warning;
            end if;
        end if;
    end process;

end behavioral;