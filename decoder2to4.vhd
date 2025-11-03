--
-- Entity: decoder2to4
-- Architecture: structural
-- Description: Decoder that takes two inputs and outputs 4.
--
library IEEE;
use IEEE.std_logic_1164.all;

entity decoder2to4 is 
	port (
    	A1, A0: in std_logic;
        E: in std_logic;
        Y3,Y2,Y1, Y0: out std_logic
    );
end decoder2to4;

architecture structural of decoder2to4 is
	component inverter is
    	port(
        	input: in std_logic;
        	output: out std_logic
        );
    end component;
    
    component and2 is 
    	port(
        	input1: in std_logic;
            input2: in std_logic;
            output: out std_logic
        );
    end component;

	signal A1_not, A0_not: std_logic;
    signal and_temp0, and_temp1, and_temp2, and_temp3: std_logic;
    
begin 
	INV1: inverter port map(
    	input => A1,
        output => A1_not
    );
    
    INV2: inverter port map(
    	input => A0,
        output => A0_not
    );
    
    AND_Y0_1: and2 port map(
    	input1 => A1_not,
        input2 => A0_not,
        output => and_temp0
    );
    
    AND_Y0_2: and2 port map(
    	input1 => and_temp0,
        input2 => E,
        output => Y0
    );
    
    AND_Y1_1: and2 port map(
    	input1 => A1_not,
        input2 => A0,
        output => and_temp1
    );
    
    AND_Y1_2: and2 port map(
    	input1 => and_temp1,
        input2 => E,
        output => Y1
    );
    
    AND_Y2_1: and2 port map(
    	input1 => A1,
        input2 => A0_not,
        output => and_temp2
    );
    
    AND_Y2_2: and2 port map(
    	input1 => and_temp2,
        input2 => E,
        output => Y2
    );
    
    AND_Y3_1: and2 port map(
    	input1 => A1, 
        input2 => A0,
        output => and_temp3
    );
    
    AND_Y3_2: and2 port map(
    	input1 => and_temp3,
        input2 => E,
        output => Y3
    );
end structural;