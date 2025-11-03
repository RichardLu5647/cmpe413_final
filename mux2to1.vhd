--
-- Entity: mux2to1
-- Architecture: structural
-- Description: Multiplexor that decided which data to output.
--
library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1 is
    port(
        D0 : in std_logic;   -- Input 0
        D1 : in std_logic;   -- Input 1
        S  : in std_logic;   -- Select (0=D0, 1=D1)
        Y  : out std_logic   -- Output
    );
end mux2to1;

architecture structural of mux2to1 is
    component and2 is
        port(
            input1 : in std_logic;
            input2 : in std_logic;
            output : out std_logic
        );
    end component;
    
    component or2 is
        port(
            input1 : in std_logic;
            input2 : in std_logic;
            output : out std_logic
        );
    end component;
    
    component inverter is
        port(
            input : in std_logic;
            output : out std_logic
        );
    end component;
    
    signal S_not : std_logic;
    signal and_out0, and_out1 : std_logic;
    
begin
    -- Invert select
    inv: inverter port map(
        input => S,
        output => S_not
    );
    
    -- AND gates
    and0: and2 port map(
        input1 => D0,
        input2 => S_not,  -- Select D0 when S=0
        output => and_out0
    );
    
    and1: and2 port map(
        input1 => D1,
        input2 => S,      -- Select D1 when S=1
        output => and_out1
    );
    
    -- OR gate
    or_gate: or2 port map(
        input1 => and_out0,
        input2 => and_out1,
        output => Y
    );
    

end structural;