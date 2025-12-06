--
-- Entity: demux1to2
-- Architecture : structural 
-- Description: 1 to 2 Demultiplexer.
--

library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity demux1to2 is
    port(
        D  : in  std_logic;         
        S  : in  std_logic;         
        Y0 : out std_logic;         
        Y1 : out std_logic          
    );
end demux1to2;

architecture structural of demux1to2 is

    -- Component declarations
    component inverter is
        port(
            input  : in  std_logic;
            output : out std_logic
        );
    end component;

    component and2 is
        port(
            a : in std_logic;
            b : in std_logic;
            y : out std_logic
        );
    end component;

    -- internal signal
    signal S_bar : std_logic;

begin

    -- invert select
    inv1: inverter port map(
        input  => S,
        output => S_bar
    );

    and_low: and2 port map(
        a => D,
        b => S_bar,
        y => Y0
    );

    and_high: and2 port map(
        a => D,
        b => S,
        y => Y1
    );

end structural;

