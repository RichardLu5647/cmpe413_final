--
-- Entity: cache_block_tb
-- Architecture: stest bench
-- Description: Tests the functions for the cache block
--
library IEEE;
use IEEE.std_logic_1164.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity cache_block_tb is
end entity;

architecture testbench of cache_block_tb is 
	component cache_block is 
    	port(
        	write_data : in std_logic_vector(7 downto 0);
        	read_data : out std_logic_vector(7 downto 0);
        	byte_select : in std_logic_vector(1 downto 0);
        	tag_in : in std_logic_vector(1 downto 0);
        	tag_out : out std_logic_vector(1 downto 0);
        	valid_in : in std_logic;
        	valid_out : out std_logic;
        
        	block_enable : in std_logic;
        	rd_wr : in std_logic;
        	tag_write_enable : in std_logic;
			RESET : in std_logic
        );
    end component;
    
    signal write_data_tb : std_logic_vector(7 downto 0);
    signal read_data_tb : std_logic_vector(7 downto 0);
    
    signal byte_select_tb : std_logic_vector(1 downto 0);
    signal tag_in_tb : std_logic_vector(1 downto 0);
    signal tag_out_tb : std_logic_vector(1 downto 0);
    signal valid_in_tb : std_logic;
    signal valid_out_tb : std_logic;
    signal block_enable_tb : std_logic;
    signal rd_wr_tb : std_logic;
    signal tag_write_enable_tb : std_logic;
	signal reset_tb : std_logic;
    
begin
	dut: cache_block port map(
    	write_data => write_data_tb,
        read_data => read_data_tb,
        byte_select => byte_select_tb,
        tag_in => tag_in_tb,
        tag_out => tag_out_tb,
        valid_in => valid_in_tb,
        valid_out => valid_out_tb,
        block_enable => block_enable_tb,
        rd_wr => rd_wr_tb,
        tag_write_enable => tag_write_enable_tb,
		RESET => reset_tb
    );
    
    process
    begin 
    	-- Initialize signals
        block_enable_tb <= '1';		-- Enable the block
        tag_write_enable_tb <= '0';	-- Doesnt write the tag yet
        rd_wr_tb <= '0';			-- Write mode
        byte_select_tb <= "00";		-- Select byte 0
        write_data_tb <=x"00";
        valid_in_tb <= '0';
        tag_in_tb <= "00";
		reset_tb <= '0';
        wait for 10 ns;
        
        -- Test 1: Write 0xAA to byte 0
        report "=== Test 1: Write 0xAA to byte 0 ===";
        byte_select_tb <= "00";
        rd_wr_tb <= '0';			-- Write mode
        write_data_tb <= x"AA";
        wait for 20 ns;
        
        -- Read back byte 0
        rd_wr_tb <= '1';
        wait for 20 ns;
        assert read_data_tb = x"AA"
        	report "Test 1 FAILED: Expected 0xAA from byte 0"
            severity error;
        report "Test 1 PASSED: Byte 0 = 0xAA";
        
        rd_wr_tb <= '1';
        wait for 10 ns;
        
        -- TEST 2: Write 0xBB to byte 1
        report "=== Test 2: Write 0xBB to byte 1 ===";
        byte_select_tb <= "01";    -- Select byte 1
        wait for 10 ns;
        rd_wr_tb <= '0';
        write_data_tb <= x"BB";
        wait for 20 ns;
        
        -- Read back byte 1
        rd_wr_tb <= '1';
        wait for 20 ns;
        assert read_data_tb = x"BB"
            report "Test 2 FAILED: Expected 0xBB from byte 1"
            severity error;
        report "Test 2 PASSED: Byte 1 = 0xBB";
        
        -- Verify byte 0 still has 0xAA
        byte_select_tb <= "00";
        wait for 20 ns;
        assert read_data_tb = x"AA"
            report "Test 2b FAILED: Byte 0 was corrupted"
            severity error;
        report "Test 2b PASSED: Byte 0 still = 0xAA";
        
        -- TEST 3: Write to bytes 2 and 3
        report "=== Test 3: Write to bytes 2 and 3 ===";
        byte_select_tb <= "10";
        wait for 10 ns;
        rd_wr_tb <= '0';
        write_data_tb <= x"CC";
        wait for 20 ns;
        
        rd_wr_tb <= '1';
        byte_select_tb <= "11";
        wait for 10 ns;
        rd_wr_tb <= '0';
        write_data_tb <= x"DD";
        wait for 20 ns;
        
        -- Read back byte 2
        rd_wr_tb <= '1';
        byte_select_tb <= "10";
        wait for 20 ns;
        assert read_data_tb = x"CC"
            report "Test 3 FAILED: Expected 0xCC from byte 2"
            severity error;
        report "Test 3 PASSED: Byte 2 = 0xCC";
        
        -- Read back byte 3
        byte_select_tb <= "11";
        wait for 20 ns;
        assert read_data_tb = x"DD"
            report "Test 3b FAILED: Expected 0xDD from byte 3"
            severity error;
        report "Test 3b PASSED: Byte 3 = 0xDD";
        
        -- TEST 4: Set tag and valid bit
        report "=== Test 4: Set tag=10 and valid=1 ===";
        tag_in_tb <= "10";
        valid_in_tb <= '1';
        tag_write_enable_tb <= '1';  -- Enable tag write
        wait for 20 ns;
        tag_write_enable_tb <= '0';  -- Disable tag write
        wait for 20 ns;
        
        assert tag_out_tb = "10"
            report "Test 4 FAILED: Tag not stored correctly"
            severity error;
        assert valid_out_tb = '1'
            report "Test 4b FAILED: Valid bit not set"
            severity error;
        report "Test 4 PASSED: Tag=10, Valid=1";
        
        -- TEST 5: Block disabled
        report "=== Test 5: Block disabled ===";
        rd_wr_tb <= '1';
        byte_select_tb <= "00";
        wait for 10 ns;
        block_enable_tb <= '0';      -- Disable block
        wait for 20 ns;
        -- read_data should be 'Z' when block disabled
        report "Test 5 complete - check waveform for Z state";
        
        -- Re-enable and verify data still intact
        block_enable_tb <= '1';
        wait for 20 ns;
        assert read_data_tb = x"AA"
            report "Test 5b FAILED: Data corrupted when block disabled"
            severity error;
        report "Test 5b PASSED: Data preserved after disable";
        
        report "=== All tests complete ===";
        
        wait;
    end process;
    
end testbench;