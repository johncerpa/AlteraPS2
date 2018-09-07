library ieee;
use ieee.std_logic_1164.all;

-----------------------------------------------------
entity Workshop is
port(
	-- PS2 Keyboard
	ps2_data: in std_logic;
	ps2_clock: in std_logic;
	
	-- Keyboard output
	output: out std_logic_vector(10 downto 0);
		
	-- 7 Segment Displays
	firstDigit_display: out std_logic_vector(6 downto 0);
	secondDigit_display: out std_logic_vector(6 downto 0);

	clk:		in std_logic;    --Clock to keep trak of time
	lcd:		out std_logic_vector(7 downto 0);  --LCD data pins
	enviar : out std_logic;    --Send signal (Enable)
	rs:		out std_logic;    --Data or command
	rw: out std_logic    --read/write
);
end Workshop;
-----------------------------------------------------

architecture FSM of Workshop is
   -- Define dfferent states to control the LCD 
	type state_type is (encender, configpantalla, encenderdisplay, limpiardisplay, configcursor, listo, fin); 
   signal estado: state_type;
	 
	constant milisegundos: integer := 50000; -- 1 millisecond
	constant microsegundos: integer := 50;
	 
	 -- Keyboard variables
	signal i: integer := 0; -- Counter
	signal ibm_code: std_logic_vector(10 downto 0);
	
	signal actu:integer:=0;
	signal post:integer:=0;
	
	function ibm_to_ascii(
		input: std_logic_vector(7 downto 0))
		return std_logic_vector is
		variable ascii : std_logic_vector(7 downto 0);
	begin
	
		case input is 		
			when X"1C"  => ascii := "01000001";--A
			when X"32"  => ascii := "01000010";--B
			when X"21"  => ascii := "01000011";--C
			when X"23"  => ascii := "01000100";--D
			when X"24"  => ascii := "01000101";--E
			when X"2B"  => ascii := "01000110";--F
			when X"34"  => ascii := "01000111";--G
			when X"33"  => ascii := "01001000";--H
			when X"43"  => ascii := "01001001";--I
			when X"3B"  => ascii := "01001010";--J
			when X"42"  => ascii := "01001011";--K
			when X"4B"  => ascii := "01001100";--L
			when X"3A"  => ascii := "01001101";--M
			when X"31"  => ascii := "01001110";--N
			when X"44"  => ascii := "01001111";--O
			when X"4D"  => ascii := "01010000";--P
			when X"15"  => ascii := "01010001";--Q
			when X"2D"  => ascii := "01010010";--R
			when X"1B"  => ascii := "01010011";--S
			when X"2C"  => ascii := "01010100";--T
			when X"3C"  => ascii := "01010101";--U
			when X"2A"  => ascii := "01010110";--V
			when X"1D"  => ascii := "01010111";--W
			when X"22"  => ascii := "01010111";--Y
			when X"35"  => ascii := "01011001";--X
			when X"1A"  => ascii := "01011010";--Z
			when X"45"  => ascii := "00110000";--0
			when X"16"  => ascii := "00110001";--1
			when X"1E"  => ascii := "00110010";--2
			when X"26"  => ascii := "00110011";--3
			when X"25"  => ascii := "00110100";--4
			when X"2E"  => ascii := "00110101";--5
			when X"36"  => ascii := "00110110";--6
			when X"3D"  => ascii := "00110111";--7
			when X"3E"  => ascii := "00111000";--8
			when X"46"  => ascii := "00111001";--9
			when X"29"  => ascii := "00100000";-- Space
			when others => ascii := "00000000";
		end case;
		
		return ascii;
	end;
	
	
	function binary_to_display(
		input: std_logic_vector(3 downto 0)) -- It takes a 4 bit length vector as an input
		return std_logic_vector is
		variable output : std_logic_vector(6 downto 0); -- Returns vector that represents an hexadecimal value on the display
	begin
		if (input = "0000") then --0
			output := "1000000";
		elsif (input = "0001") then --1
			output := "1111001";
		elsif (input = "0010") then --2
			output := "0100100";
		elsif (input = "0011") then --3 
			output := "0110000";
		elsif (input = "0100") then --4
			output := "0011001";
		elsif (input = "0101") then --5
			output := "0010010";
		elsif (input = "0110") then --6
			output := "0000010";
		elsif (input = "0111") then --7
			output := "1111000";
		elsif (input = "1000") then --8
			output := "0000000";
		elsif (input = "1001") then --9
			output := "0010000";
		elsif (input = "1010") then --A
			output := "0001000";
		elsif (input = "1011") then --B
			output := "0000011";
		elsif (input = "1100") then --C
			output := "1000110";
		elsif (input = "1101") then --D
			output := "0100001";
		elsif (input = "1110") then --E
			output := "0000100";
		elsif (input = "1111") then --F
			output := "0001110";
		end if;
		return output;		
	end;
	 
