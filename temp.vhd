--
-- Entity: cache
-- Architecture : structural (top-level cache system)
-- Author: Generated for structural cache controller project
-- Description: Top-level module integrating cache controller and cache array
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity cache is
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
end cache;

architecture behavioral of cache is

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
            
            array_enable : in std_logic;

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
    
    component latch_at_posedge is
    port(
        CLK             : in  std_logic;
        RESET           : in  std_logic;  
        CD_or_CA        : in std_logic;
        cache_data_addr : out std_logic
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

    component xnor2 is 
        port (
            A : in std_logic;
            B : in std_logic;
            Y : out std_logic
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
    signal read_data_0, read_data_1    : std_logic_vector(7 downto 0);
    signal block_select_0, block_select_1  : std_logic_vector(1 downto 0);
    signal byte_select_0, byte_select_1   : std_logic_vector(1 downto 0);
    signal tag_in_0, tag_in_1      : std_logic_vector(1 downto 0);
    signal write_data_0, write_data_1    : std_logic_vector(7 downto 0);
    signal rd_wr_0, rd_wr_1  : std_logic;
    signal tag_write_enable_0, tag_write_enable_1 : std_logic;
    signal valid_in_0, valid_in_1      : std_logic;
    signal OUTPUT_ENABLE_0, OUTPUT_ENABLE_1 : std_logic;

    signal chip_enable_0, chip_enable_1 : std_logic;

    -- Unused cache array outputs
    signal tag_match_unused       : std_logic;
    signal valid_unused           : std_logic;

    -- Hit Miss Detection Logic Signals
    signal check_enable_pos, check_enable_neg : std_logic;
    signal not_check_enable_neg : std_logic;
    
    signal start_q, start_not_q   : std_logic;
    signal start_pos              : std_logic;

    signal clear_q                : std_logic;
    signal clear_pulse            : std_logic;

    signal next_check_enable      : std_logic;
    signal check_enable           : std_logic;
    signal check_enable1, check_enable2 : std_logic;



    -- Chip addresses
    signal storage_0_byte_select  : std_logic_vector(1 downto 0);
    signal storage_0_tag_in       : std_logic_vector(1 downto 0);
    signal storage_0_block_select : std_logic_vector(1 downto 0);

    signal storage_1_byte_select  : std_logic_vector(1 downto 0);
    signal storage_1_tag_in       : std_logic_vector(1 downto 0);
    signal storage_1_block_select : std_logic_vector(1 downto 0);

    -- Chip read writes
    signal storage_0_rd_wr        : std_logic;
    signal storage_1_rd_wr        : std_logic;

    -- LRU Bit signals
    signal lru_set                : std_logic;
    signal lru_bit                : std_logic;
    signal updated_lru_bit        : std_logic;
    signal next_lru               : std_logic;
    signal not_busy, busy_d, busy_edge            : std_logic;  

    -- LRU Logic Signals
    signal cache_mux_select : std_logic;

    -- Mux input output
    signal CD_0, CD_1             : std_logic_vector(7 downto 0);
    signal MD_0, MD_1             : std_logic_vector(7 downto 0);
    signal MA_0, MA_1             : std_logic_vector(5 downto 0);
    signal CA_0, CA_1             : std_logic_vector(5 downto 0);
    signal OUTPUT_ENABLE          : std_logic;
    signal BUSY_0, BUSY_1         : std_logic;
    signal ENABLE_0, ENABLE_1     : std_logic;
    
    signal latched_hit_0, latched_hit_1 : std_logic;
    signal start_0, start_1       : std_logic;


begin


    -- ======================================================================
    -- CHIP 0 INSTANTIATION
    -- ======================================================================

    fsm_0: cache_fsm port map(
        -- System signals
        CLK           => CLK,
        RESET         => RESET,

        -- CPU interface (pass through to top level)
        START         => start_0,
        CA            => CA,
        RD_WR         => RD_WR,
        CD            => CD,
        BUSY          => BUSY_0,
        OUTPUT_ENABLE => OUTPUT_ENABLE_0,

        -- Cache interface (internal connections)
        is_hit        => is_hit_0,
        read_data     => read_data_0,
        block_select  => block_select_0,
        byte_select   => byte_select_0,
        tag_in        => tag_in_0,
        write_data    => write_data_0,
        cache_rd_wr   => rd_wr_0,
        tag_write_enable => tag_write_enable_0,
        valid_in      => valid_in_0,

        -- Memory interface (pass through to top level)
        MD            => MD_0,
        MA            => MA_0,
        ENABLE        => ENABLE_0
    );


    storage_0: cache_array port map(
        -- Data interface (from/to controller)
        write_data => write_data_0,

        read_data => read_data_0,

        -- Enable (From top module)
        array_enable => chip_enable_0,

        -- Address breakdown (from controller)
        block_select => block_select_0,
        byte_select => byte_select_0,
        tag_in => tag_in_0,

        -- Tag comparison output (to controller)
        is_hit => is_hit_0,
        tag_match => tag_match_unused,    -- Not used by controller
        valid => valid_unused,            -- Not used by controller

        -- Control signals (from controller)
        rd_wr => rd_wr_0,
        tag_write_enable => tag_write_enable_0 and chip_enable_0,
        valid_in => valid_in_0,
        RESET => RESET
    );


    -- ======================================================================
    -- CHIP 1 INSTANTIATION
    -- ======================================================================

    fsm_1: cache_fsm port map(
        -- System signals
        CLK           => CLK,
        RESET         => RESET,

        -- CPU interface (pass through to top level)
        START         => start_1,
        CA            => CA,
        RD_WR         => RD_WR,
        CD            => CD,
        BUSY          => BUSY_1,
        OUTPUT_ENABLE => OUTPUT_ENABLE_1,

        -- Cache interface (internal connections)
        is_hit        => is_hit_1,
        read_data     => read_data_1,
        block_select  => block_select_1,
        byte_select   => byte_select_1,
        tag_in        => tag_in_1,
        write_data    => write_data_1,
        cache_rd_wr   => rd_wr_1,
        tag_write_enable => tag_write_enable_1,
        valid_in      => valid_in_1,

        -- Memory interface (pass through to top level)
        MD            => MD_1,
        MA            => MA_1,
        ENABLE        => ENABLE_1
    );


    storage_1: cache_array port map(
        -- Data interface (from/to controller)
        write_data => write_data_1,

        read_data => read_data_1,

        -- Enable (From top module)
        array_enable => chip_enable_1,

        -- Address breakdown (from controller)
        block_select => block_select_1,
        byte_select => byte_select_1,
        tag_in => tag_in_1,

        -- Tag comparison output (to controller)
        is_hit => is_hit_1,
        tag_match => tag_match_unused,    -- Not used by controller
        valid => valid_unused,            -- Not used by controller

        -- Control signals (from controller)
        rd_wr => rd_wr_1,
        tag_write_enable => tag_write_enable_1 and chip_enable_1,
        valid_in => valid_in_1,
        RESET => RESET
    );

    -- ======================================================================
    -- CHIP SELECT LOGIC
    -- ======================================================================  
/*
    check_enabler: and2 port map(
        input1 => START,
        input2 => not BUSY,
        output => check_enable
    );
    */
    



    -- Previous START value
    start_d_ff : latch_at_posedge port map(
        CLK             => CLK,
        RESET           => RESET,
        CD_or_CA        => START,
        cache_data_addr => check_enable1
    );

    -- NOT(start_d)
    inv_start_d : inverter port map(
        input  => check_enable1,
        output => check_enable2
    );

    -- Detect START rise (1 for exactly one clock cycle)
    start_pos_and : and2 port map(
        input1 => START,
        input2 => check_enable2,
        output => check_enable
    );


    /*
    check_enabler: latch_at_posedge port map(
        CLK             => START,
        RESET           => RESET,  
        CD_or_CA        => '1',
        cache_data_addr => check_enable
    );
    */
    
    -------------------------------------------------------------------------------
    -- TAG SELECT LOGIC
    -------------------------------------------------------------------------------
    -- Pass tag from FSM normally, or pass CPU address tag during check_enable
    tag_selector_0 : for i in 0 to 1 generate
        tag_selector_mux_0 : mux2to1 port map(
            D0 => tag_in_0(i),         -- Hold FSM value
            D1 => CA(4 + i),           -- Incoming address tag bits
            S  => check_enable,
            Y  => storage_0_tag_in(i)
        );
    end generate;

    tag_selector_1 : for i in 0 to 1 generate
        tag_select_mux_1 : mux2to1 port map(
            D0 => tag_in_1(i),
            D1 => CA(4 + i),
            S  => check_enable,
            Y  => storage_1_tag_in(i)
        );
    end generate;


    -------------------------------------------------------------------------------
    -- BLOCK SELECT LOGIC
    -------------------------------------------------------------------------------
    block_selector_0 : for i in 0 to 1 generate
        block_select_mux_0 : mux2to1 port map(
            D0 => block_select_0(i),
            D1 => CA(2 + i),
            S  => check_enable,
            Y  => storage_0_block_select(i)
        );
    end generate;

    block_selector_1 : for i in 0 to 1 generate
        block_select_mux_1 : mux2to1 port map(
            D0 => block_select_1(i),
            D1 => CA(2 + i),
            S  => check_enable,
            Y  => storage_1_block_select(i)
        );
    end generate;


    -------------------------------------------------------------------------------
    -- BYTE SELECT LOGIC
    -------------------------------------------------------------------------------
    byte_selector_0 : for i in 0 to 1 generate
        byte_select_mux_0 : mux2to1 port map(
            D0 => byte_select_0(i),
            D1 => CA(i),
            S  => check_enable,
            Y  => storage_0_byte_select(i)
        );
    end generate;

    byte_selector_1 : for i in 0 to 1 generate
        byte_select_mux_1 : mux2to1 port map(
            D0 => byte_select_1(i),
            D1 => CA(i),
            S  => check_enable,
            Y  => storage_1_byte_select(i)
        );
    end generate;


    -------------------------------------------------------------------------------
    -- RD/WR OVERRIDE DURING CHECK
    -- During check_enable, all reads must be forced (rd_wr = 1)
    -------------------------------------------------------------------------------
    rd_wr_enable_mux_0 : mux2to1 port map(
        D0 => rd_wr_0,       -- normal FSM-controlled read/write
        D1 => '1',           -- force read during check
        S  => check_enable,
        Y  => storage_0_rd_wr
    );

    rd_wr_enable_mux_1 : mux2to1 port map(
        D0 => rd_wr_1,
        D1 => '1',
        S  => check_enable,
        Y  => storage_1_rd_wr
    );

/*
    latch_hit0: latch_at_posedge port map(
        CLK             => CLK,
        RESET           => RESET,
        CD_or_CA        => is_hit_0,
        cache_data_addr => latched_hit_0
    );

    latch_hit1: latch_at_posedge port map(
        CLK             => CLK,
        RESET           => RESET,
        CD_or_CA        => is_hit_1,
        cache_data_addr => latched_hit_1
    );
    */
    



    -- ======================================================================
    -- LRU BIT LOGIC
    -- ======================================================================

    -- The new lru is always the opposite of the current lru.
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

    detect_busy: latch_at_posedge port map(
        CLK             => CLK,
        RESET           => RESET,
        CD_or_CA        => BUSY,
        cache_data_addr => busy_d
    );

    inv_busy: inverter port map(
        input => BUSY,
        output => not_busy
    );

    -- Detects negedge BUSY
    busy_edge_and: and2 port map(
        input1 => not_busy,
        input2 => busy_d,
        output => busy_edge
    );

    -- stores LRU bit
    store_lru: latch_at_posedge port map(
        CLK             => CLK,
        RESET           => RESET,
        CD_or_CA        => next_lru,
        cache_data_addr => lru_bit
    );

    -- ======================================================================
    -- LRU LOGIC
    -- ======================================================================

    -- Whether to select the LRU bit or the chip that had a hit.
    cache_mux_selector: xnor2 port map(
        A => is_hit_0,
        B => is_hit_1,
        Y => cache_mux_select
    );

    cache_selector: mux2to1 port map(
        D0 => is_hit_1,
        D1 => lru_bit,      
        S  => cache_mux_select,    
        Y  => chip_enable_1
    );

    -- Selects which chip to use.

    -- Enable for chip 0
    select_chip_0: inverter port map(
        input => chip_enable_1,
        output => chip_enable_0
    );

    -- Memory Address Output from selected chip.
    mem_address_out: for i in 0 to 5 generate
        cache_data_mux: mux2to1 port map(
            D0 => MA_0(i), 
            D1 => MA_1(i),         
            S  => chip_enable_1,    
            Y  => MA(i)
        );
    end generate;
    
    -- memory output enable from selected chip.
    mem_enable0: mux2to1 port map(
    	D0 => ENABLE_0,
        D1 => ENABLE_1,
        S => chip_enable_1,
        Y => ENABLE
    );
    
    -- memory output enable from selected chip.
    mem_enable1: mux2to1 port map(
    	D0 => BUSY_0,
        D1 => BUSY_1,
        S => chip_enable_1,
        Y => BUSY
    );

    -- memory data in.
    mem_data_in: for i in 0 to 7 generate
        mem_data_demux: demux1to2 port map(
            D => MD(i),
            S => chip_enable_1,
            Y0 => MD_0(i),
            Y1 => MD_1(i)
        );
    end generate;
    
    start_demux: demux1to2 port map(
            D => START,
            S => chip_enable_1,
            Y0 => start_0,
            Y1 => start_1
        );


end behavioral;
