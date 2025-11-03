--
-- Entity: cache_cell
-- Architecture: structural
-- Description: Cache cell for the cache.
--

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_cell is
port(
  write_data: in std_logic_vector(7 downto 0);
  chip_enable : in std_logic;
  rd_wr : in std_logic;
  read_data: out std_logic_vector(7 downto 0)
);
end cache_cell;

architecture structural of cache_cell is 
	component dlatch is 
    	port (
        	d : in std_logic;
            clk : in std_logic;
            q : out std_logic;
            qbar: out std_logic
        );
    end component;
    
    component inverter is 
    	port (
        	input : in std_logic;
            output : out std_logic
        );
    end component;
    
    component and2 is 
    	port(
        	input1: in std_logic;
            input2 : in std_logic;
            output : out std_logic
        );
    end component;
    
    component tx is 
    	port(
        	sel : in std_logic;
            selnot : in std_logic;
            input : in std_logic;
            output : out std_logic
        );
    end component;
    
    signal stored_data : std_logic_vector(7 downto 0);
    signal write_en : std_logic;
    signal read_en : std_logic;
    signal read_en_n : std_logic;
    signal rd_wr_n : std_logic;
    
begin 

    -- Inverted signals
	INV: inverter port map(
    	input => rd_wr,
        output => rd_wr_n
    );
    
    INV2: inverter port map(
    	input => read_en,
        output => read_en_n
    );
    
    -- Read and write enables.
    write_and: and2 port map(
    	input1 => chip_enable,
        input2 => rd_wr_n,
        output => write_en
    );
    
    read_and: and2 port map(
    	input1 => chip_enable,
        input2 => rd_wr,
        output => read_en
    );
    
    -- Where the data is stored.
    set_latches: for i in 0 to 7 generate
        latch_i: dlatch port map(
            d => write_data(i),
            clk => write_en,
            q => stored_data(i),
            qbar => open
        );
    end generate;
    
    -- What data will be stored based on enables.
    data_en: for i in 0 to 7 generate
        txi: tx port map(
            sel => read_en,
            selnot => read_en_n,
            input => stored_data(i),
            output => read_data(i)
        );
    end generate;
    

end structural;