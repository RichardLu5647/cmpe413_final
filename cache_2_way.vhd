--
-- Entity: cache_2_way
-- Architecture : structural (top-level cache system)
-- Author: Generated for structural cache controller project
-- Description: Top-level module integrating cache controller and cache array
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity cache_2_way is
    port (
        -- System signals
        CLK    : in  std_logic;
        RESET  : in  std_logic;
        
        -- CPU Interface
        START  : in  std_logic;                      -- Start operation
        CA     : in  std_logic_vector(5 downto 0);   -- CPU address
        RD_WR  : in  std_logic;                      -- 1=read, 0=write
        CD     : inout std_logic_vector(7 downto 0); -- CPU data bus
        BUSY   : out std_logic;                      -- Cache busy
        
        -- Memory Interface
        MD     : in  std_logic_vector(7 downto 0);   -- Memory data
        MA     : out std_logic_vector(5 downto 0);   -- Memory address
        ENABLE : out std_logic                       -- Memory enable
    );
end cache_2_way;

architecture behavioral of cache_2_way is

    -- Component: Cache Controller (State Machine)
    component cache_fsm is
        port (
            -- System signals
            CLK           : in  std_logic;
            RESET         : in  std_logic;

            -- CPU interface
            START         : in  std_logic;
            CA            : in  std_logic_vector(5 downto 0);
            RD_WR         : in  std_logic;
            CD            : inout std_logic_vector(7 downto 0);
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
            MD            : in  std_logic_vector(7 downto 0);
            MA            : out std_logic_vector(5 downto 0);
            ENABLE        : out std_logic
        );
    end component;

    -- Component: Cache Array (Storage)
    component cache_array is
        port(
            -- Data interface
            write_data : in std_logic_vector(7 downto 0);
            read_data : out std_logic_vector(7 downto 0);

            -- Full address breakdown
            block_select : in std_logic_vector(1 downto 0);
            byte_select : in std_logic_vector(1 downto 0);
            tag_in : in std_logic_vector(1 downto 0);

            -- Tag comparison output (for hit/miss detection)
            is_hit : out std_logic;
            tag_match : out std_logic;
            valid : out std_logic;

            -- Control
            rd_wr : in std_logic;
            tag_write_enable : in std_logic;
            valid_in : in std_logic;
            RESET : in std_logic
        );
    end component;
    
    component latch_at_negedge is
    port(
        CLK             : in  std_logic;
        RESET           : in  std_logic;  
        CD_or_CA        : in std_logic;
        cache_data_addr : out std_logic
    );
    end component;

    component mux2to1 is  
        port (
            D0 : in  std_logic;
            D1 : in  std_logic;
            S  : in  std_logic;
            Y  : out std_logic
        );
    end component;

    component inverter is
    port (
        input    : in  std_logic;
        output   : out std_logic);
    end component;

    component and2 is
        port (
            input1   : in  std_logic;
            input2   : in  std_logic;
            output   : out std_logic
            );
    end component;
    
    component and3 is 
        port (
            A : in std_logic;
            B : in std_logic;
            C : in std_logic;
            Y : out std_logic
            );
    end component;
    
    component or2 is
        port (
            input1   : in  std_logic;
            input2   : in  std_logic;
            output   : out std_logic
            );
    end component;

    component demux1to2 is
        port(
            D  : in  std_logic;         
            S  : in  std_logic;         
            Y0 : out std_logic;         
            Y1 : out std_logic          
        );
    end component;

    -- Internal signals connecting controller to cache array
    signal is_hit_0, is_hit_1        : std_logic;
    signal read_data_0, read_data_1, read_data    : std_logic_vector(7 downto 0);
    signal block_select  : std_logic_vector(1 downto 0);
    signal byte_select   : std_logic_vector(1 downto 0);
    signal tag_in      : std_logic_vector(1 downto 0);
    signal write_data_0, write_data_1, write_data    : std_logic_vector(7 downto 0);
    signal rd_wr_0, rd_wr_1, fsm_rd_wr  : std_logic;
    signal valid_in      : std_logic;
    signal tag_write_enable: std_logic;
    signal tag_write_0, tag_write_1 : std_logic;

    -- OUTPUT_ENABLE
    signal OUTPUT_ENABLE          : std_logic;

    -- Unused cache array outputs
    signal tag_match_unused       : std_logic;
    signal valid_unused           : std_logic;

    -- Chip selection logic signals
    signal chip_enable_0, chip_enable_1 : std_logic;
    signal way1_hit, chosen_lru, not_hit_0, not_hit_1 : std_logic;

    -- LRU bit logic signals
    signal lru_set, lru_bit       : std_logic;
    signal updated_lru_bit        : std_logic;
    signal next_lru               : std_logic;
    signal not_busy, busy_d, busy_edge    : std_logic;  

