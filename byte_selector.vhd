--
-- Entity: byte_selector
-- Architecture: structural
-- Description: Determines what bytes should the byte select should be.
--

library IEEE;
use IEEE.std_logic_1164.all;

entity byte_selector is
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
end byte_selector;

architecture structural of byte_selector is

    component mux2to1_2bit is
        port(
            D0 : in std_logic_vector(1 downto 0);   -- Input 0
            D1 : in std_logic_vector(1 downto 0);   -- Input 1
            S  : in std_logic;   
            Y  : out std_logic_vector(1 downto 0)   -- Output
        );
    end component;

    -- Temporary outputs for the muxes.
    signal mux00_out, mux01_out, mux10_out: std_logic_vector(1 downto 0);
    
begin

    -- Selects between 00 or cache byte
    mux00: mux2to1_2bit port map(
        D0 => cache_byte,
        D1 => byte_00,
        S  => byte_00_en,
        Y  => mux00_out
    );

    -- Selects between 01 or mux00_out
    mux01: mux2to1_2bit port map(
        D0 => mux00_out,
        D1 => byte_01,
        S  => byte_01_en,
        Y  => mux01_out
    );

    -- Selects between 10 or mux01_out
    mux10: mux2to1_2bit port map(
        D0 => mux01_out,
        D1 => byte_10,
        S  => byte_10_en,
        Y  => mux10_out
    );

    -- Selects between 11 or mux10_out
    mux11: mux2to1_2bit port map(
        D0 => mux10_out,
        D1 => byte_11,
        S  => byte_11_en,
        Y  => Y
    );

    
end structural;