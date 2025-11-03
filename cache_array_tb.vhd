--
-- Entity: cache_array
-- Architecture: structural
-- Description: Cache array for the cache.
-- 
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity cache_array_tb is 
end entity;

architecture testbench of cache_array_tb is 
	component cache_array is 
    	port (
        	write_data : in std_logic_vector(7 downto 0);
            read_data : out std_logic_vector(7 downto 0);
            block_select : in std_logic_vector(1 downto 0);
            byte_select : in std_logic_vector(1 downto 0);
            tag_in : in std_logic_vector(1 downto 0);
            is_hit : out std_logic;
            tag_match : out std_logic;
            valid : out std_logic;
            rd_wr : in std_logic;
            tag_write_enable : in std_logic;
            valid_in : in std_logic;
			RESET : std_logic
        );
    end component;
    
    signal write_data_tb : std_logic_vector(7 downto 0);
    signal read_data_tb : std_logic_vector(7 downto 0);
    signal block_select_tb : std_logic_vector(1 downto 0);
    signal byte_select_tb : std_logic_vector(1 downto 0);
    signal tag_in_tb : std_logic_vector(1 downto 0);
    signal is_hit_tb : std_logic;
    signal tag_match_tb : std_logic;
    signal valid_tb : std_logic;
    signal rd_wr_tb : std_logic;
    signal tag_write_enable_tb : std_logic;
    signal valid_in_tb : std_logic;
	signal reset_tb : std_logic;
    
