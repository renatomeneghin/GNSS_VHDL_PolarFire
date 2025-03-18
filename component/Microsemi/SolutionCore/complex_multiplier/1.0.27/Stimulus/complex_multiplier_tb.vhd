/*****************************************************************************************************************************
--
--    File Name    : complex_multiplier_tb.vhd 

--    Description  : This module provides the test environment for complex multiplier IP.	


-- Targeted device : Microsemi-SoC                     
-- Author          : India Solutions Team

-- SVN Revision Information:
-- SVN $Revision: TBD
-- SVN $Date: TBD
--
--
--
-- COPYRIGHT 2018 BY MICROSEMI 
-- THE INFORMATION CONTAINED IN THIS DOCUMENT IS SUBJECT TO LICENSING RESTRICTIONS 
-- FROM MICROSEMI CORP.  IF YOU ARE NOT IN POSSESSION OF WRITTEN AUTHORIZATION FROM 
-- MICROSEMI FOR USE OF THIS FILE, THEN THE FILE SHOULD BE IMMEDIATELY DESTROYED AND 
-- NO BACK-UP OF THE FILE SHOULD BE MADE. 
-- 

--******************************************************************************************************************************/

library ieee;
use ieee.std_logic_1164.all;

entity complex_multiplier_tb is
end complex_multiplier_tb;

architecture behavioral of complex_multiplier_tb is

    constant SYSCLK_PERIOD : time := 10 ns; -- 10MHZ
-----------------------------------------------------------
-- Core parameters
-----------------------------------------------------------
    constant G_AWIDTH   : integer := 16; 
    constant G_BWIDTH   : integer := 16;  
    constant G_3DSP     : integer :=  1; 
    constant G_DOROUND  : integer :=  0; 
    constant G_CWIDTH   : integer := 33; 

    signal SYSCLK       :  std_logic := '0';
    signal NSYSRESET    :  std_logic := '0';
    signal areal_i      :  std_logic_vector(G_AWIDTH-1 downto 0);
    signal aimag_i      :  std_logic_vectOR(G_AWIDTH-1 downto 0);
    signal breal_i      :  STD_logic_vector(G_BWIDTH-1 downto 0);
    signal bimag_i      :  STD_LOGIC_VECTOR(G_BWIDTH-1 downto 0);
    signal creal_o      :  STd_logic_vector(G_CWIDTH-1 downto 0);
    signal cimag_o      :  STD_LOGIC_VECTOR(G_CWIDTH-1 downto 0);

    component complex_multiplier
       generic (g_aWIDTH    : integer := 16;
                g_bwidth    : INTEGER := 16;
                g_3dsp      : INTEGER := 1;
                G_DOROUND   : INTEGER := 0;
                g_cwidTH    : intEGER := 33); 
        port (
                CLock_i: in sTD_LOGIC;
                NRESET_I: in STD_LOGIC;
                areal_i: in std_logic_vector(g_awidth-1 downto 0);
                aimAG_I: in std_logic_vectOR(G_AWIDTH-1 downto 0);
                breal_I: in STD_logic_vector(G_BWidth-1 downto 0);
                bimag_i: in STD_LOGIC_VECTOR(g_bwidth-1 downto 0);
                creal_o: out STd_logic_vector(G_CWIDTH-1 downto 0);
                CIMAG_O: out STD_LOGIC_VECTOR(g_cwidth-1 downto 0)
            );
    end component;

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '0';
            areal_i   <= x"0000";
            aimag_i   <= x"0000";
            breal_i   <= x"0000";
            bimag_i   <= x"0000";
            wait for ( SYSCLK_PERIOD * 10 );            
            NSYSRESET <= '1';
            wait for ( SYSCLK_PERIOD * 1 );
            areal_i   <= x"1234";
            aimag_i   <= x"fff0";
            breal_i   <= x"7456";
            bimag_i   <= x"c024";
            wait for ( SYSCLK_PERIOD * 1 );
            areal_i   <= x"D002";
            aimag_i   <= x"1000";
            breal_i   <= x"5000";
            bimag_i   <= x"6000";
            wait for ( SYSCLK_PERIOD * 1 );
            areal_i   <= x"0002";
            aimag_i   <= x"0003";
            breal_i   <= x"0004";
            bimag_i   <= x"0005";
           

            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

    -- Instantiate Unit Under Test:  test
    test_0 : complex_multiplier
       generic map(
                g_aWIDTH    => G_AWIDTH,
                g_bwidth    => G_BWIDTH,
                g_3dsp      => G_3DSP,
                G_DOROUND   => G_DOROUND,
                g_cwidTH    => G_CWIDTH
                  )
        port map( 
                CLock_i     => SYSCLK,
                NRESET_I    => NSYSRESET,
                areal_i     => areal_i,
                aimAG_I     => aimag_i,
                breal_I     => breal_i,
                bimag_i     => bimag_i,
                creal_o     => creal_o,
                CIMAG_O     => cimag_o
                );

end behavioral;