begin

    -- ======================================================================
    -- FSM INSTANTIATION
    -- ======================================================================

    fsm_cache: cache_fsm port map(
        -- System signals
        CLK           => CLK,
        RESET         => RESET,

        -- CPU interface (pass through to top level)
        START         => START,
        CA            => CA,
        RD_WR         => RD_WR,
        CD            => CD,
        BUSY          => BUSY,
        OUTPUT_ENABLE => OUTPUT_ENABLE,

        -- Cache interface (internal connections)
        is_hit        => (is_hit_1 or is_hit_0),
        read_data     => read_data,
        block_select  => block_select,
        byte_select   => byte_select,
        tag_in        => tag_in,
        write_data    => write_data,
        cache_rd_wr   => fsm_rd_wr,
        tag_write_enable => tag_write_enable,
        valid_in      => valid_in,

        -- Memory interface (pass through to top level)
        MD            => MD,
        MA            => MA,
        ENABLE        => ENABLE
    );

    -- ======================================================================
    -- CHIP 0 INSTANTIATION
    -- ======================================================================

    storage_0: cache_array port map(
        -- Data interface (from/to controller)
        write_data => write_data_0,

        read_data => read_data_0,

        -- Address breakdown (from controller)
        block_select => block_select,
        byte_select => byte_select,
        tag_in => tag_in,

        -- Tag comparison output (to controller)
        is_hit => is_hit_0,
        tag_match => tag_match_unused,    -- Not used by controller
        valid => valid_unused,            -- Not used by controller

        -- Control signals (from controller)
        rd_wr => rd_wr_0,
        tag_write_enable => (tag_write_enable and chip_enable_0),
        valid_in => valid_in,
        RESET => RESET
    );

    -- ======================================================================
    -- CHIP 1 INSTANTIATION
    -- ======================================================================

    storage_1: cache_array port map(
        -- Data interface (from/to controller)
        write_data => write_data_1,
        read_data => read_data_1,
        
        -- Address breakdown (from controller)
        block_select => block_select,
        byte_select => byte_select,
        tag_in => tag_in,

        -- Tag comparison output (to controller)
        is_hit => is_hit_1,
        tag_match => tag_match_unused,    -- Not used by controller
        valid => valid_unused,            -- Not used by controller

        -- Control signals (from controller)
        rd_wr => rd_wr_1,
        tag_write_enable => (tag_write_enable and chip_enable_1),
        valid_in => valid_in,
        RESET => RESET
    );

    -- ======================================================================
    -- INPUT/OUTPUT MUXES
    -- ======================================================================

    -- Which read data is sent to fsm.
	read_data_muxes : for i in 0 to 7 generate
      read_data_mux: mux2to1 port map(
          D0 => read_data_0(i),   -- From way 0
          D1 => read_data_1(i),   -- From way 1
          S  => chip_enable_1,    -- Select way 1 when its enable = 1
          Y  => read_data(i)      -- Output to FSM
      );
      end generate;

    -- Which chip should fsm_rd_wr go to.
	rd_wr_demux: demux1to2 port map(
    	D => fsm_rd_wr,
        S => chip_enable_1,
        Y0 => rd_wr_0,
        Y1 => rd_wr_1
    );
    
    -- Which chip should write_data go to.
    write_data_muxes : for i in 0 to 7 generate
        write_data_mux: demux1to2 port map(
            D => write_data(i),
            S => chip_enable_1,
            Y0 => write_data_0(i),
            Y1 => write_data_1(i)
        );
    end generate;

    -- ======================================================================
    -- LRU UPDATE LOGIC
    -- ======================================================================

    -- The new lru is always the opposite of the chip just used.
    LRU_data: inverter port map(
        input => chip_enable_1,
        output => updated_lru_bit
    );

    -- Whether to have lru data or updated lru data
    update_mux_lru: mux2to1 port map(
        D0 => lru_bit,   
        D1 => updated_lru_bit,            
        S  => busy_edge,        
        Y  => lru_set
    );

    -- Resets lru_bit when RESET is enabled.
    reset_mux_lru: mux2to1 port map(
        D0 => lru_set,   
        D1 => '0',            
        S  => RESET,        
        Y  => next_lru
    );

    -- Stores the busy at posedge (not CLK makes it posedge)
    detect_busy: latch_at_negedge port map(
        CLK             => not CLK,
        RESET           => RESET,
        CD_or_CA        => BUSY,
        cache_data_addr => busy_d
    );

    -- Inverts busy
    inv_busy: inverter port map(
        input => BUSY,
        output => not_busy
    );

    -- Detects negedge of BUSY
    busy_edge_and: and2 port map(
        input1 => not_busy,
        input2 => busy_d,
        output => busy_edge
    );

    -- stores LRU bit at posedge
    store_lru: latch_at_negedge port map(
        CLK             => not CLK,
        RESET           => RESET,
        CD_or_CA        => next_lru,
        cache_data_addr => lru_bit
    );

    -- ======================================================================
    -- CHIP SELECT LOGIC
    -- ======================================================================
    
    -- Enable for chip 0, always opposite of chip_enable_1
    select_chip_0: inverter port map(
        input => chip_enable_1,
        output => chip_enable_0
    );
	
    -- Invert of is_hit_0
    inv_hit0: inverter port map(
    	input => is_hit_0,
        output => not_hit_0
    );
    
    -- Invert of is_hit_1
    inv_hit1: inverter port map(
    	input => is_hit_1,
        output => not_hit_1
    );
    
    -- Whether there is a hit in way 1 and miss in way 0.
    hit1miss0: and2 port map(
    	input1 => not_hit_0,
        input2 => is_hit_1,
        output => way1_hit
    );
    
    -- Decides whether to use the lru bit if both ways miss.
    use_lru: and3 port map(
    	A => not_hit_0,
        B => not_hit_1,
        C => lru_bit,
        Y => chosen_lru
    );
    
    -- Decides whether way 1's tag write should be enabled.
    chip_1_select: or2 port map(
    	input1 => way1_hit,
        input2 => chosen_lru,
        output => chip_enable_1
    );

    -- Whether way 0 should have its tag enabled set HIGH.
    chip_0_tag: and2 port map(
        input1 => tag_write_enable, 
        input2 => chip_enable_0,
        output => tag_write_0
    );
    
    -- Whether way 1 should have its tag enabled set HIGH.
    chip_1_tag: and2 port map(
        input1 => tag_write_enable, 
        input2 => chip_enable_1,
        output => tag_write_1
    );


end behavioral;
