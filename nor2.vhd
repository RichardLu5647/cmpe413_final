--
-- Entity: nor2
-- Architecture: structural
-- Description: NOR gate for 2 inputs
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity nor2 is

  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    output   : out std_logic);
end nor2;

architecture structural of nor2 is
    component inverter is 
    	port (
        	input : in std_logic;
            output : out std_logic
        );
    end component;

    signal not_output : std_logic;

begin

    inv: inverter port map(
        input => not_output,
        output => output
    );

    not_output <= input2 or input1;

end structural;