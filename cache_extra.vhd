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

architecture structural of cache is

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

    -- Internal signals connecting controller to cache array
    signal is_hit_internal        : std_logic;
    signal read_data_internal     : std_logic_vector(7 downto 0);
    signal block_select_internal  : std_logic_vector(1 downto 0);
    signal byte_select_internal   : std_logic_vector(1 downto 0);
    signal tag_in_internal        : std_logic_vector(1 downto 0);
    signal write_data_internal    : std_logic_vector(7 downto 0);
    signal cache_rd_wr_internal   : std_logic;
    signal tag_write_enable_internal : std_logic;
    signal valid_in_internal      : std_logic;
    signal OUTPUT_ENABLE_internal : std_logic;

    -- Unused cache array outputs
    signal tag_match_unused       : std_logic;
    signal valid_unused           : std_logic;
    

begin

    -- ======================================================================
    -- CACHE CONTROLLER INSTANTIATION
    -- ======================================================================
    controller1: cache_fsm port map(
        -- System signals
        CLK           => CLK,
        RESET         => RESET,

        -- CPU interface (pass through to top level)
        START         => START,
        CHECK         => CHECK,
        CA            => CA,
        RD_WR         => RD_WR,
        CD            => CD,
        BUSY          => BUSY,
        OUTPUT_ENABLE => OUTPUT_ENABLE_internal,

        -- Cache interface (internal connections)
        is_hit        => is_hit_internal,
        read_data     => read_data_internal,
        block_select  => block_select_internal,
        byte_select   => byte_select_internal,
        tag_in        => tag_in_internal,
        write_data    => write_data_internal,
        cache_rd_wr   => cache_rd_wr_internal,
        tag_write_enable => tag_write_enable_internal,
        valid_in      => valid_in_internal,

        -- Memory interface (pass through to top level)
        MD            => MD,
        MA            => MA,
        ENABLE        => ENABLE
    );

    -- ======================================================================
    -- CACHE ARRAY INSTANTIATION
    -- ======================================================================

    cache_storage1: cache_array port map(
        -- Data interface (from/to controller)
        write_data => write_data_internal,
        read_data => read_data_internal,

        -- Address breakdown (from controller)
        block_select => block_select_internal,
        byte_select => byte_select_internal,
        tag_in => tag_in_internal,

        -- Tag comparison output (to controller)
        is_hit => is_hit_internal,
        tag_match => tag_match_unused,    -- Not used by controller
        valid => valid_unused,            -- Not used by controller

        -- Control signals (from controller)
        rd_wr => cache_rd_wr_internal,
        tag_write_enable => tag_write_enable_internal,
        valid_in => valid_in_internal,
        RESET => RESET
    );


      -- ======================================================================
    -- CACHE CONTROLLER INSTANTIATION
    -- ======================================================================
    controller2: cache_fsm port map(
        -- System signals
        CLK           => CLK,
        RESET         => RESET,

        -- CPU interface (pass through to top level)
        START         => START,
        CHECK         => CHECK,
        CA            => CA,
        RD_WR         => RD_WR,
        CD            => CD,
        BUSY          => BUSY,
        OUTPUT_ENABLE => OUTPUT_ENABLE_internal,

        -- Cache interface (internal connections)
        is_hit        => is_hit_internal,
        read_data     => read_data_internal,
        block_select  => block_select_internal,
        byte_select   => byte_select_internal,
        tag_in        => tag_in_internal,
        write_data    => write_data_internal,
        cache_rd_wr   => cache_rd_wr_internal,
        tag_write_enable => tag_write_enable_internal,
        valid_in      => valid_in_internal,

        -- Memory interface (pass through to top level)
        MD            => MD,
        MA            => MA,
        ENABLE        => ENABLE
    );

    -- ======================================================================
    -- CACHE ARRAY INSTANTIATION
    -- ======================================================================

    cache_storage2: cache_array port map(
        -- Data interface (from/to controller)
        write_data => write_data_internal,
        read_data => read_data_internal,

        -- Address breakdown (from controller)
        block_select => block_select_internal,
        byte_select => byte_select_internal,
        tag_in => tag_in_internal,

        -- Tag comparison output (to controller)
        is_hit => is_hit_internal,
        tag_match => tag_match_unused,    -- Not used by controller
        valid => valid_unused,            -- Not used by controller

        -- Control signals (from controller)
        rd_wr => cache_rd_wr_internal,
        tag_write_enable => tag_write_enable_internal,
        valid_in => valid_in_internal,
        RESET => RESET
    );


end structural;
