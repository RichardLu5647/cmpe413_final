--
-- Entity: mux4to1
-- Architecture: structural
-- Description: Multiplexor with 4 inputs.
--
library IEEE;
use IEEE.std_logic_1164.all;

entity mux4to1 is 
	port (
    	D0, D1, D2, D3 : in std_logic;
        S : in std_logic_vector(1 downto 0);
        Y : out std_logic
    );
end mux4to1;

architecture structural of mux4to1 is 
	component mux2to1 is 
    	port (
        	D0, D1 : in std_logic;
            S : in std_logic;
            Y : out std_logic
        );
    end component;
    
    signal stage1_out0 : std_logic;
    signal stage1_out1 : std_logic;
    
begin
	stage1_mux0: mux2to1 port map(
    	D0 => D0,
        D1 => D1,
        S => S(0),
        Y => stage1_out0
    );
    
    stage1_mux1: mux2to1 port map(
    	D0 => D2,
        D1 => D3,
        S => S(0),
        Y => stage1_out1
    );
    
    stage2_mux: mux2to1 port map(
    	D0 => stage1_out0,
        D1 => stage1_out1,
        S => S(1),
        Y => Y
    );
    

end structural;