--
-- Entity: and5
-- Architecture: structural
-- Description: AND gate for 5 inputs
--
library IEEE;
use IEEE.std_logic_1164.all;

entity and5 is 
	port (
    	A : in std_logic;
        B : in std_logic;
        C : in std_logic;
        D : in std_logic;
        E : in std_logic;
        Y : out std_logic
    );
end and5;

architecture structural of and5 is 
begin
	Y <= A and B and C and D and E;
end structural;