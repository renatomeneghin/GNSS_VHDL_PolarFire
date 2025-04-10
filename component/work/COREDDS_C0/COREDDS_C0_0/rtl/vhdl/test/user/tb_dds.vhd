-- ***************************************************************************/
--Microsemi Corporation Proprietary and Confidential
--Copyright 2016 Microsemi Corporation. All rights reserved.
--
--ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
--ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
--IN ADVANCE IN WRITING.
--
--Description:  CoreDDS
--              User testbench
--
--Revision Information:
--Date         Description
--26Aug2016    Initial Release
--
--SVN Revision Information:
--SVN $Revision: $
--SVN $Data: $
--
--Resolved SARs
--SAR     Date    Who         Description
--

LIBRARY IEEE;
  USE IEEE.std_logic_1164.all;
  USE IEEE.NUMERIC_STD.all;
LIBRARY STD;
  USE IEEE.STD_LOGIC_TEXTIO.ALL;
  USE STD.textio.all;
USE work.bhv_pack.all;
USE work.coreparameters.all;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE bhv OF testbench IS
  COMPONENT COREDDS_C0_COREDDS_C0_0_COREDDS IS
    GENERIC (
      PH_ACC_BITS             : INTEGER;
      PH_INC_MODE             : INTEGER;
      PH_INC                  : INTEGER;
      SIN_ON                  : INTEGER;
      COS_ON                  : INTEGER;
      SIN_POLARITY            : INTEGER;
      COS_POLARITY            : INTEGER;
      FREQ_OFFSET_BITS        : INTEGER;
      PH_OFFSET_MODE          : INTEGER;
      PH_OFFSET_CONST         : INTEGER;
      PH_OFFSET_BITS          : INTEGER;
      PH_CORRECTION           : INTEGER;
      QUANTIZER_BITS          : INTEGER;
      OUTPUT_BITS             : INTEGER;
      LATENCY                 : INTEGER;
      URAM_MAXDEPTH           : INTEGER;
      FPGA_FAMILY             : INTEGER;
      DIE_SIZE                : INTEGER;
      -- Use in Standalone only
      MAX_FULL_WAVE_LOGDEPTH  : INTEGER  );
    PORT (
      FREQ_OFFSET             : IN STD_LOGIC_VECTOR(FREQ_OFFSET_BITS - 1 DOWNTO 0);
      FREQ_OFFSET_WE          : IN STD_LOGIC;
      PH_OFFSET               : IN STD_LOGIC_VECTOR(PH_OFFSET_BITS - 1 DOWNTO 0);
      PH_OFFSET_WE            : IN STD_LOGIC;
      SINE                    : OUT STD_LOGIC_VECTOR(OUTPUT_BITS - 1 DOWNTO 0);
      COSINE                  : OUT STD_LOGIC_VECTOR(OUTPUT_BITS - 1 DOWNTO 0);
      NGRST                   : IN STD_LOGIC;
      RSTN                    : IN STD_LOGIC;
      CLK                     : IN STD_LOGIC;
      INIT                    : IN STD_LOGIC;       -- Optional external INIT
      INIT_OVER               : OUT STD_LOGIC  );
  END COMPONENT;

  COMPONENT dds_bhvTestVectIn
    GENERIC ( PH_OFFSET_BITS    : INTEGER;
              FREQ_OFFSET_BITS  : INTEGER   );
    PORT    ( freq_offset_we, ph_offset_we : OUT STD_LOGIC;
              sample_num  :  IN INTEGER;
              freq_offset : OUT STD_LOGIC_VECTOR(FREQ_OFFSET_BITS-1 DOWNTO 0);
              ph_offset   : OUT STD_LOGIC_VECTOR(PH_OFFSET_BITS-1 DOWNTO 0)  );
  END COMPONENT;
  
  COMPONENT dds_bhvTestVectOut
    GENERIC ( OUTPUT_BITS    : INTEGER  );
    PORT  ( sample_num : INTEGER; 
      goldSin, goldCos : OUT STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0) );
  END COMPONENT;

  -- Replicate RTL param values
  -- parameter MAX_FULL_WAVE_LOGDEPTH = 9;  Delivered via coreparameters.v/vhd
  constant TST_LENGTH     : INTEGER := 510;
  constant QUARTER_WAVE   : INTEGER := intMux_bhv(0, 1, QUANTIZER_BITS>MAX_FULL_WAVE_LOGDEPTH); 
  constant RAM_LOGDEPTH   : INTEGER := intMux_bhv(QUANTIZER_BITS-3, QUANTIZER_BITS, QUARTER_WAVE=0);
  constant LOGDEPTH_LONG  : INTEGER := intMux_bhv (4, RAM_LOGDEPTH, RAM_LOGDEPTH > 3);
  constant LOGDEPTH_SHRT  : INTEGER := intMux_bhv (RAM_LOGDEPTH, 4, RAM_LOGDEPTH > 3);
  constant DEPTH_LONG     : INTEGER := 2**LOGDEPTH_LONG;
  constant DEPTH_SHRT     : INTEGER := 2**LOGDEPTH_SHRT;
                                    
  -- Calculate pipe values        
  constant PIPE1  : INTEGER := intMux_bhv(0, 1, LATENCY>1);
  constant PIPE2  : INTEGER := intMux_bhv(0, 1, ((PH_OFFSET_MODE/=0) OR (PH_CORRECTION=1)) AND (LATENCY>1) );
  constant PIPE3  : INTEGER := intMux_bhv(0, 1, (PH_CORRECTION=0) AND (QUANTIZER_BITS<PH_ACC_BITS) AND (LATENCY>1) );   --01/16/17
  -- PIPE 4                       
  -- LSRAM always have the rA pipe on - it cannot be turned off. To follow this
  -- behavior on uRAM, where rA pipe is optional, we'll keep PIPE4 always on
  constant PIPE4  : INTEGER := 1;
  constant PIPE4EXT : INTEGER := intMux_bhv(0, 1, LATENCY>1);
  constant PIPE5  : INTEGER := intMux_bhv(0, 1, LATENCY>0);
  constant PIPE6  : INTEGER := intMux_bhv(0, 1, LATENCY>2);
  constant PIPE7  : INTEGER := intMux_bhv(0, 1, (QUARTER_WAVE>0) AND (LATENCY>1));
  -- Trigonometric Correction pipes
  constant PIPE8  : INTEGER := intMux_bhv(0, 1, (PH_CORRECTION=2) AND (PIPE4=1) );
  constant PIPE9  : INTEGER := intMux_bhv(0, 1, (PH_CORRECTION=2) AND (PIPE5=1) );
  constant PIPE10 : INTEGER := intMux_bhv(0, 1, (PH_CORRECTION=2) AND (LATENCY>2) );
  constant PIPE11 : INTEGER := intMux_bhv(0, 1, (PH_CORRECTION=2) AND (LATENCY>1) );
  constant PIPE_PH_INC : INTEGER := PIPE2+PIPE3+PIPE4+PIPE4EXT+PIPE5+PIPE6+PIPE7+PIPE10+PIPE11;
  constant PIPE_PH_OFFS: INTEGER := PIPE_PH_INC+PIPE1;
  
  -- !!! Set Slow clk divider on RTL and backend SW !!!
  constant SLOWCLK_DIV : INTEGER := 4;

  SIGNAL clk                : STD_LOGIC;
  SIGNAL nGrst              : STD_LOGIC;
  SIGNAL rst                : STD_LOGIC;
  SIGNAL rstn               : STD_LOGIC;
  SIGNAL uut_sin            : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL uut_cos            : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL freq_offset_w      : STD_LOGIC_VECTOR(FREQ_OFFSET_BITS-1 DOWNTO 0);
  SIGNAL freq_offset_inp    : STD_LOGIC_VECTOR(FREQ_OFFSET_BITS-1 DOWNTO 0);
  SIGNAL ph_offset_w        : STD_LOGIC_VECTOR(PH_OFFSET_BITS-1 DOWNTO 0);
  SIGNAL ph_offset_inp      : STD_LOGIC_VECTOR(PH_OFFSET_BITS-1 DOWNTO 0);
  SIGNAL sample_num_w       : STD_LOGIC_VECTOR(ceil_log2_bhv(TST_LENGTH) DOWNTO 0);
  SIGNAL sample_num         : INTEGER;
  SIGNAL freq_offset_we_inp : STD_LOGIC;
  SIGNAL ph_offset_we_inp   : STD_LOGIC;
  SIGNAL freq_offset_we_w   : STD_LOGIC;
  SIGNAL ph_offset_we_w     : STD_LOGIC;
  SIGNAL end_test           : STD_LOGIC;
  SIGNAL uut_init_over      : STD_LOGIC;
  SIGNAL goldSin            : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL goldCos            : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL goldSin_dly        : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL goldCos_dly        : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL init_timer         : STD_LOGIC_VECTOR(23 DOWNTO 0);
  SIGNAL init_progress      : STD_LOGIC;		-- init in progress
  SIGNAL watch4init_over    : STD_LOGIC;
  SIGNAL rst_sample_num     : STD_LOGIC;
  SIGNAL test_progress      : STD_LOGIC;
  SIGNAL test_progress_dly  : STD_LOGIC;
  SIGNAL fail_init          : STD_LOGIC;
  SIGNAL fail_sin           : STD_LOGIC;
  SIGNAL fail_cos           : STD_LOGIC;
  SIGNAL end_watch          : STD_LOGIC;
  SIGNAL start_watch        : STD_LOGIC;
  SIGNAL halt               : STD_LOGIC := '0';
  
