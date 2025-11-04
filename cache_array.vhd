--
-- Entity: cache_array
-- Architecture: structural
-- Description: Cache array for the cache.
--
library IEEE;
use IEEE.std_logic_1164.all;

entity cache_array is
    port(
        -- Data interface
        write_data : in std_logic_vector(7 downto 0);
        read_data : out std_logic_vector(7 downto 0);

        -- Full address breakdown
        block_select : in std_logic_vector(1 downto 0); -- which block
        byte_select : in std_logic_vector(1 downto 0);  -- which byte
        tag_in : in std_logic_vector(1 downto 0);               -- Tag to check/write

        -- Tag comparison output (for hit/miss detection)
        is_hit : out std_logic;
        tag_match : out std_logic;  -- does stored tag = tag_in?
        valid : out std_logic;       -- is this block valid?

        -- Control
        rd_wr : in std_logic;                           -- read or write
        tag_write_enable : in std_logic;        -- Update tag and valid
        valid_in : in std_logic;                        -- Valid bit to write
        RESET : in std_logic
    );
end cache_array;

architecture structural of cache_array is
        component decoder2to4 is
        port (
        A1, A0: in std_logic;
        E: in std_logic;
        Y3,Y2,Y1, Y0: out std_logic
        );
    end component;

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

    component mux4to1 is
        port (
                D0, D1, D2, D3 : in std_logic;
                S : in std_logic_vector(1 downto 0);
                Y : out std_logic
        );
    end component;

    component or2 is
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        output   : out std_logic);
    end component;

    component xnor2 is
        port (
                A : in std_logic;
            B : in std_logic;
            Y : out std_logic
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

    signal block_enable_0, block_enable_1, block_enable_2, block_enable_3 : std_logic;
    signal tag_out_0, tag_out_1, tag_out_2, tag_out_3 : std_logic_vector(1 downto 0);

    signal valid_out_0, valid_out_1, valid_out_2, valid_out_3 : std_logic;

    signal selected_tag : std_logic_vector(1 downto 0);
    signal selected_valid : std_logic;

        -- Signals for hit detection
        signal xnor_bit0, xnor_bit1 : std_logic;
    signal is_hit_internal : std_logic;
    signal block_enable_0_reset, block_enable_1_reset, block_enable_2_reset, block_enable_3_reset : std_logic;
    signal tag_write_enable_reset : std_logic;
begin
    -- Determines which block should be selected
        block_decoder: decoder2to4 port map(
        A1 => block_select(1),
        A0 => block_select(0),
        E  => not RESET,
        Y0 => block_enable_0,
        Y1 => block_enable_1,
        Y2 => block_enable_2,
        Y3 => block_enable_3
    );

    -- Block enables and reset logic.
    block0_en: or2 port map(
        input1 => block_enable_0,
        input2 => RESET,
        output => block_enable_0_reset
    );

    block1_en: or2 port map(
        input1 => block_enable_1,
        input2 => RESET,
        output => block_enable_1_reset
    );

    block2_en: or2 port map(
        input1 => block_enable_2,
        input2 => RESET,
        output => block_enable_2_reset
    );

    block3_en: or2 port map(
        input1 => block_enable_3,
        input2 => RESET,
        output => block_enable_3_reset
    );

    -- Tag enables and reset logic.
    tag_en: or2 port map(
        input1 => tag_write_enable,
        input2 => RESET,
        output => tag_write_enable_reset
    );

    -- Inputs data to chosen block. All blocks are chosen
    -- if reset is high.
    block_0: cache_block port map(
        write_data => write_data,
        read_data => read_data,
        byte_select => byte_select,
        tag_in => tag_in,
        tag_out => tag_out_0,
        valid_in => valid_in,
        valid_out => valid_out_0,
        block_enable => block_enable_0_reset,
        rd_wr => rd_wr,
        tag_write_enable => tag_write_enable_reset,
        RESET => RESET
    );

    block_1: cache_block port map(
        write_data => write_data,
        read_data => read_data,
        byte_select => byte_select,
        tag_in => tag_in,
        tag_out => tag_out_1,
        valid_in => valid_in,
        valid_out => valid_out_1,
        block_enable => block_enable_1_reset,
        rd_wr => rd_wr,
        tag_write_enable => tag_write_enable_reset,
        RESET => RESET
    );

    block_2: cache_block port map(
        write_data => write_data,
        read_data => read_data,
        byte_select => byte_select,
        tag_in => tag_in,
        tag_out => tag_out_2,
        valid_in => valid_in,
        valid_out => valid_out_2,
        block_enable => block_enable_2_reset,
        rd_wr => rd_wr,
        tag_write_enable => tag_write_enable_reset,
        RESET => RESET
    );

    block_3: cache_block port map(
        write_data => write_data,
        read_data => read_data,
        byte_select => byte_select,
        tag_in => tag_in,
        tag_out => tag_out_3,
        valid_in => valid_in,
        valid_out => valid_out_3,
        block_enable => block_enable_3_reset,
        rd_wr => rd_wr,
        tag_write_enable => tag_write_enable_reset,
        RESET => RESET
    );

        -- Select tag bit 0
    mux_tag_bit0: mux4to1 port map(
        D0 => tag_out_0(0),
        D1 => tag_out_1(0),
        D2 => tag_out_2(0),
        D3 => tag_out_3(0),
        S => block_select,
        Y => selected_tag(0)
    );

    -- Select tag bit 1
    mux_tag_bit1: mux4to1 port map(
        D0 => tag_out_0(1),
        D1 => tag_out_1(1),
        D2 => tag_out_2(1),
        D3 => tag_out_3(1),
        S => block_select,
        Y => selected_tag(1)
    );

    -- Select valid bit
    mux_valid_bit: mux4to1 port map(
        D0 => valid_out_0,
        D1 => valid_out_1,
        D2 => valid_out_2,
        D3 => valid_out_3,
        S => block_select,
        Y => selected_valid
    );

    -- Hit/Miss Detection
    hit_check_0: xnor2 port map(
        A => tag_in(0),
        B => selected_tag(0),
        Y => xnor_bit0
    );

    hit_check_1: xnor2 port map(
        A => tag_in(1),
        B => selected_tag(1),
        Y => xnor_bit1
    );

    hit_detector: and3 port map(
        A => xnor_bit0,
        B => xnor_bit1,
        C => selected_valid,
        Y => is_hit_internal
    );

    valid <= selected_valid;
    is_hit <= is_hit_internal;


end structural;