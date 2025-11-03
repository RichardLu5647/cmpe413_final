--
-- Entity: xnor3
-- Architecture: structural
-- Description: XOR's two inputs
--
library IEEE;
use IEEE.std_logic_1164.all;

entity xnor2 is 
	port (
    	A : in std_logic;
    	B : in std_logic;
    	Y : out std_logic
    );
end xnor2;

architecture structural of xnor2 is 
begin
	Y <= A xnor B;
    

end structural;