BEGIN
  rstn <= NOT(rst);
--03/23/17  ext_freq_phase_offset : IF ((PH_INC_MODE/=0) OR (PH_OFFSET_MODE /=0)) GENERATE
  ext_freq_phase_offset : IF ((PH_INC_MODE/=0) OR (PH_OFFSET_MODE=2)) GENERATE
    vect_in_0 : dds_bhvTestVectIn
      GENERIC MAP ( FREQ_OFFSET_BITS  => FREQ_OFFSET_BITS,
                    PH_OFFSET_BITS    => PH_OFFSET_BITS  )
      PORT MAP (
        sample_num      => sample_num,
        freq_offset     => freq_offset_inp,
        freq_offset_we  => freq_offset_we_inp,
        ph_offset       => ph_offset_inp,
        ph_offset_we    => ph_offset_we_inp  );
  END GENERATE;
  
  freq_offset_w <= freq_offset_inp WHEN (PH_INC_MODE /= 0) ELSE (others=>'0');
  freq_offset_we_w <= freq_offset_we_inp WHEN (PH_INC_MODE /= 0) ELSE '0';
--03/23/17  ph_offset_w <= ph_offset_inp WHEN (PH_OFFSET_MODE /= 0) ELSE (others=>'0');
--03/23/17  ph_offset_we_w <= ph_offset_we_inp WHEN (PH_OFFSET_MODE /= 0) ELSE '0';
  ph_offset_w <= ph_offset_inp WHEN (PH_OFFSET_MODE=2) ELSE (others=>'0');
  ph_offset_we_w <= ph_offset_we_inp WHEN (PH_OFFSET_MODE=2) ELSE '0';
  
  uut_0 : COREDDS_C0_COREDDS_C0_0_COREDDS
    GENERIC MAP (
      PH_ACC_BITS             => PH_ACC_BITS,
      PH_INC_MODE             => PH_INC_MODE,
      PH_INC                  => PH_INC,
      SIN_ON                  => SIN_ON,
      COS_ON                  => COS_ON,
      SIN_POLARITY            => SIN_POLARITY,
      COS_POLARITY            => COS_POLARITY,
      FREQ_OFFSET_BITS        => FREQ_OFFSET_BITS,
      PH_OFFSET_MODE          => PH_OFFSET_MODE,
      PH_OFFSET_CONST         => PH_OFFSET_CONST,
      PH_OFFSET_BITS          => PH_OFFSET_BITS,
      PH_CORRECTION           => PH_CORRECTION,
      QUANTIZER_BITS          => QUANTIZER_BITS,
      OUTPUT_BITS             => OUTPUT_BITS,
      LATENCY                 => LATENCY,
      URAM_MAXDEPTH           => URAM_MAXDEPTH,
      FPGA_FAMILY             => FPGA_FAMILY,
      DIE_SIZE                => DIE_SIZE,
      MAX_FULL_WAVE_LOGDEPTH  => MAX_FULL_WAVE_LOGDEPTH  )
    PORT MAP (
      FREQ_OFFSET     => freq_offset_w,
      FREQ_OFFSET_WE  => freq_offset_we_w,
      PH_OFFSET       => ph_offset_w,
      PH_OFFSET_WE    => ph_offset_we_w,
      SINE            => uut_sin,
      COSINE          => uut_cos,
      NGRST           => nGrst,
      RSTN            => rstn,
      INIT            => '0',
      CLK             => clk,
      INIT_OVER       => uut_init_over  );
  
  --                         +-+-+-+-+ +-+-+-+-+ +-+-+-+-+
  --                         |I|n|i|t| |O|v|e|r| |T|r|a|p|
  --                         +-+-+-+-+ +-+-+-+-+ +-+-+-+-+
  dly_count_0 : bhvCountS
    GENERIC MAP (
      WIDTH     => 24,
      DCVALUE   => SLOWCLK_DIV*DEPTH_LONG+20,
      BUILD_DC  => 1  )
    PORT MAP (
      nGrst  => nGrst,
      rst    => '0',
      clk    => clk,
      clkEn  => clk,
      cntEn  => '1',
      Q      => init_timer,
      dc     => end_watch   );
  start_watch <= to_logic_bhv(to_integer(unsigned(init_timer)) = SLOWCLK_DIV*DEPTH_LONG);
  
  -- Start watching for the INIT_OVER
  PROCESS (nGrst, clk)
  BEGIN
    IF (nGrst = '0') THEN
      watch4init_over <= '0';
    ELSIF (clk'EVENT AND clk = '1') THEN
      IF (start_watch = '1') THEN
        watch4init_over <= '1';
      ELSIF (uut_init_over = '1') THEN
        watch4init_over <= '0';
      END IF;
    END IF;
  END PROCESS;
  --  ------------------ Init Over check completed
  
  --                     +-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+-+
  --                     |G|o|l|d|e|n| |V|e|c|t|o|r| |G|e|n|
  --                     +-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+-+
  
  -- Keep sample_num=0 until after uut_init_over
  PROCESS (nGrst, clk)
  BEGIN
    IF (nGrst = '0') THEN
      init_progress <= '1';
    ELSIF (clk'EVENT AND clk = '1') THEN
      IF (uut_init_over = '1') THEN
        init_progress <= '0';
      END IF;
    END IF;
  END PROCESS;
  
  
  -- Output golden sample counter
  rst_sample_num <= rst OR (init_progress AND NOT(uut_init_over));
  gold_sample_count_0 : bhvCountS
    GENERIC MAP ( WIDTH     => ceil_log2_bhv(TST_LENGTH+110),
                  DCVALUE   => TST_LENGTH,
                  BUILD_DC  => 1  )
    PORT MAP (  nGrst  => nGrst,
                rst    => rst_sample_num,
                clk    => clk,
                clkEn  => '1',
                cntEn  => '1',
                Q      => sample_num_w,
                dc     => end_test  );
  sample_num <= to_integer(unsigned(sample_num_w));
  
  gold_out_vect_0 : dds_bhvTestVectOut
    GENERIC MAP ( OUTPUT_BITS  => OUTPUT_BITS)
    PORT MAP (
      sample_num  => sample_num,
      goldsin     => goldSin,
      goldcos     => goldCos  );
  
  -- Delay the golden samples by overall HW pipeline delay

  pipe_dly_0 : bhv_kitDelay_reg
    GENERIC MAP (
      DELAY  => PIPE_PH_INC,
      WIDTH  => OUTPUT_BITS  )
    PORT MAP (
      nGrst  => nGrst,
      rst    => rst,
      clk    => clk,
      clkEn  => '1',
      inp    => goldSin,
      outp   => goldSin_dly  );

  pipe_dly_1 : bhv_kitDelay_reg
    GENERIC MAP (
      DELAY  => PIPE_PH_INC,
      WIDTH  => OUTPUT_BITS  )
    PORT MAP (
      nGrst  => nGrst,
      rst    => rst,
      clk    => clk,
      clkEn  => '1',
      inp    => goldCos,
      outp   => goldCos_dly  );
  
  -- Identify valid output time period that starts on uut_init_over
  test_progress <= (NOT(init_progress) AND NOT(end_test)) OR uut_init_over;
  
  pipe_dly_2 : bhv_kitDelay_bit_reg
    GENERIC MAP (DELAY => PIPE_PH_INC+PIPE1 )
    PORT MAP (
      nGrst  => nGrst,
      rst    => rst,
      clk    => clk,
      clkEn  => '1',
      inp    => test_progress,
      outp   => test_progress_dly  );

  --      _   _   _   _   _     _   _   _   _   _   _   _
  --     / \ / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ / \
  --    ( C | H | E | C | K ) ( R | E | S | U | L | T | S )
  --     \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/
  
  PROCESS 
    VARIABLE var_line : line;
  BEGIN
    print("");

    print("");
    print("---------------------------------------------------------------------------------");
    write(var_line, string'("DDS introduces delay of "));
    write(var_line, PIPE_PH_INC);
    write(var_line, string'(" clock cycles"));
    writeline (output, var_line);
    print("Note: The delay from PHASE_OFFSET_WE signal to the output is one clock cycle more");
    print("---------------------------------------------------------------------------------");
    
    print("");
    print("------------------");
    print("Testing CoreDDS");
    print("------------------");
    print("");
    WAIT;
  END PROCESS;
  
  PROCESS (clk, nGrst)
    VARIABLE var_line : line;
  BEGIN
    IF (nGrst = '0') THEN
      fail_init <= '0';
      fail_sin <= '0';
      fail_cos <= '0';
    ELSIF (clk'EVENT AND clk = '1') THEN
      -- Watch INIT_OVER
      -- If end_watch comes while watch interval is still on
      IF ((end_watch = '1') AND (watch4init_over = '1')) THEN
        fail_init <= '1';
      END IF;
      
      IF (test_progress_dly = '1') THEN
        IF (SIN_ON /= 0) THEN
          write(var_line, string'("time: "));
          write(var_line, NOW );
          IF ( (to_integer(signed(goldSin_dly))-to_integer(signed(uut_sin)))>1)
              OR 
             ( (to_integer(signed(goldSin_dly))-to_integer(signed(uut_sin)))<-1) 
            THEN 
              fail_sin <= '1';
              write(var_line, string'("  SINE Output ERROR: Expected value = "));
              write(var_line, to_integer(signed(goldSin_dly)) );
              write(var_line, string'(", Actual = "));
              write(var_line, to_integer(signed(uut_sin)) );
              writeline (output, var_line);
          ELSE  
              write(var_line, string'("  Match: SINE value = "));
              write(var_line, to_integer(signed(uut_sin)) );
              writeline (output, var_line);
          END IF;
        END IF;            
            
        IF (COS_ON /= 0) THEN
          write(var_line, string'("time: "));
          write(var_line, NOW );
          IF ( (to_integer(signed(goldCos_dly))-to_integer(signed(uut_cos)))>1)
              OR 
             ( (to_integer(signed(goldCos_dly))-to_integer(signed(uut_cos)))<-1) 
            THEN 
              fail_cos <= '1';
              write(var_line, string'("  COSINE Output ERROR: Expected value = "));
              write(var_line, to_integer(signed(goldCos_dly)) );
              write(var_line, string'(", Actual = "));
              write(var_line, to_integer(signed(uut_cos)) );
              writeline (output, var_line);
          ELSE  
              write(var_line, string'("  Match: COSINE value = "));
              write(var_line, to_integer(signed(uut_cos)) );
              writeline (output, var_line);
          END IF;
        END IF;
      END IF;            

      IF (end_test = '1') THEN
        print("");
        IF (fail_init = '1') THEN
          print("UUT failed to generate INIT_OVER");
        END IF;
        print("");
        print("##############################");
        IF (fail_init='1' OR fail_sin='1' OR fail_cos='1') THEN
          print("!!!!! DDS TEST FAILED !!!!!");
        ELSE
          print(" DDS test passed ");
        END IF;
        print("##############################");
        
        halt <= '1';
      END IF;
    END IF;
  END PROCESS;
  
  
  -----------------------------------------------------------------------------
  clock_0 : bhvClockGen
    GENERIC MAP ( CLKPERIOD   => 10 ns,
                  NGRSTLASTS  => 24 ns )
    PORT MAP( halt            => halt,
              clk             => clk,
              nGrst           => nGrst,
              rst             => rst,
              rstn            => open  );
  
--  clk_1 : bhvClkGen
--    GENERIC MAP ( CLKPERIOD   => 10 ns,
--                  NGRSTLASTS  => 24 ns,
--                  RST_DLY     => 10 ns )
--    PORT MAP (  clk    => open,
--                nGrst  => open,
--                rst    => rst  );
  
END ARCHITECTURE bhv;


