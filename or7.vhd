--
-- Entity: or7
-- Architecture: structural
-- Description: OR gate for 7 inputs
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity or7 is

  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    input3   : in std_logic;
    input4   : in  std_logic;
    input5   : in  std_logic;
    input6   : in std_logic;
    input7   : in std_logic;
    output   : out std_logic);
end or7;

architecture structural of or7 is

begin

  output <= input7 or input6 or input5 or input4 or input3 or input2 or input1;

end structural;
