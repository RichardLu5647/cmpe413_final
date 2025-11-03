---
-- Entity: cache_cell_tb
-- Architecture: structural
-- Description: Testbencg for cache cell.
--
library IEEE;
use IEEE.std_logic_1164.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity cache_cell_tb is
end entity;

architecture testbench of cache_cell_tb is
	component cache_cell is 
		port(
        	write_data : in std_logic_vector(7 downto 0);
            chip_enable : in std_logic;
            rd_wr : in std_logic;
            read_data : out std_logic_vector(7 downto 0)
        );
    end component;
    
    signal write_data_tb, read_data_tb : std_logic_vector(7 downto 0);
    signal chip_enable_tb, rd_wr_tb : std_logic;
    
begin 
	dut: cache_cell port map(
    	write_data => write_data_tb,
        chip_enable => chip_enable_tb,
        rd_wr => rd_wr_tb,
        read_data => read_data_tb
    );
    
    process
    begin 
    	-- Test Case 1: Write and Read
        report "=== Test 1: Write 0xAA ===";
        write_data_tb <= x"AA";
        chip_enable_tb <= '1';
        rd_wr_tb <= '0';
        wait for 20 ns;
        
        rd_wr_tb <= '1';
        wait for 20 ns;
        
        assert read_data_tb = x"AA"
        	report "Test 1 FAILED - read_data does not match 0xAA"
            severity error;
        report "Test 1 PASSED";
        
        -- Test Case 2 Cell Not Selected (chip_enable = 0)
        report "=== Test 2 chip_enable = 0 ===";
        write_data_tb <= x"55";
        chip_enable_tb <= '0';
        rd_wr_tb <= '0';
        wait for 20 ns;
        
        rd_wr_tb <= '1';
        wait for 20 ns;
        
        assert read_data_tb = x"ZZ"
        	report "Test 2 FAILED - read data does not match Z"
            severity error;
        report "Test 2 PASSED";
        
        -- Test Case 3 Multiple Writes
        report "=== Test 3 ===";
        write_data_tb <= x"11";
        chip_enable_tb <= '1';
        rd_wr_tb <= '0';
        wait for 20 ns;
        
        write_data_tb <= x"22";
        chip_enable_tb <= '1';
        rd_wr_tb <= '0';
        wait for 20 ns;
        
        write_data_tb <= x"33";
        chip_enable_tb <= '1';
        rd_wr_tb <= '0';
        wait for 20 ns;
        
        rd_wr_tb <= '1';
        wait for 20 ns;
        
        assert read_data_tb = x"33"
        	report "Test 3 FAILED - read does not match 0x33"
            severity error;
        report "Test 3 PASSED";
        
        
        wait;
    end process;

end architecture;