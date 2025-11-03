--
-- Entity: and4
-- Architecture: structural
-- Description: AND gate for 4 inputs
--
library IEEE;
use IEEE.std_logic_1164.all;

entity and4 is 
	port (
    	A : in std_logic;
        B : in std_logic;
        C : in std_logic;
        D : in std_logic;
        Y : out std_logic
    );
end and4;

architecture structural of and4 is 
begin
	Y <= A and B and C and D;
end structural;