begin
  comb_logic: process(clk)
  variable contar: integer := 0;
  variable lineas : integer := 0;
  begin
	if (clk'event and clk='1') then
	  case estado is
	    when encender =>
		  if (contar < 50*milisegundos) then    --Wait for the LCD to start all its components
				contar := contar + 1;
				estado <= encender;
			else
				enviar <= '0';
				contar := 0; 
				estado <= configpantalla;
			end if;
			--From this point we will send diffrent configuration commands as shown in class
			--You should check the manual to understand what configurations we are sending to
			--The display. You have to wait between each command for the LCD to take configurations.
	    when configpantalla =>
			if (contar = 0) then
				contar := contar +1;
				rs <= '0';
				rw <= '0';
				lcd <= "00111000";
				enviar <= '1';
				estado <= configpantalla;
			elsif (contar < 1*milisegundos) then
				contar := contar + 1;
				estado <= configpantalla;
			else
				enviar <= '0';
				contar := 0;
				estado <= encenderdisplay;
			end if;
	    when encenderdisplay =>
			if (contar = 0) then
				contar := contar +1;
				lcd <= "00001111";				
				enviar <= '1';
				estado <= encenderdisplay;
			elsif (contar < 1*milisegundos) then
				contar := contar + 1;
				estado <= encenderdisplay;
			else
				enviar <= '0';
				contar := 0;
				estado <= limpiardisplay;
			end if;
	    when limpiardisplay =>	
			if (contar = 0) then
				contar := contar +1;
				lcd <= "00000001";				
				enviar <= '1';
				estado <= limpiardisplay;
			elsif (contar < 1*milisegundos) then
				contar := contar + 1;
				estado <= limpiardisplay;
			else
				enviar <= '0';
				contar := 0;
				estado <= configcursor;
			end if;
	    when configcursor =>	
			if (contar = 0) then
				contar := contar +1;
				lcd <= "00000100";				
				enviar <= '1';
				estado <= configcursor;
			elsif (contar < 1*milisegundos) then
				contar := contar + 1;
				estado <= configcursor;
			else
				enviar <= '0';
				contar := 0;
				estado <= listo;
			end if;
			--The display is now configured now it you just can send data to de LCD 
			--In this example we are just sending letter A, for this project you
			--Should make it variable for what has been pressed on the keyboard.
	    when listo =>	
		 
			if (contar = 0 and ibm_code(8 downto 1) = X"F0" and i = 10) then -- F0, don't do anything and make post = 1
				post <= 1;
			elsif (post = 1 and i = 10) then -- It goes here and doesn't go to next elsif, post = 0 so you can keep typing new letters
				post <= 0;
			elsif (contar = 0  and ibm_code(8 downto 1) /= X"F0" and post = 0)then -- First time, it sends the letter to LCD
				
				if (lineas <= 15 or (lineas >= 40 and lineas < 66-9)) then
					if (i = 10) then
						rs <= '1';
						rw <= '0';
						enviar <= '1';
						lcd <= ibm_to_ascii(ibm_code(8 downto 1)); -- ascii
						contar := contar + 1;
						estado <= listo;
						lineas := lineas + 1;
					end if;
				elsif (lineas >= 15 and lineas <= 40) then
					rs <= '1';
					rw <= '0';
					enviar <= '1';
					lcd <= ibm_to_ascii(ibm_code(8 downto 1)); -- ascii
					contar := contar + 1;
					estado <= listo;
					lineas := lineas + 1;
				elsif (lineas >= 66 - 9) then
					rs <= '1';
					rw <= '0';
					enviar <= '1';
					estado <= encender;
					contar := 0;
					lineas := 0;
				end if;
				
				
			elsif (contar < 5 * milisegundos) then -- Wait 2 milliseconds
				contar := contar + 1;
				estado <= listo;
			else
				enviar <= '0';
				contar := 0;
				estado <= fin;
			end if;
		when fin =>
				estado <= listo;
	    when others =>
			estado <= encender;
	  end case;
	end if;
	
 end process;
 
 ps2_process : process(ps2_clock)
 -- variables
 begin
 
	if (ps2_clock'EVENT and ps2_clock = '0' and i < 11) then		
	
		ibm_code(i) <= ps2_data;

		i <= (i + 1) mod 11;	
				
		if (i = 10) then -- STOP
				
			firstDigit_display <= binary_to_display(ibm_code(4 downto 1));
			secondDigit_display <= binary_to_display(ibm_code(8 downto 5));
		end if;			
		
	end if;
		 
 end process;
 
end FSM;
