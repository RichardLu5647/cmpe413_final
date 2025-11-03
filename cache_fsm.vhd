--
-- Entity: cache_fsm
-- Architecture: structural
-- Description: Cache fsm to control logic flow of cache.
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cache_fsm is
    port (
        -- System signals
        CLK           : in  std_logic;
        RESET         : in  std_logic;

        -- CPU interface
        START         : in  std_logic;
        CA            : in  std_logic_vector(5 downto 0);  -- CPU address
        RD_WR         : in  std_logic;                     -- 1=read, 0=write
        CD            : inout std_logic_vector(7 downto 0); -- CPU data bus
        BUSY          : out std_logic;
        OUTPUT_ENABLE : out std_logic;

        -- Cache interface
        is_hit        : in  std_logic;
        read_data     : in  std_logic_vector(7 downto 0);
        block_select  : out std_logic_vector(1 downto 0);
        byte_select   : out std_logic_vector(1 downto 0);
        tag_in        : out std_logic_vector(1 downto 0);
        write_data    : out std_logic_vector(7 downto 0);
        cache_rd_wr   : out std_logic;
        tag_write_enable : out std_logic;
        valid_in      : out std_logic;

        -- Memory interface
        MD            : in  std_logic_vector(7 downto 0);  -- Memory data
        MA            : out std_logic_vector(5 downto 0);  -- Memory address
        ENABLE        : out std_logic                      -- Memory enable
    );
end cache_fsm;

architecture structural of cache_fsm is
    component dlatch is 
    	port (
        	d : in std_logic;
            clk : in std_logic;
            q : out std_logic;
            qbar: out std_logic
        );
    end component;
    
    component fsm_states is
    port(
    	CLK           : in  std_logic;
        RESET         : in  std_logic;  
        START         : in std_logic;
        is_hit        : in std_logic;
        rd_wr         : in std_logic;
        states        : in std_logic_vector (21 downto 0);
        next_states   : out std_logic_vector (21 downto 0)
    );
    end component;

    component and2 is
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        output   : out std_logic);
    end component;

    component or7 is
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        input3   : in std_logic;
        input4   : in  std_logic;
        input5   : in  std_logic;
        input6   : in std_logic;
        input7   : in std_logic;
        output   : out std_logic);
    end component;

    component nor2 is
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        output   : out std_logic);
    end component;

    component or3 is
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        input3   : in std_logic;
        output   : out std_logic
    );
    end component;

    component set_curr_states is
        port(
            CLK           : in  std_logic;
            RESET         : in  std_logic;  
            next_state    : in std_logic_vector (21 downto 0);
            curr_state    : out std_logic_vector (21 downto 0)
        );
    end component;

    component or2 is
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        output   : out std_logic);
    end component;

    component tri_buffer is
    port(
        data_in  : in  std_logic_vector(7 downto 0);
        enable   : in  std_logic;
        data_out : out std_logic_vector(7 downto 0)
    );
    end component;

    component mux2to1 is
      port (
          D0 : in std_logic;  
          D1 : in std_logic;  
          S  : in std_logic;  
          Y  : out std_logic
      );
	end component;
    
    component latch_cache_address is
      port(
          CLK  		  : in std_logic;
          address     : in  std_logic_vector(5 downto 0);
          enable      : in  std_logic;
          RESET       : in std_logic;
          address_out : out std_logic_vector(5 downto 0)
      );
	end component;
    
    component latch_cache_data is
      port(
          CLK  		  : in std_logic;
          data     : in  std_logic_vector(7 downto 0);
          enable      : in  std_logic;
          RESET       : in std_logic;
          data_out : out std_logic_vector(7 downto 0)
      );
	end component;
    
    component latch_rd_wr is
      port(
          CLK  		  : in std_logic;
          rd_wr       : in  std_logic;
          enable      : in  std_logic;
          RESET       : in std_logic;
          rd_wr_out   : out std_logic
      );
	end component;
    
    component select_write_data is
      port(
          latched_data : in std_logic_vector(7 downto 0);   -- Input 0
          memory_data  : in std_logic_vector(7 downto 0);   -- Input 1
          S            : in std_logic;   -- Select (0=D0, 1=D1)
          Y            : out std_logic_vector(7 downto 0)   -- Output
      );
	end component;
    
    component byte_selector is
      port(
          byte_00     : in std_logic_vector(1 downto 0); 
          byte_01     : in std_logic_vector(1 downto 0);
          byte_10     : in std_logic_vector(1 downto 0);
          byte_11     : in std_logic_vector(1 downto 0);
          cache_byte  : in std_logic_vector(1 downto 0);
          byte_00_en  : in std_logic; 
          byte_01_en  : in std_logic;
          byte_10_en  : in std_logic;
          byte_11_en  : in std_logic;
          Y           : out std_logic_vector(1 downto 0)
      );
	end component;

    -- Internal registers
    signal latched_addr  : std_logic_vector(5 downto 0);
    signal latched_rd_wr : std_logic;
    signal latched_cd : std_logic_vector(7 downto 0);

    -- States
    signal states : std_logic_vector (21 downto 0);
    signal next_states : std_logic_vector (21 downto 0);
    
    -- Enable for inputing address, data, and rd_wr.
    signal input_en : std_logic;
    
    -- Enable for memory data
    signal memory_data_en : std_logic;
    
    -- Enables for byte select
    signal byte00_select, byte01_select, byte10_select, byte11_select : std_logic;