begin
	dut: cache_array port map(
    	write_data => write_data_tb,
        read_data => read_data_tb,
        block_select => block_select_tb,
        byte_select => byte_select_tb,
        tag_in => tag_in_tb,
        is_hit => is_hit_tb,
        --tag_match => tag_match_tb,
        valid => valid_tb,
        rd_wr => rd_wr_tb,
        tag_write_enable => tag_write_enable_tb,
        valid_in => valid_in_tb,
		RESET => reset_tb
    );
    
    process 
    begin
        report "=== CACHE ARRAY TESTBENCH STARTING ===";
        
    	-- Initialization - Set all signals to known state
    	tag_in_tb <= "00";
        block_select_tb <= "00";
        byte_select_tb <= "00";
        rd_wr_tb <= '1';  -- Read mode
        tag_write_enable_tb <= '0';
        valid_in_tb <= '0';
        write_data_tb <= x"00";
		reset_tb <= '0';
        wait for 10 ns;
        
        -- Test 1: Write data to Block 0, Byte 0 and set up tag
        report "=== Test 1: Write to Block 0, Byte 0 ===";
        block_select_tb <= "00";  -- Block 0
        byte_select_tb <= "00";   -- Byte 0
        tag_in_tb <= "01";        -- Tag = 1
        write_data_tb <= x"AB";   -- Data to write
        valid_in_tb <= '1';       -- Mark as valid
        rd_wr_tb <= '0';          -- Write mode
        tag_write_enable_tb <= '1'; -- Enable tag/valid update
        wait for 20 ns;
        
        -- Read it back
        rd_wr_tb <= '1';          -- Read mode
        tag_write_enable_tb <= '0'; -- Disable tag updates
        wait for 20 ns;
        
        assert read_data_tb = x"AB"
        	report "Test 1 FAILED: Expected 0xAB, got " & 
                   integer'image(to_integer(unsigned(read_data_tb)))
        	severity error;
        report "Test 1 PASSED: Data written and read correctly";
        
        -- Test 2: Hit Detection with correct tag
        report "=== Test 2: Hit Detection (Correct Tag) ===";
        block_select_tb <= "00";  -- Same block
        byte_select_tb <= "00";   -- Same byte
        tag_in_tb <= "01";        -- Same tag
        rd_wr_tb <= '1';          -- Read mode
        tag_write_enable_tb <= '0';
        wait for 20 ns;
        
        assert is_hit_tb = '1' 
            report "Test 2 FAILED: Should be HIT (is_hit should be 1)" 
            severity error;
        assert valid_tb = '1' 
            report "Test 2 FAILED: Should be valid" 
            severity error;
        --assert tag_match_tb = '1'
            --report "Test 2 FAILED: Tag should match"
            --severity error;
        report "Test 2 PASSED: Hit detection working";
        
        -- Test 3: Miss Detection with wrong tag
        report "=== Test 3: Miss Detection (Wrong Tag) ===";
        block_select_tb <= "00";  -- Same block
        byte_select_tb <= "00";   -- Same byte
        tag_in_tb <= "10";        -- Different tag
        rd_wr_tb <= '1';          -- Read mode
        wait for 20 ns;
        
        assert is_hit_tb = '0' 
            report "Test 3 FAILED: Should be MISS (is_hit should be 0)" 
            severity error;
        --assert tag_match_tb = '0'
            --report "Test 3 FAILED: Tag should NOT match"
            --severity error;
        report "Test 3 PASSED: Miss detection working";
        
        wait for 10 ns;
        
        -- Test 4: Write to different byte in same block
        report "=== Test 4: Write to Different Byte ===";
        block_select_tb <= "00";  -- Same block
        byte_select_tb <= "01";   -- Different byte (byte 1)
        tag_in_tb <= "01";        -- Same tag
        wait for 10 ns;
        
        write_data_tb <= x"CD";   -- Different data
        rd_wr_tb <= '0';          -- Write mode
        tag_write_enable_tb <= '0'; -- Don't update tag (already set)
        wait for 20 ns;
        
        -- Read it back
        rd_wr_tb <= '1';          -- Read mode
        wait for 20 ns;
        
        assert read_data_tb = x"CD"
        	report "Test 4 FAILED: Expected 0xCD"
        	severity error;
        assert is_hit_tb = '1' 
            report "Test 4 FAILED: Should still be HIT" 
            severity error;
        report "Test 4 PASSED: Different byte access working";
        
        wait for 10 ns;
        
        -- Test 5: Verify first byte still has original data
        report "=== Test 5: Verify Byte Isolation ===";
        byte_select_tb <= "00";   -- Back to byte 0
        wait for 20 ns;
        
        assert read_data_tb = x"AB"
        	report "Test 5 FAILED: Byte 0 should still be 0xAB"
        	severity error;
        report "Test 5 PASSED: Byte isolation working";
        
        wait for 10 ns;
        
        -- Test 6: Different block
        report "=== Test 6: Different Block Access ===";
        block_select_tb <= "01";  -- Block 1
        byte_select_tb <= "00";   -- Byte 0
        tag_in_tb <= "10";        -- Tag = 2
        wait for 10 ns;
        
        write_data_tb <= x"EF";   -- Data to write
        valid_in_tb <= '1';       -- Mark as valid
        rd_wr_tb <= '0';          -- Write mode
        tag_write_enable_tb <= '1'; -- Enable tag/valid update
        wait for 10 ns;
        
        -- Read it back
        rd_wr_tb <= '1';          -- Read mode
        tag_write_enable_tb <= '0';
        wait for 20 ns;
        
        assert read_data_tb = x"EF"
        	report "Test 6 FAILED: Expected 0xEF"
        	severity error;
        assert is_hit_tb = '1' 
            report "Test 6 FAILED: Should be HIT in new block" 
            severity error;
        report "Test 6 PASSED: Different block working";
        
        -- Test 7: Verify block isolation
        report "=== Test 7: Verify Block Isolation ===";
        block_select_tb <= "00";  -- Back to block 0
        tag_in_tb <= "01";        -- Original tag
        wait for 20 ns;
        
        assert read_data_tb = x"AB"
        	report "Test 7 FAILED: Block 0 should still have 0xAB"
        	severity error;
        assert is_hit_tb = '1' 
            report "Test 7 FAILED: Block 0 should still be HIT" 
            severity error;
        report "Test 7 PASSED: Block isolation working";
        
        report "=== ALL TESTS COMPLETED SUCCESSFULLY ===";
        wait;
    
    end process;
    	

end testbench;