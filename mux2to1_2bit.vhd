--
-- Entity: 2bit_mux2to1
-- Architecture: structural
-- Description: The mux for byte select, uses two bits instead of 1.
--
library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1_2bit is
    port(
        D0 : in std_logic_vector(1 downto 0);   -- Input 0
        D1 : in std_logic_vector(1 downto 0);   -- Input 1
        S  : in std_logic;   
        Y  : out std_logic_vector(1 downto 0)   -- Output
    );
end mux2to1_2bit;

architecture structural of mux2to1_2bit is
    component mux2to1 is 
    	port (
        	D0, D1 : in std_logic;
            S : in std_logic;
            Y : out std_logic
        );
    end component;
    
begin

    -- Mux for first bit.
    bit0: mux2to1 port map(
        D0 => D0(0), 
        D1 => D1(0), 
        S  => S, 
        Y  => Y(0)
    );

    -- Mux for second bit
    bit1: mux2to1 port map(
        D0 => D0(1), 
        D1 => D1(1), 
        S  => S, 
        Y  => Y(1)
    );
    
end structural;