begin

    -- Sets current states to next states.
    set_current_states: set_curr_states port map(
        CLK           => CLK,
        RESET         => RESET,
        next_state    => next_states,
        curr_state    => states
    );

    -- Sets the next states based on current inputs.
	set_next_states: fsm_states port map(
        CLK           => CLK,
        RESET         => RESET,  
        START         => START,
        is_hit        => is_hit,
        rd_wr         => latched_rd_wr,
        states        => states,
        next_states   => next_states
    );
    
    -- Enables output in READ_DONE state.
    OUTPUT_ENABLE <= states(20);

    -- Sets write enable to 1 when in READ_MISS_DATA state
    tag_write_enable <= states(9);

    -- Sets cache rd_wr to 1 in TAG_CHECK, READ_MISS_OUTPUT, WAIT_READ_MISS,
    -- READ_DONE, WRITE_MISS, or IDLE.
    set_cache_rd_wr: or7 port map(
        input1   => states(0),
        input2   => states(1),
        input3   => states(2),
        input4   => states(17),
        input5   => states(18),
        input6   => states(19),
        input7   => states(20),
        output   => cache_rd_wr
    );

    -- Enables memory enable in READ_MISS_REQUEST state.
    ENABLE <= states(3);

    -- Sets busy to low in IDLE or READ_DONE state.
    
    set_busy_low: nor2 port map(
        input1 => states(0),
        input2 => states(20),
        output => BUSY
    );
    
    valid_in <= '1';  -- Always set valid bit when writing tag

    -- Sets the CD data when OUTPUT_ENABLE is HIGH.
    set_CD: tri_buffer port map(
        data_in => read_data,
        enable  => OUTPUT_ENABLE,
        data_out => CD
    );
    

	-- Determines when address should be inputted.
	enable_address: and2 port map(
    	input1 => states(0),
        input2 => START,
        output => input_en
    );
    
    -- Latches the cache address if start is high and current state is idle.
    input_address: latch_cache_address port map(
      	CLK  		=> CLK,
      	address     => CA, 
      	enable      => input_en,
      	RESET       => RESET,
      	address_out => latched_addr
    );
    
    -- Latches the cache data if start is high and current state is idle.
    input_data: latch_cache_data port map(
      	CLK  		=> CLK,
      	data        => CD, 
      	enable      => input_en,
      	RESET       => RESET,
      	data_out    => latched_cd
    );
    
    -- Latches the rd_wr if start is high and current state is idle.
    input_rd_wr: latch_rd_wr port map(
        CLK  		=> CLK,
      	rd_wr       => RD_WR, 
      	enable      => input_en,
      	RESET       => RESET,
      	rd_wr_out   => latched_rd_wr
    );

    -- Address breakdown from latched address
    tag_in <= latched_addr(5 downto 4);
    block_select <= latched_addr(3 downto 2);


	-- Determining enables for the byte select
    select00: or2 port map(
    	input1 => states(10),
        input2 => states(11),
        output => byte00_select
    );
    select01: or2 port map(
    	input1 => states(12),
        input2 => states(13),
        output => byte01_select
    );
    select10: or2 port map(
    	input1 => states(14),
        input2 => states(15),
        output => byte10_select
    );
    
    byte11_select <= states(16);
    
	-- Which bytes should the memory data go to based on the state
    select_byte: byte_selector port map(
          byte_00     => "00", 
          byte_01     => "01",
          byte_10     => "10",
          byte_11     => "11",
          cache_byte  => latched_addr(1 downto 0),
          byte_00_en  => byte00_select, 
          byte_01_en  => byte01_select,
          byte_10_en  => byte10_select,
          byte_11_en  => byte11_select,
          Y           => byte_select
      );

    -- write_data: MD during data loading, latched_cd otherwise
    -- Decided when memory data should be imported.
	mem_data_en: or7 port map(
    	input1 => states(10),
        input2 => states(11),
        input3 => states(12),
        input4 => states(13),
        input5 => states(14),
        input6 => states(15),
       	input7 => states(16),
        output => memory_data_en
    );
    
    -- Whether write_data should be from cache data or memory data.
    write_MD_or_CD: select_write_data port map(
    	latched_data => latched_cd,  
      	memory_data => MD,  
      	S  => memory_data_en,  
      	Y  => write_data
    );

    -- Memory address: block-aligned (lower 2 bits = "00")
    MA <= latched_addr(5 downto 2) & "00";

end structural;
