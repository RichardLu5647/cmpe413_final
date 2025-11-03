library IEEE;
use IEEE.std_logic_1164.all;

entity cache_block is 
	port (
    	write_data : in std_logic_vector(7 downto 0);
        read_data : out std_logic_vector(7 downto 0);
        
        byte_select : in std_logic_vector(1 downto 0);
        
        tag_in : in std_logic_vector(1 downto 0);
        tag_out : out std_logic_vector(1 downto 0);
        
        valid_in : in std_logic;
        valid_out : out std_logic;
        
        block_enable : in std_logic;
        rd_wr : in std_logic;
        tag_write_enable : in std_logic;					-- Should only be high when loading a new block from memory (read miss)
        RESET : in std_logic
    );

end cache_block;

architecture structural of cache_block is
	component decoder2to4 is
    	port(
        	A1, A0 : in std_logic;
            E : in std_logic;
            Y0, Y1, Y2, Y3 : out std_logic
        );
    end component;
    
    component cache_cell is 
    	port (
        	write_data : in std_logic_vector(7 downto 0);
            chip_enable : in std_logic;
            rd_wr : in std_logic;
            read_data : out std_logic_vector(7 downto 0)
        );
    end component;
        
    component dlatch is 
    	port(
        	d : in std_logic;
            clk : in std_logic;
            q : out std_logic;
            qbar : out std_logic
        );
    end component;
    
    component mux2to1 is
      port (
          D0 : in std_logic;  -- normal data
          D1 : in std_logic;  -- reset value
          S  : in std_logic;  -- select: 0 = normal, 1 = reset
          Y  : out std_logic
      );
	end component;

    
    -- Signals for the output of the decoder
    signal chip_enable_0, chip_enable_1, chip_enable_2, chip_enable_3 : std_logic;
    
    signal stored_tag : std_logic_vector(1 downto 0);
    signal stored_valid : std_logic;
    signal valid_write_enable : std_logic;
    
    signal tag0_reset_mux_out, tag1_reset_mux_out, valid_reset_mux_out : std_logic;
    
begin 
	-- Decoder: Select which of 4 cache_cells to enable
	byte_decoder: decoder2to4 port map(
    	A1 => byte_select(1),	-- High bit of byte_select
        A0 => byte_select(0),	-- Low bit of byte_select
        E => block_enable and not RESET,		-- Only decode if this block is enabled
        Y0 => chip_enable_0,	-- Enable for cache_cell 0
        Y1 => chip_enable_1,	-- Enable for cache_cell 1
        Y2 => chip_enable_2,	-- Enable for cache_cell 2
        Y3 => chip_enable_3		-- Enable for cache_cell 3
    );
    
    cell_0: cache_cell port map(
    	write_data => write_data,		-- Shared bus
        chip_enable => chip_enable_0,	-- Decoder Y0
        rd_wr => rd_wr,					-- Shared Control
        read_data => read_data			-- Shared bus 
    );
    
	cell_1: cache_cell port map(
    	write_data => write_data,		
        chip_enable => chip_enable_1,	-- Decoder Y1
        rd_wr => rd_wr,					
        read_data => read_data
    );
    
    cell_2: cache_cell port map(
    	write_data => write_data,		
        chip_enable => chip_enable_2,	-- Decoder Y2
        rd_wr => rd_wr,					
        read_data => read_data
    );
    
    cell_3: cache_cell port map(
    	write_data => write_data,		
        chip_enable => chip_enable_3,	-- Decoder Y3
        rd_wr => rd_wr,					
        read_data => read_data
    );
    
    
    tag0_mux: mux2to1 port map(
      D0 => tag_in(0),    -- normal input
      D1 => '0',          -- reset value
      S  => RESET,        -- when RESET=1, select '0'
      Y  => tag0_reset_mux_out
    );

    tag1_mux: mux2to1 port map(
        D0 => tag_in(1),
        D1 => '0',
        S  => RESET,
        Y  => tag1_reset_mux_out
    );

    valid_mux: mux2to1 port map(
        D0 => valid_in,
        D1 => '0',
        S  => RESET,
        Y  => valid_reset_mux_out
    );
    
    -- Store tag bit 0
    tag_latch_0: dlatch port map(
    	d => tag0_reset_mux_out,
        clk => tag_write_enable,	-- Stores when high
        q => stored_tag(0),
        qbar => open
    );
    
    -- Store tag bit 1
    tag_latch_1: dlatch port map(
    	d => tag1_reset_mux_out,
        clk => tag_write_enable,
        q => stored_tag(1),
        qbar => open
    );
    
    -- Store valid bit
    valid_latch: dlatch port map(
    	d => valid_reset_mux_out,
        clk => tag_write_enable,
        q => stored_valid,
        qbar => open
    );
    
    tag_out <= stored_tag;
    valid_out <= stored_valid;
	

end structural;