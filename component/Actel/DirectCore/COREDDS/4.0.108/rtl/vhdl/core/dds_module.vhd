--****************************************************************
--Microsemi Corporation Proprietary and Confidential
--Copyright 2016 Microsemi Corporation.  All rights reserved
--
--ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
--ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
--IN ADVANCE IN WRITING.
--
--Description: CoreDDS
--             Static modules
--
--Rev:
--v3.0 10/31/2016
--
--SVN Revision Information:
--SVN$Revision:$
--SVN$Date:$
--
--Resolved SARS
--
--Notes:
--
--****************************************************************

--                        +-+-+-+-+ +-+-+-+ +-+-+-+-+
--                        |S|i|n|e| |L|U|T| |I|n|i|t|
--                        +-+-+-+-+ +-+-+-+ +-+-+-+-+
-- Create LUT initialization sequences. Need to initialize sin/cos LUT's and
-- a dithering LFSR 16-word LUT. Initialization starts on the rear end of the
-- sync'ed nGrst signal
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY dds_LUT_initializer IS
  GENERIC ( RAM_LOGDEPTH    : INTEGER := 8;
      SLOWCLK_DIV     : INTEGER := 8;
      LOG_SLOWCLK_DIV : INTEGER := 3  );
  PORT (
    clk       : IN STD_LOGIC;
    nGrst     : IN STD_LOGIC;
    ext_rstn  : IN STD_LOGIC;
    ext_init  : IN STD_LOGIC;
    init_over : OUT STD_LOGIC;
    rstn      : OUT STD_LOGIC;
    slow_clk  : OUT STD_LOGIC;
    sico_wEn  : OUT STD_LOGIC;                                  -- to sin LUT
    sico_wA   : OUT STD_LOGIC_VECTOR(RAM_LOGDEPTH-1 DOWNTO 0);  -- to sin LUT
    lfsr_wEn  : OUT STD_LOGIC;                        -- to LFSR LUT
    lfsr_wA   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) );   -- to LFSR LUT
END ENTITY dds_LUT_initializer;

ARCHITECTURE rtl OF dds_LUT_initializer IS
  -- If LFSR table depth is bigger than sin/cos LUT
  constant  LOGDEPTH_LONG : INTEGER := intMux (4, RAM_LOGDEPTH, RAM_LOGDEPTH > 3);
  constant  LOGDEPTH_SHRT : INTEGER := intMux (RAM_LOGDEPTH, 4, RAM_LOGDEPTH > 3);
  constant  DEPTH_LONG    : INTEGER := 2**LOGDEPTH_LONG;
  constant  DEPTH_SHRT    : INTEGER := 2**LOGDEPTH_SHRT;

  SIGNAL init_nGrst             : STD_LOGIC;
  SIGNAL initi                  : STD_LOGIC;
  SIGNAL last_wA_last_clk_long  : STD_LOGIC;
  SIGNAL last_wA_last_clk_shrt  : STD_LOGIC;
  SIGNAL last_wA_long           : STD_LOGIC;
  SIGNAL wEn_long               : STD_LOGIC;
  SIGNAL wEn_shrt               : STD_LOGIC;
  SIGNAL wA                     : STD_LOGIC_VECTOR(LOGDEPTH_LONG-1 DOWNTO 0);
  SIGNAL last_wA_shrt           : STD_LOGIC;
  SIGNAL nwEn_long              : STD_LOGIC;
  SIGNAL slow_clki              : STD_LOGIC;

  attribute syn_noclockbuf: Boolean;                  --03/09/17
  attribute syn_noclockbuf of wA : signal is true;    --03/09/17

BEGIN
  slow_clk <= slow_clki;

  -- Generate 1-clk wide sync'd init_nGrst pulse on the nGrst rising (back) edge
  sync_ngrst_0 : dds_kitSyncNgrst
    GENERIC MAP ( PULSE_WIDTH  => 1 )
    PORT MAP (
      nGrst     => nGrst,
      clk       => clk,
      pulse     => init_nGrst,
      ext_rstn  => ext_rstn,
      rstn      => rstn  );

  initi <= init_nGrst OR ext_init;
  -- Slow clk generator
  slow_count_0 : dds_kitCountS
    GENERIC MAP ( WIDTH     => LOG_SLOWCLK_DIV,
                  DCVALUE   => SLOWCLK_DIV-1,
                  BUILD_DC  => 1 )
    PORT MAP (
      nGrst  => nGrst,
      rst    => initi,
      clk    => clk,
      clkEn  => '1',
      cntEn  => '1',
      Q      => open,
      dc     => slow_clki );

  -- Generate two initialization-in-progress signals, wEn_shrt and wEn_long. One
  -- lasts long enough to write to deeper LUT whether it is sin/cos or LFSR LUT,
  -- another to shorter LUT. LUT's use them as wEn
  PROCESS (nGrst, clk)
  BEGIN
    IF (nGrst = '0') THEN
      wEn_shrt <= '0';
      wEn_long <= '0';
    ELSIF (clk'EVENT AND clk = '1') THEN
      IF (slow_clki = '1') THEN
        IF (last_wA_last_clk_long = '1') THEN
          wEn_long <= '0';
        END IF;
        IF (last_wA_last_clk_shrt = '1') THEN
          wEn_shrt <= '0';
        END IF;
      END IF;
      IF (initi = '1') THEN
        wEn_long <= '1';
        wEn_shrt <= '1';
      END IF;
    END IF;
  END PROCESS;

  nwEn_long <= NOT(wEn_long);

  -- wA counter covers the long LUT. It counts when wEn=1.
  wA_count_0 : dds_kitCountS
    GENERIC MAP ( WIDTH     => LOGDEPTH_LONG,
                  DCVALUE   => DEPTH_LONG-1,
                  BUILD_DC  => 1  )
    PORT MAP (
      nGrst  => nGrst,
      rst    => nwEn_long,
      clk    => clk,
      clkEn  => slow_clki,
      cntEn  => '1',
      Q      => wA,
      dc     => last_wA_long  );

  last_wA_shrt <= to_logic(to_integer(unsigned(wA)) = DEPTH_SHRT-1) ;
  -- The last clk of the last wA
  last_wA_last_clk_long <= last_wA_long AND slow_clki;
  last_wA_last_clk_shrt <= last_wA_shrt AND slow_clki;

  lfsr_wA <= wA(3 DOWNTO 0);
  lfsr_wEn <= wEn_shrt WHEN (RAM_LOGDEPTH > 3) ELSE wEn_long;
  sico_wA <= wA(RAM_LOGDEPTH-1 DOWNTO 0);
  sico_wEn <= wEn_long WHEN (RAM_LOGDEPTH > 3) ELSE wEn_shrt;

  -- init_over flag is a delayed copy of the last_wA_last_clk
  -- 3-clk delay is set to make sure write pipes are over
  initOver_0 : dds_kitDelay_bit_reg
    GENERIC MAP ( DELAY  => 3 )
    PORT MAP (
      nGrst  => nGrst,
      rst    => '0',
      clk    => clk,
      clkEn  => '1',
      inp    => last_wA_last_clk_long,
      outp   => init_over  );

END ARCHITECTURE rtl;



--                      +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+
--                      |P|h|a|s|e| |A|c|c|u|m|u|l|a|t|o|r|
--                      +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY dds_ph_accumulator IS
  GENERIC (
    PH_INC_MODE       : INTEGER := 0;
    FREQ_OFFSET_BITS  : INTEGER := 10;
    PH_ACC_BITS       : INTEGER := 24;
    PH_INC            : INTEGER := 1024*1024;
    PIPE1             : INTEGER := 0  );
  PORT (
    clk               : IN STD_LOGIC;
    rstn              : IN STD_LOGIC;
    nGrst             : IN STD_LOGIC;
    ext_freq_offset   : IN STD_LOGIC_VECTOR(FREQ_OFFSET_BITS-1 DOWNTO 0);
    freq_offset_we    : IN STD_LOGIC;
    ph_accum          : OUT STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0) );
END ENTITY dds_ph_accumulator;

ARCHITECTURE rtl OF dds_ph_accumulator IS
  constant CONST_FREQ_OFFSET_BITS  : INTEGER := ceil_log2(PH_INC)+1;

  SIGNAL freq_offset_r  : STD_LOGIC_VECTOR(FREQ_OFFSET_BITS-1 DOWNTO 0);
  SIGNAL freq_offset    : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL ph_adder       : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL ph_reg         : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL ph_reg_inp     : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL ph_inc_w       : STD_LOGIC_VECTOR(CONST_FREQ_OFFSET_BITS-1 DOWNTO 0);
  SIGNAL rst            : STD_LOGIC;
BEGIN
  ph_inc_w  <= std_logic_vector(to_unsigned(PH_INC, CONST_FREQ_OFFSET_BITS));
  rst       <= NOT(rstn);

  -- Process phase increment
  var_ph_inc_port : IF(PH_INC_MODE/=0) GENERATE  -- External variable freq_ofset
    ext_ph_inc_0 : dds_kitDelay_reg
      GENERIC MAP ( BITWIDTH  => FREQ_OFFSET_BITS,
                    DELAY     => 1 )
      PORT MAP (
        nGrst  => nGrst,
        rst    => rst,
        clk    => clk,
        clkEn  => freq_offset_we,
        inp    => ext_freq_offset,
        outp   => freq_offset_r  );

    -- Sign extend the unsigned offset
    signExt_0 : dds_signExt
      GENERIC MAP (
        INWIDTH   => FREQ_OFFSET_BITS,
        OUTWIDTH  => PH_ACC_BITS,
        UNSIGN    => 1,
        DROP_MSB  => 0  )
      PORT MAP (
        inp   => freq_offset_r,
        outp  => freq_offset  );
  END GENERATE;

  const_freq_offset : IF(PH_INC_MODE=0) GENERATE -- Internal constant freq_ofset
    signExt_0 : dds_signExt       -- Sign extend the unsigned offset
      GENERIC MAP (
        INWIDTH   => CONST_FREQ_OFFSET_BITS,
        OUTWIDTH  => PH_ACC_BITS,
        UNSIGN    => 1,
        DROP_MSB  => 0  )
      PORT MAP (
        inp   => ph_inc_w,
        outp  => freq_offset  );
  END GENERATE;
  -- Process phase increment ends

  -- Phase Accumulator
  ph_adder <= std_logic_vector(unsigned(freq_offset) + unsigned(ph_reg));

  ph_accum_piped : IF (PIPE1 /= 0) GENERATE
    ph_accum_0 : dds_kitDelay_reg
      GENERIC MAP ( BITWIDTH  => PH_ACC_BITS,
                    DELAY     => 1  )
      PORT MAP (
        nGrst  => nGrst,
        rst    => rst,
        clk    => clk,
        clkEn  => '1',
        inp    => ph_adder,
        outp   => ph_reg  );

    ph_accum <= ph_reg;
  END GENERATE;

  -- To provide 0 delay, take output right from the adder.
  -- In order to reset the PH_ACC, need to load -PH_INC in accumulator register.
  -- Then the reset will set the PH_ACC in 0 state
  ph_accum_through : IF (PIPE1 = 0) GENERATE
    -- nGrst isn't used here due to RTG4 limitation
    ph_reg_inp <= (others=>'0') WHEN (rstn = '0') ELSE ph_adder;

    ph_accum_0 : dds_kitDelay_reg
      GENERIC MAP (
        BITWIDTH  => PH_ACC_BITS,
        DELAY     => 1  )
      PORT MAP (
        nGrst  => nGrst,
        rst    => '0',
        clk    => clk,
        clkEn  => '1',
        inp    => ph_reg_inp,
        outp   => ph_reg  );
    ph_accum <= ph_reg_inp;
  END GENERATE;
END ARCHITECTURE rtl;




--         +-+-+-+-+-+ +-+-+-+-+-+-+   +-+-+-+-+-+-+ +-+-+-+-+-+-+
--         |P|h|a|s|e| |O|f|f|s|e|t| & |D|i|t|h|e|r| |b|r|a|n|c|h|
--         +-+-+-+-+-+ +-+-+-+-+-+-+   +-+-+-+-+-+-+ +-+-+-+-+-+-+
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY dds_dither_offset IS
  GENERIC (
    PH_ACC_BITS           : INTEGER := 24;
    QUANTIZER_BITS        : INTEGER := 8;
    PH_OFFSET_MODE        : INTEGER := 0;
    PH_OFFSET_CONST       : INTEGER := 0;
    PH_OFFSET_BITS        : INTEGER := 10;
    PH_CORRECTION         : INTEGER := 1;
    PIPE1                 : INTEGER := 0;
    FPGA_FAMILY           : INTEGER := 26;
    SIMUL_RAM             : INTEGER := 1  );
  PORT (
    clk                   : IN STD_LOGIC;
    rstn                  : IN STD_LOGIC;
    nGrst                 : IN STD_LOGIC;
    ext_ph_offset         : IN STD_LOGIC_VECTOR(PH_OFFSET_BITS-1 DOWNTO 0);
    ph_offset_we          : IN STD_LOGIC;
    dith_init             : IN STD_LOGIC;
    dith_offs             : OUT STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
    -- LFSR LUT initialization ports
    slow_clk              : IN STD_LOGIC;
    lfsr_wEn              : IN STD_LOGIC;
    lfsr_wA               : IN STD_LOGIC_VECTOR(3 DOWNTO 0) );
END ENTITY dds_dither_offset;

ARCHITECTURE rtl OF dds_dither_offset IS
  COMPONENT dds_dither
    GENERIC ( FPGA_FAMILY : INTEGER;
              SIMUL_RAM   : INTEGER  );
    PORT (
      clk         : IN STD_LOGIC;
      rstn        : IN STD_LOGIC;
      nGrst       : IN STD_LOGIC;
      init        : IN STD_LOGIC;		-- Bring lfsr_wEn here
      dither      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      slow_clk    : IN STD_LOGIC;		-- LFSR LUT initialization
      lfsr_wEn    : IN STD_LOGIC;   -- LUT initialization
      lfsr_wA     : IN STD_LOGIC_VECTOR(3 DOWNTO 0)  ); -- LUT initialization
  END COMPONENT;

  constant TRUNCATE_BITS  : INTEGER :=
          intMux(PH_ACC_BITS-QUANTIZER_BITS, 4, (PH_ACC_BITS-QUANTIZER_BITS)>3);

  -- Set the minimal bitwidth of the PH_OFFSET_CONSTI = 2 to avoid HDL complaint
--04/05/17  constant CONST_PH_OFFSET_BITS  : INTEGER :=
--04/04/17                  intMux (2, ceil_log2(PH_OFFSET_CONST)+1, PH_OFFSET_CONST>3 );
--04/05/17                  intMux (2, ceil_log2(PH_OFFSET_CONST), PH_OFFSET_CONST>3 );
--04/05/17  constant PH_OFFSET_CONSTI: std_logic_vector(CONST_PH_OFFSET_BITS-1 downto 0):=
--04/05/17          std_logic_vector(to_unsigned(PH_OFFSET_CONST, CONST_PH_OFFSET_BITS));

  SIGNAL ph_offset_r  : STD_LOGIC_VECTOR(PH_OFFSET_BITS-1 DOWNTO 0);
  SIGNAL ph_offset    : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL ph_adder     : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL ph_reg       : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL dither_ext   : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL dith_phOffs  : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL dither       : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL dither_w     : STD_LOGIC_VECTOR(TRUNCATE_BITS-1 DOWNTO 0);
  SIGNAL rst          : STD_LOGIC;

BEGIN
  -- Process phase offset
  var_ph_offset_port : IF (PH_OFFSET_MODE=2) GENERATE -- Variable ph_ofset
    rst <= NOT(rstn);
    ext_ph_offset_0 : dds_kitDelay_reg
      GENERIC MAP ( BITWIDTH  => PH_OFFSET_BITS,
                    DELAY     => 1  )
      PORT MAP (
        nGrst  => nGrst,
        rst    => rst,
        clk    => clk,
        clkEn  => ph_offset_we,
        inp    => ext_ph_offset,
        outp   => ph_offset_r );

    -- Sign extend the unsigned offset
    signExt_0 : dds_signExt
      GENERIC MAP ( INWIDTH   => PH_OFFSET_BITS,
                    OUTWIDTH  => PH_ACC_BITS,
                    UNSIGN    => 1,
                    DROP_MSB  => 0  )
      PORT MAP (  inp   => ph_offset_r,
                  outp  => ph_offset  );
  END GENERATE;

  const_ph_offset : IF (PH_OFFSET_MODE = 1) GENERATE -- Constant ph_offset
    -- Sign extend the unsigned offset
--04/05/17    signExt_0 : dds_signExt
--04/05/17      GENERIC MAP ( INWIDTH   => CONST_PH_OFFSET_BITS,
--04/05/17                    OUTWIDTH  => PH_ACC_BITS,
--04/05/17                    UNSIGN    => 1,
--04/05/17                    DROP_MSB  => 0  )
--04/05/17      PORT MAP (  inp   => PH_OFFSET_CONSTI,
--04/05/17                  outp  => ph_offset  );
    ph_offset <= std_logic_vector(to_unsigned(PH_OFFSET_CONST, PH_ACC_BITS));
  END GENERATE;

  dithering : IF (PH_CORRECTION = 1) GENERATE
    dither_0 : dds_dither
      GENERIC MAP (
        FPGA_FAMILY  => FPGA_FAMILY,
        SIMUL_RAM    => SIMUL_RAM  )
      PORT MAP (
        clk       => clk,
        rstn      => rstn,
        nGrst     => nGrst,
        init      => dith_init,
        dither    => dither,
        -- LFSR LUT initialization ports
        slow_clk  => slow_clk,
        lfsr_wEn  => lfsr_wEn,
        lfsr_wA   => lfsr_wA  );

    --      <- QUANTIZER_BITS -><- Truncate bits ->
    --    +
    --      000     ...      000<-Dither->
    dither_w <= dither(TRUNCATE_BITS-1 DOWNTO 0);

    signExt_0 : dds_signExt
      GENERIC MAP (
        INWIDTH   => TRUNCATE_BITS,
        OUTWIDTH  => PH_ACC_BITS,
        UNSIGN    => 1,
        DROP_MSB  => 0  )
      PORT MAP (
        inp   => dither_w,
        outp  => dither_ext );
  END GENERATE;

  -- Only Phase Offset is on
  offset_only : IF ((PH_OFFSET_MODE /= 0) AND (PH_CORRECTION /= 1)) GENERATE
    dith_phOffs <= ph_offset;
  END GENERATE;

  -- Only Dither is on
  dither_only : IF ((PH_OFFSET_MODE = 0) AND (PH_CORRECTION = 1)) GENERATE
    dith_phOffs <= dither_ext;
  END GENERATE;

  -- Both Phase Offset and Dither are on.
  offset_plus_dither : IF ((PH_OFFSET_MODE/=0) AND (PH_CORRECTION=1)) GENERATE
    dith_phOffs <= std_logic_vector(unsigned(ph_offset) + unsigned(dither_ext));
  END GENERATE;

  -- Infer Pipe1
  pipe1_0 : dds_kitDelay_reg
    GENERIC MAP ( BITWIDTH  => PH_ACC_BITS,
                  DELAY     => PIPE1 )
    PORT MAP (
      nGrst  => nGrst,
      rst    => '0',
      clk    => clk,
      clkEn  => '1',
      inp    => dith_phOffs,
      outp   => dith_offs  );
END ARCHITECTURE rtl;





--                            +-+-+-+-+-+-+-+-+-+
--                            |Q|u|a|n|t|i|z|e|r|
--                            +-+-+-+-+-+-+-+-+-+
-- Final Phase adder right in front of a quantizer and the quantizer
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY dds_quantizer IS
  GENERIC (
    PH_ACC_BITS             : INTEGER := 24;
    PH_INC_MODE             : INTEGER := 0;
    PH_INC                  : INTEGER := 1024 * 1024;
    QUANTIZER_BITS          : INTEGER := 8;
    FREQ_OFFSET_BITS        : INTEGER := 3;
    PH_OFFSET_MODE          : INTEGER := 0;
    PH_OFFSET_CONST         : INTEGER := 0;
    PH_OFFSET_BITS          : INTEGER := 10;
    PH_CORRECTION           : INTEGER := 1;
    PIPE1                   : INTEGER := 0;
    PIPE2                   : INTEGER := 0;
    PIPE3                   : INTEGER := 0;
    LATENCY                 : INTEGER := 0;
    -- LFSR LUT initialization params
    FPGA_FAMILY             : INTEGER := 26;
    SIMUL_RAM               : INTEGER := 1  );
  PORT (
    clk                     : IN STD_LOGIC;
    rstn                    : IN STD_LOGIC;
    nGrst                   : IN STD_LOGIC;
    ext_freq_offset         : IN STD_LOGIC_VECTOR(FREQ_OFFSET_BITS-1 DOWNTO 0);
    freq_offset_we          : IN STD_LOGIC;
    ext_ph_offset           : IN STD_LOGIC_VECTOR(PH_OFFSET_BITS-1 DOWNTO 0);
    ph_offset_we            : IN STD_LOGIC;
    dith_init               : IN STD_LOGIC;
    ph_acc_s                : OUT STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
    full_wave_addr          : OUT STD_LOGIC_VECTOR(QUANTIZER_BITS-1 DOWNTO 0);
    -- LFSR LUT initialization ports
    slow_clk                : IN STD_LOGIC;
    lfsr_wEn                : IN STD_LOGIC;
    lfsr_wA                 : IN STD_LOGIC_VECTOR(3 DOWNTO 0) );
END ENTITY dds_quantizer;

ARCHITECTURE rtl OF dds_quantizer IS
  COMPONENT dds_ph_accumulator IS
    GENERIC (
      PH_INC_MODE             : INTEGER;
      FREQ_OFFSET_BITS        : INTEGER;
      PH_ACC_BITS             : INTEGER;
      PH_INC                  : INTEGER;
      PIPE1                   : INTEGER );
    PORT (
      clk                     : IN STD_LOGIC;
      rstn                    : IN STD_LOGIC;
      nGrst                   : IN STD_LOGIC;
      ext_freq_offset         : IN STD_LOGIC_VECTOR(FREQ_OFFSET_BITS-1 DOWNTO 0);
      freq_offset_we          : IN STD_LOGIC;
      ph_accum                : OUT STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0)  );
  END COMPONENT;

  COMPONENT dds_dither_offset
    GENERIC (
      PH_ACC_BITS           : INTEGER := 24;
      QUANTIZER_BITS        : INTEGER := 8;
      PH_OFFSET_MODE        : INTEGER := 0;
      PH_OFFSET_CONST       : INTEGER := 0;
      PH_OFFSET_BITS        : INTEGER := 10;
      PH_CORRECTION         : INTEGER := 1;
      PIPE1                 : INTEGER := 0;
      FPGA_FAMILY           : INTEGER := 26;
      SIMUL_RAM             : INTEGER := 1  );
    PORT (
      clk                   : IN STD_LOGIC;
      rstn                  : IN STD_LOGIC;
      nGrst                 : IN STD_LOGIC;
      ext_ph_offset         : IN STD_LOGIC_VECTOR(PH_OFFSET_BITS-1 DOWNTO 0);
      ph_offset_we          : IN STD_LOGIC;
      dith_init             : IN STD_LOGIC;
      dith_offs             : OUT STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
      -- LFSR LUT initialization ports
      slow_clk              : IN STD_LOGIC;
      lfsr_wEn              : IN STD_LOGIC;
      lfsr_wA               : IN STD_LOGIC_VECTOR(3 DOWNTO 0) );
  END COMPONENT;

  constant RND_CONST : UNSIGNED(QUANTIZER_BITS downto 0) := to_unsigned(1, QUANTIZER_BITS+1);
  SIGNAL ph_accum         : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL phAcc_Dith_Offs  : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL dith_offs        : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL round_out        : STD_LOGIC_VECTOR(QUANTIZER_BITS-1 DOWNTO 0);
  SIGNAL round_inp        : STD_LOGIC_VECTOR(QUANTIZER_BITS DOWNTO 0);
  SIGNAL rst              : STD_LOGIC;
  SIGNAL ph_acc_si        : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
BEGIN
  ph_acc_s <= ph_acc_si;
  rst <= NOT(rstn);

  ph_accum_0 : dds_ph_accumulator
    GENERIC MAP (
      PH_INC_MODE       => PH_INC_MODE,
      FREQ_OFFSET_BITS  => FREQ_OFFSET_BITS,
      PH_ACC_BITS       => PH_ACC_BITS,
      PH_INC            => PH_INC,
      PIPE1             => PIPE1 )
    PORT MAP (
      clk              => clk,
      rstn             => rstn,
      nGrst            => nGrst,
      ext_freq_offset  => ext_freq_offset,
      freq_offset_we   => freq_offset_we,
      ph_accum         => ph_accum  );

  --  ------------  Add Dither and/or Phase Offset. Calculate the quantiz_1
  -- If dither or Phase Offset
  dither_or_ph_offset : IF ((PH_OFFSET_MODE/=0) OR (PH_CORRECTION=1)) GENERATE
    dither_offset_0 : dds_dither_offset
      GENERIC MAP (
        PH_ACC_BITS      => PH_ACC_BITS,
        QUANTIZER_BITS   => QUANTIZER_BITS,
        PH_OFFSET_MODE   => PH_OFFSET_MODE,
        PH_OFFSET_CONST  => PH_OFFSET_CONST,
        PH_OFFSET_BITS   => PH_OFFSET_BITS,
        PH_CORRECTION    => PH_CORRECTION,
        PIPE1            => PIPE1,
        FPGA_FAMILY      => FPGA_FAMILY,
        SIMUL_RAM        => SIMUL_RAM  )
      PORT MAP (
        clk            => clk,
        rstn           => rstn,
        nGrst          => nGrst,
        ext_ph_offset  => ext_ph_offset,
        ph_offset_we   => ph_offset_we,
        dith_init      => dith_init,
        dith_offs      => dith_offs,
        slow_clk       => slow_clk,
        lfsr_wEn       => lfsr_wEn,
        lfsr_wA        => lfsr_wA  );

    phAcc_Dith_Offs <= std_logic_vector(unsigned(ph_accum) + unsigned(dith_offs));

    -- PIPE 2
    pipe2_0 : dds_kitDelay_reg
      GENERIC MAP ( BITWIDTH  => PH_ACC_BITS,
                    DELAY     => PIPE2  )
      PORT MAP (
        nGrst  => nGrst,
        rst    => rst,
        clk    => clk,
        clkEn  => '1',
        inp    => phAcc_Dith_Offs,
        outp   => ph_acc_si );
  END GENERATE;

  -- No Dither or Phase Offset
  no_dither_no_ph_offs : IF((PH_OFFSET_MODE=0) AND (PH_CORRECTION/=1)) GENERATE
    ph_acc_si <= ph_accum;
  END GENERATE;

  -- Truncate if Dither or Trigonom Correction. Keep the full acc width if
  -- QUANTIZER_BITS==PH_ACC_BITS. Round otherwise
  -- Leave the upper QUANTIZER_BITS bits
  trunc_dither : IF (PH_CORRECTION /= 0) OR (QUANTIZER_BITS = PH_ACC_BITS) GENERATE --01/16/17
    full_wave_addr <= ph_acc_si(PH_ACC_BITS-1 DOWNTO PH_ACC_BITS-QUANTIZER_BITS);
  END GENERATE;

  -- Round
  round : IF (PH_CORRECTION = 0) AND (QUANTIZER_BITS < PH_ACC_BITS) GENERATE  --01/16/17
    -- Leave the upper QUANTIZER_BITS+1 bits
    round_inp <= std_logic_vector(unsigned
    (ph_acc_si(PH_ACC_BITS-1 DOWNTO PH_ACC_BITS-QUANTIZER_BITS-1)) + RND_CONST);
    round_out <= round_inp(QUANTIZER_BITS DOWNTO 1);

    -- PIPE 3
    pipe3_0 : dds_kitDelay_reg
      GENERIC MAP ( BITWIDTH  => QUANTIZER_BITS,
                    DELAY     => PIPE3  )
      PORT MAP (
        nGrst  => nGrst,
        rst    => rst,
        clk    => clk,
        clkEn  => '1',
        inp    => round_out,
        outp   => full_wave_addr );
  END GENERATE;

END ARCHITECTURE rtl;



--             +-+-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+
--             |T|r|i|g|o|n|o|m|e|t|r|i|c| |C|o|r|r|e|c|t|i|o|n|
--             +-+-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+
-- trig_cor module must have a balancing delay. trig_cor processes (1) truncated
-- LSB's of the phaseAccum and (2) sine/cosine samples coming from the LUT. Each
-- path (1) & (2) has its own configuration-dependent number of pipes but the
-- componenets (1) & (2) must come to the trig_cor Mult_Add at the same time.
-- This module implements a dly to be inferred in the path (1) to balance pipes
-- of the paths (2)
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
USE work.dds_rtl_pack.all;

ENTITY balance_dly IS
  GENERIC (
    PH_ACC_BITS     : INTEGER := 24;
    QUANTIZER_BITS  : INTEGER := 8;
    PIPE4EXT        : INTEGER := 0;
    PIPE6           : INTEGER := 0;
    PIPE7           : INTEGER := 0  );
  PORT (
    clk         : IN STD_LOGIC;
    nGrst       : IN STD_LOGIC;
    ph_lsb_in   : IN STD_LOGIC_VECTOR(PH_ACC_BITS-QUANTIZER_BITS-1 DOWNTO 0);
    ph_lsb_dly  : OUT STD_LOGIC_VECTOR(PH_ACC_BITS-QUANTIZER_BITS-1 DOWNTO 0) );
END ENTITY balance_dly;

ARCHITECTURE rtl OF balance_dly IS
BEGIN
  dly_0 : dds_kitDelay_reg
    GENERIC MAP ( BITWIDTH  => PH_ACC_BITS-QUANTIZER_BITS,
                  DELAY     => PIPE6+PIPE7+PIPE4EXT  )
    PORT MAP (
      nGrst  => nGrst,
      rst    => '0',
      clk    => clk,
      clkEn  => '1',
      inp    => ph_lsb_in,
      outp   => ph_lsb_dly  );
END ARCHITECTURE rtl;


LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY trig_cor IS
  GENERIC (
    PH_ACC_BITS     : INTEGER := 24;
    QUANTIZER_BITS  : INTEGER := 8;
    LATENCY         : INTEGER := 0;
    FPGA_FAMILY     : INTEGER := 26;
    SIN_ON          : INTEGER := 1;
    COS_ON          : INTEGER := 1;
    SIN_POLARITY    : INTEGER := 0;
    COS_POLARITY    : INTEGER := 0;
    OUTPUT_BITS     : INTEGER := 18;
    PIPE4EXT        : INTEGER := 0;
    PIPE6           : INTEGER := 0;
    PIPE7           : INTEGER := 0;
    PIPE8           : INTEGER := 0;
    PIPE9           : INTEGER := 0;
    PIPE10          : INTEGER := 0;
    PIPE11          : INTEGER := 0  );
  PORT (
    clk             : IN STD_LOGIC;
    rstn            : IN STD_LOGIC;
    nGrst           : IN STD_LOGIC;
    ph_accum_in     : IN STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
    sinA            : IN STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
    cosA            : IN STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
    sin_o           : OUT STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
    cos_o           : OUT STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0)  );
END ENTITY trig_cor;

ARCHITECTURE rtl OF trig_cor IS
  COMPONENT balance_dly IS
    GENERIC (
      PH_ACC_BITS     : INTEGER;
      QUANTIZER_BITS  : INTEGER;
      PIPE4EXT        : INTEGER;
      PIPE6           : INTEGER;
      PIPE7           : INTEGER  );
    PORT (
      clk        : IN STD_LOGIC;
      nGrst      : IN STD_LOGIC;
      ph_lsb_in  : IN STD_LOGIC_VECTOR(PH_ACC_BITS-QUANTIZER_BITS-1 DOWNTO 0);
      ph_lsb_dly : OUT STD_LOGIC_VECTOR(PH_ACC_BITS-QUANTIZER_BITS-1 DOWNTO 0));
  END COMPONENT;

  COMPONENT mac18x18_dds IS
    GENERIC (
      BYPASS_REG_A  : INTEGER;
      BYPASS_REG_B  : INTEGER;
      BYPASS_REG_C  : INTEGER;
      BYPASS_REG_P  : INTEGER;
      MULT_ADD      : INTEGER;  --  0-Mult only
      FPGA_FAMILY   : INTEGER );
    PORT (
      nGrst     : IN STD_LOGIC;
      rstn      : IN STD_LOGIC;
      clk       : IN STD_LOGIC;
      en_a      : IN STD_LOGIC;
      en_b      : IN STD_LOGIC;
      en_c      : IN STD_LOGIC;
      en_p      : IN STD_LOGIC;
      mcand_a   : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
      mcand_b   : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
      addend_c  : IN STD_LOGIC_VECTOR(intMux(44, 48, FPGA_FAMILY=26)-1 DOWNTO 0);
      pout      : OUT STD_LOGIC_VECTOR(intMux(44, 48, FPGA_FAMILY=26)-1 DOWNTO 0);
      sub       : IN STD_LOGIC  );    --  0-add; 1-sub
  END COMPONENT;

  -- Make sure the ph_lsb does not exceed 17 bits, as an unsigned mcand cannot
  -- exceed that value.  If this happens, have trig_cor take reduced Phase
  -- Accumulator bits
  constant PH_ACC_BITSI : INTEGER :=
        intMux(PH_ACC_BITS, QUANTIZER_BITS+17, (PH_ACC_BITS-QUANTIZER_BITS)>17);
  constant LSB_BITS     : INTEGER := PH_ACC_BITSI - QUANTIZER_BITS;
  -- Define MACC bitwidth
  constant MACC_BITS    : INTEGER := intMux(44, 48, FPGA_FAMILY=26);
  -- Calculate Trigonometry Constant
  constant RC_const     : INTEGER := intMux(MACC_BITS-18-QUANTIZER_BITS, 14,
                                          (MACC_BITS-18-QUANTIZER_BITS) >= 14);
  constant TRIG_CONST : std_logic_vector(17 downto 0) := trigon_const(RC_const);

  constant COM_POLARITY: INTEGER :=
                        SIN_POLARITY + 2*COS_POLARITY + 10*SIN_ON + 100*COS_ON;

  SIGNAL delA_interi  : STD_LOGIC_VECTOR(35 DOWNTO 0);
  SIGNAL sin_corri    : STD_LOGIC_VECTOR(35 DOWNTO 0);
  SIGNAL cos_corri    : STD_LOGIC_VECTOR(35 DOWNTO 0);
  SIGNAL sin_corrii   : STD_LOGIC_VECTOR(35 DOWNTO 0);
  SIGNAL cos_corrii   : STD_LOGIC_VECTOR(35 DOWNTO 0);
  SIGNAL delA_inter   : STD_LOGIC_VECTOR(17 DOWNTO 0);
  SIGNAL ph_lsb_18    : STD_LOGIC_VECTOR(17 DOWNTO 0);
  SIGNAL sinA_18, cosA_18 : STD_LOGIC_VECTOR(17 DOWNTO 0);
  SIGNAL sin_corr     : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL cos_corr     : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL dbg_cos      : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL ph_lsb       : STD_LOGIC_VECTOR(LSB_BITS-1 DOWNTO 0);
  SIGNAL ph_lsb_dly   : STD_LOGIC_VECTOR(LSB_BITS-1 DOWNTO 0);
  SIGNAL sinA_ext     : STD_LOGIC_VECTOR(MACC_BITS-1 DOWNTO 0);
  SIGNAL cosA_ext     : STD_LOGIC_VECTOR(MACC_BITS-1 DOWNTO 0);
  SIGNAL add_sinA     : STD_LOGIC_VECTOR(MACC_BITS-1 DOWNTO 0);
  SIGNAL add_cosA     : STD_LOGIC_VECTOR(MACC_BITS-1 DOWNTO 0);
  SIGNAL sin48        : STD_LOGIC_VECTOR(MACC_BITS-1 DOWNTO 0);
  SIGNAL cos48        : STD_LOGIC_VECTOR(MACC_BITS-1 DOWNTO 0);
  SIGNAL pout         : STD_LOGIC_VECTOR(MACC_BITS-1 DOWNTO 0);
  SIGNAL sin48_sc     : STD_LOGIC_VECTOR(MACC_BITS-1 DOWNTO 0);
  SIGNAL cos48_sc     : STD_LOGIC_VECTOR(MACC_BITS-1 DOWNTO 0);
  SIGNAL ph_accum_ini : STD_LOGIC_VECTOR(PH_ACC_BITSI-1 DOWNTO 0);
  SIGNAL sub_ctrl     : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL sin_sub, cos_sub : STD_LOGIC;

BEGIN
  -- Define constant add/sub modes for sin +/- delta*cos and cos -/+ delta*sin
  -- calculations
  --                        SIN_POLARITY  COS_POLARITY  SinSub   CosSub
  -- SIN_ON=1; COS_ON=0           0             0         0         1
  --                              0             1         1         x
  --                              1             0         1         x
  --                              1             1         0         x
  -- SIN_ON=0; COS_ON=1           0             0         0         1
  --                              0             1         0         0
  --                              1             0         0         0
  --                              1             1         0         1
  -- SIN_ON=1; COS_ON=1           0             0         0         1
  --                              0             1         1         0
  --                              1             0         1         0
  --                              1             1         0         1
  sub_ctrl <= sub_const(COM_POLARITY);
  sin_sub <= sub_ctrl(0);
  cos_sub <= sub_ctrl(1);

  -- Take not more than QUANTIZER_BITS+17 of the Phase Accum, that is discard
  -- some LSB's if necessary
  ph_accum_ini <= ph_accum_in(PH_ACC_BITS - 1 DOWNTO PH_ACC_BITS - PH_ACC_BITSI);
  -- If PH_ACC_BITS==QUANTIZER_BITS, the trig_cor module won't be instantiated
  ph_lsb <= ph_accum_ini(LSB_BITS-1 DOWNTO 0);

  -- sin/cos from LUT output can be delayed regarding the phase_accum truncated
  --  LSB's. To balance the delays, delay the ph_lsb depending on the LATENCY
  --  and modes
  bal_dly_0 : balance_dly
    GENERIC MAP (
      PH_ACC_BITS     => PH_ACC_BITSI,
      QUANTIZER_BITS  => QUANTIZER_BITS,
      PIPE4EXT        => PIPE4EXT,
      PIPE6           => PIPE6,
      PIPE7           => PIPE7  )
    PORT MAP (
      nGrst       => nGrst,
      clk         => clk,
      ph_lsb_in   => ph_lsb,
      ph_lsb_dly  => ph_lsb_dly  );

  -- Extend it to 18 bits. Note, ph_lsb is always positive
  signExt_0 : dds_signExt
    GENERIC MAP (
      INWIDTH   => LSB_BITS,
      OUTWIDTH  => 18,
      UNSIGN    => 1,
      DROP_MSB  => 0  )
    PORT MAP (
      inp   => ph_lsb_dly,
      outp  => ph_lsb_18  );

  -- delA_interi = TRIG_CONST*ph_lsb;
  const_mult_0 : mac18x18_dds
    GENERIC MAP (
      BYPASS_REG_A  => 1,
      BYPASS_REG_B  => 1-PIPE8,
      BYPASS_REG_C  => 1,
      BYPASS_REG_P  => 1-PIPE9,
      MULT_ADD      => 0,           -- Multiplier, no adder
      FPGA_FAMILY   => FPGA_FAMILY  )
    PORT MAP (
      nGrst     => nGrst,
      rstn      => rstn,
      clk       => clk,
      en_a      => '1',
      en_b      => '1',
      en_c      => '1',
      en_p      => '1',
      mcand_a   => TRIG_CONST,
      mcand_b   => ph_lsb_18,
      addend_c  => (others=>'X'),
      sub       => '0',
      pout      => pout  );
  delA_interi <= pout(35 DOWNTO 0);
  -- Shrink delA_interi to 18 bits
  delA_inter <= delA_interi(LSB_BITS+17 DOWNTO LSB_BITS);

  signExt_sin_0 : dds_signExt
    GENERIC MAP (
      INWIDTH   => OUTPUT_BITS,
      OUTWIDTH  => MACC_BITS,
      UNSIGN    => 0,
      DROP_MSB  => 0 )
    PORT MAP (
      inp   => sinA,
      outp  => sinA_ext );

  signExt_cos_0 : dds_signExt
    GENERIC MAP (
      INWIDTH   => OUTPUT_BITS,
      OUTWIDTH  => MACC_BITS,
      UNSIGN    => 0,
      DROP_MSB  => 0 )
    PORT MAP (
      inp   => cosA,
      outp  => cosA_ext  );

  add_sinA <= leftShiftL (sinA_ext, (RC_const + QUANTIZER_BITS));
  add_cosA <= leftShiftL (cosA_ext, (RC_const + QUANTIZER_BITS));

  signExt_sin18_0 : dds_signExt
    GENERIC MAP (
      INWIDTH   => OUTPUT_BITS,
      OUTWIDTH  => 18,
      UNSIGN    => 0,
      DROP_MSB  => 0 )
    PORT MAP (
      inp   => sinA,
      outp  => sinA_18 );

  signExt_cos18_0 : dds_signExt
    GENERIC MAP (
      INWIDTH   => OUTPUT_BITS,
      OUTWIDTH  => 18,
      UNSIGN    => 0,
      DROP_MSB  => 0 )
    PORT MAP (
      inp   => cosA,
      outp  => cosA_18 );

  madd_0 : mac18x18_dds
    GENERIC MAP (
      BYPASS_REG_A  => 1-PIPE10,
      BYPASS_REG_B  => 1-PIPE10,
      BYPASS_REG_C  => 1-PIPE10,
      BYPASS_REG_P  => 1-PIPE11,
      MULT_ADD      => 1,           -- Multiplier + adder
      FPGA_FAMILY   => FPGA_FAMILY  )
    PORT MAP (
      nGrst     => nGrst,
      rstn      => rstn,
      clk       => clk,
      en_a      => '1',
      en_b      => '1',
      en_c      => '1',
      en_p      => '1',
      mcand_a   => cosA_18,
      mcand_b   => delA_inter,
      addend_c  => add_sinA,
--03/20/17      sub       => '0',
      sub       => sin_sub,
      pout      => sin48  );

  madd_1 : mac18x18_dds
    GENERIC MAP (
      BYPASS_REG_A  => 1-PIPE10,
      BYPASS_REG_B  => 1-PIPE10,
      BYPASS_REG_C  => 1-PIPE10,
      BYPASS_REG_P  => 1-PIPE11,
      MULT_ADD      => 1,           -- Multiplier + adder
      FPGA_FAMILY   => FPGA_FAMILY  )
    PORT MAP (
      nGrst     => nGrst,
      rstn      => rstn,
      clk       => clk,
      en_a      => '1',
      en_b      => '1',
      en_c      => '1',
      en_p      => '1',
      mcand_a   => sinA_18,
      mcand_b   => delA_inter,
      addend_c  => add_cosA,
--03/20/17      sub       => '1',
      sub       => cos_sub,
      pout      => cos48  );

  --  assign sin48_sc = $signed(sin48) >>> (RC_const + QUANTIZER_BITS);
  --  assign cos48_sc = $signed(cos48) >>> (RC_const + QUANTIZER_BITS);
  sin48_sc <= rightShiftA(sin48, (RC_const + QUANTIZER_BITS) );
  cos48_sc <= rightShiftA(cos48, (RC_const + QUANTIZER_BITS) );

  sin_o <= sin48_sc(OUTPUT_BITS-1 DOWNTO 0);
  cos_o <= cos48_sc(OUTPUT_BITS-1 DOWNTO 0);

END ARCHITECTURE rtl;



--            +-+-+-+ +-+-+-+ +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+
--            |M|A|C| |F|o|r| |T|r|i|g|o|n|o|m| |C|o|r|r|e|c|t|i|o|n|
--            +-+-+-+ +-+-+-+ +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY mac18x18_dds IS
  GENERIC (
    BYPASS_REG_A            : INTEGER := 0;
    BYPASS_REG_B            : INTEGER := 0;
    BYPASS_REG_C            : INTEGER := 0;
    BYPASS_REG_P            : INTEGER := 0;
    MULT_ADD                : INTEGER := 1;   --  0-Mult only
    FPGA_FAMILY             : INTEGER := 26 );
  PORT (
    nGrst     : IN STD_LOGIC;
    rstn      : IN STD_LOGIC;
    clk       : IN STD_LOGIC;
    en_a      : IN STD_LOGIC;
    en_b      : IN STD_LOGIC;
    en_c      : IN STD_LOGIC;
    en_p      : IN STD_LOGIC;
    mcand_a   : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    mcand_b   : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    addend_c  : IN STD_LOGIC_VECTOR(intMux(44, 48, FPGA_FAMILY=26)-1 DOWNTO 0);
    pout      : OUT STD_LOGIC_VECTOR(intMux(44, 48, FPGA_FAMILY=26)-1 DOWNTO 0);
    sub       : IN STD_LOGIC  );    --  0-add; 1-sub
END ENTITY mac18x18_dds;

--P_WIDTH = intMux(44, 48, FPGA_FAMILY=26);

ARCHITECTURE rtl OF mac18x18_dds IS

  component MACC      --  G4
    port( CLK        : in  std_logic_vector(1 downto 0);
          A          : in  std_logic_vector(17 downto 0);
          A_EN       : in  std_logic_vector(1 downto 0);
          A_ARST_N   : in  std_logic_vector(1 downto 0);
          A_SRST_N   : in  std_logic_vector(1 downto 0);
          A_BYPASS   : in  std_logic_vector(1 downto 0);

          B          : in  std_logic_vector(17 downto 0);
          B_EN       : in  std_logic_vector(1 downto 0);
          B_ARST_N   : in  std_logic_vector(1 downto 0);
          B_SRST_N   : in  std_logic_vector(1 downto 0);
          B_BYPASS   : in  std_logic_vector(1 downto 0);

          C          : in std_logic_vector(43 downto 0);
          C_EN       : in std_logic_vector(1 downto 0);
          C_ARST_N   : in std_logic_vector(1 downto 0);
          C_SRST_N   : in std_logic_vector(1 downto 0);
          C_BYPASS   : in std_logic_vector(1 downto 0);
          CARRYIN    : in std_logic;

          P          : out std_logic_vector(43 downto 0);
          CDOUT      : out std_logic_vector(43 downto 0);
          P_EN       : in  std_logic_vector(1 downto 0);
          P_ARST_N   : in  std_logic_vector(1 downto 0);
          P_SRST_N   : in  std_logic_vector(1 downto 0);
          P_BYPASS   : in  std_logic_vector(1 downto 0);

          OVFL_CARRYOUT : out std_logic;

          CDIN       : in  std_logic_vector(43 downto 0);

          SUB        : in  std_logic;
          SUB_EN     : in  std_logic;
          SUB_AD     : in  std_logic;
          SUB_AL_N   : in  std_logic;
          SUB_SD_N   : in  std_logic;
          SUB_SL_N   : in  std_logic;
          SUB_BYPASS : in  std_logic;

          ARSHFT17        : in  std_logic;
          ARSHFT17_EN     : in  std_logic;
          ARSHFT17_AD     : in  std_logic;
          ARSHFT17_AL_N   : in  std_logic;
          ARSHFT17_SD_N   : in  std_logic;
          ARSHFT17_SL_N   : in  std_logic;
          ARSHFT17_BYPASS : in  std_logic;

          FDBKSEL        : in  std_logic;
          FDBKSEL_EN     : in  std_logic;
          FDBKSEL_AD     : in  std_logic;
          FDBKSEL_AL_N   : in  std_logic;
          FDBKSEL_SD_N   : in  std_logic;
          FDBKSEL_SL_N   : in  std_logic;
          FDBKSEL_BYPASS : in  std_logic;

          CDSEL        : in  std_logic;
          CDSEL_EN     : in  std_logic;
          CDSEL_AD     : in  std_logic;
          CDSEL_AL_N   : in  std_logic;
          CDSEL_SD_N   : in  std_logic;
          CDSEL_SL_N   : in  std_logic;
          CDSEL_BYPASS : in  std_logic;

          OVFL_CARRYOUT_SEL : in  std_logic;

          SIMD       : in  std_logic;
          DOTP       : in  std_logic  );
  end component;

  component MACC_PA     --  PolarFire
    port( CLK                   : in  std_logic;
          AL_N                  : in  std_logic;
          A                     : in  std_logic_vector(17 downto 0);
          A_BYPASS              : in  std_logic;
          A_SRST_N              : in  std_logic;
          A_EN                  : in  std_logic;
          B                     : in  std_logic_vector(17 downto 0);
          B_BYPASS              : in  std_logic;
          B_SRST_N              : in  std_logic;
          B_EN                  : in  std_logic;
          D                     : in  std_logic_vector(17 downto 0);
          D_ARST_N              : in  std_logic;
          D_BYPASS              : in  std_logic;
          D_SRST_N              : in  std_logic;
          D_EN                  : in  std_logic;
          CARRYIN               : in  std_logic;
          C                     : in  std_logic_vector(47 downto 0);
          C_BYPASS              : in  std_logic;
          C_ARST_N              : in  std_logic;
          C_SRST_N              : in  std_logic;
          C_EN                  : in  std_logic;
          CDIN                  : in std_logic_vector(47 downto 0);
          P                     : out std_logic_vector(47 downto 0);
          OVFL_CARRYOUT         : out std_logic;
          CDOUT                 : out std_logic_vector(47 downto 0);
          P_EN                  : in  std_logic;
          P_SRST_N              : in  std_logic;
          P_BYPASS              : in  std_logic;
          PASUB                 : in  std_logic;
          PASUB_BYPASS          : in  std_logic;
          PASUB_AD_N            : in  std_logic;
          PASUB_SL_N            : in  std_logic;
          PASUB_SD_N            : in  std_logic;
          PASUB_EN              : in  std_logic;
          SUB                   : in  std_logic;
          SUB_EN                : in  std_logic;
          SUB_AD_N              : in  std_logic;
          SUB_SD_N              : in  std_logic;
          SUB_SL_N              : in  std_logic;
          SUB_BYPASS            : in  std_logic;
          ARSHFT17              : in  std_logic;
          ARSHFT17_EN           : in  std_logic;
          ARSHFT17_AD_N         : in  std_logic;
          ARSHFT17_SD_N         : in  std_logic;
          ARSHFT17_SL_N         : in  std_logic;
          ARSHFT17_BYPASS       : in  std_logic;
          CDIN_FDBK_SEL         : in  std_logic_vector(1 downto 0);
          CDIN_FDBK_SEL_BYPASS  : in  std_logic;
          CDIN_FDBK_SEL_AD_N    : in  std_logic_vector(1 downto 0);
          CDIN_FDBK_SEL_SD_N    : in  std_logic_vector(1 downto 0);
          CDIN_FDBK_SEL_SL_N    : in  std_logic;
          CDIN_FDBK_SEL_EN      : in  std_logic;
          OVFL_CARRYOUT_SEL     : in  std_logic;
          SIMD                  : in  std_logic;
          DOTP                  : in  std_logic  );
  end component;

  SIGNAL BY_REGA, BY_REGB, BY_REGC, BY_REGP : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL ea_w                    : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL eb_w                    : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL ec_w                    : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL ep_w                    : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL rstn_a_w                : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL rstn_b_w                : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL rstn_c_w                : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL rstn_p_w                : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL arstn_a                 : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL arstn_b                 : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL arstn_c                 : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL arstn_p                 : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL sel_cdin                : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL a_bp_g5                 : STD_LOGIC;
  SIGNAL a_rs_g5                 : STD_LOGIC;
  SIGNAL a_en_g5                 : STD_LOGIC;
  SIGNAL b_bp_g5                 : STD_LOGIC;
  SIGNAL b_rs_g5                 : STD_LOGIC;
  SIGNAL b_en_g5                 : STD_LOGIC;
  SIGNAL c_bp_g5                 : STD_LOGIC;
  SIGNAL c_rs_g5                 : STD_LOGIC;
  SIGNAL c_en_g5                 : STD_LOGIC;
  SIGNAL c_ar_g5                 : STD_LOGIC;
  SIGNAL p_bp_g5                 : STD_LOGIC;
  SIGNAL p_rs_g5                 : STD_LOGIC;
  SIGNAL p_en_g5                 : STD_LOGIC;

BEGIN

  BY_REGA <= "11" WHEN (BYPASS_REG_A /= 0) ELSE "00";
  BY_REGB <= "11" WHEN (BYPASS_REG_B /= 0) ELSE "00";
  BY_REGC <= "11" WHEN (BYPASS_REG_C /= 0) ELSE "00";
  BY_REGP <= "11" WHEN (BYPASS_REG_P /= 0) ELSE "00";

  ea_w <= "11" WHEN (BYPASS_REG_A /= 0) ELSE (en_a & en_a);
  eb_w <= "11" WHEN (BYPASS_REG_B /= 0) ELSE (en_b & en_b);
  ec_w <= "11" WHEN (BYPASS_REG_C /= 0) ELSE (en_c & en_c);
  ep_w <= "11" WHEN (BYPASS_REG_P /= 0) ELSE (en_p & en_p);

  bypass_A : IF (BYPASS_REG_A = 1) GENERATE
    rstn_a_w  <= "11";
    arstn_a   <= "11";
    a_bp_g5   <= '1';
    a_rs_g5   <= '1';
    a_en_g5   <= '1';
  END GENERATE;
  use_A : IF (BYPASS_REG_A /= 1) GENERATE
    rstn_a_w  <= (rstn & rstn);
    arstn_a   <= (nGrst & nGrst);
    a_bp_g5   <= '0';
    a_rs_g5   <= rstn;
    a_en_g5   <= en_a;
  END GENERATE;

  bypass_B : IF (BYPASS_REG_B = 1) GENERATE
    rstn_b_w  <= "11";
    arstn_b   <= "11";
    b_bp_g5   <= '1';
    b_rs_g5   <= '1';
    b_en_g5   <= '1';
  END GENERATE;
  use_B : IF (BYPASS_REG_B /= 1) GENERATE
    rstn_b_w  <= (rstn & rstn);
    arstn_b   <= (nGrst & nGrst);
    b_bp_g5   <= '0';
    b_rs_g5   <= rstn;
    b_en_g5   <= en_b;
  END GENERATE;

  bypass_C : IF (BYPASS_REG_C = 1) GENERATE
    rstn_c_w  <= "11";
    arstn_c   <= "11";
    c_bp_g5   <= '1';
    c_rs_g5   <= '1';
    c_en_g5   <= '1';
    c_ar_g5   <= '1';
  END GENERATE;
  use_C : IF (BYPASS_REG_C /= 1) GENERATE
    rstn_c_w  <= (rstn & rstn);
    arstn_c   <= (nGrst & nGrst);
    c_bp_g5   <= '0';
    c_rs_g5   <= rstn;
    c_en_g5   <= en_c;
    c_ar_g5   <= nGrst;
  END GENERATE;

  bypass_P : IF (BYPASS_REG_P = 1) GENERATE
    rstn_p_w  <= "11";
    arstn_p   <= "11";
    p_bp_g5   <= '1';
    p_rs_g5   <= '1';
    p_en_g5   <= '1';
  END GENERATE;
  use_P : IF (BYPASS_REG_P /= 1) GENERATE
    rstn_p_w  <= (rstn & rstn);
    arstn_p   <= (nGrst & nGrst);
    p_bp_g5   <= '0';
    p_rs_g5   <= rstn;
    p_en_g5   <= en_p;
  END GENERATE;

  g4_add : IF (((FPGA_FAMILY=19) OR (FPGA_FAMILY=24) OR (FPGA_FAMILY=25))
                                                    AND (MULT_ADD=1)) GENERATE
    mac_0 : MACC
      PORT MAP (
        CLK(0)            => clk,
        CLK(1)            => clk,
        A                 => mcand_a,
        A_EN              => ea_w,
        A_ARST_N          => arstn_a,
        A_SRST_N          => rstn_a_w,
        A_BYPASS          => BY_REGA,
        B                 => mcand_b,
        B_EN              => eb_w,
        B_ARST_N          => arstn_b,
        B_SRST_N          => rstn_b_w,
        B_BYPASS          => BY_REGB,
        C                 => addend_c,
        C_EN              => ec_w,
        C_ARST_N          => arstn_c,
        C_SRST_N          => rstn_c_w,
        C_BYPASS          => BY_REGC,
        CARRYIN           => '0',
        P                 => pout,
        CDOUT             => open,
        P_EN              => ep_w,
        P_ARST_N          => arstn_p,
        P_SRST_N          => rstn_p_w,
        P_BYPASS          => BY_REGP,
        OVFL_CARRYOUT     => open,
        CDIN              => "00000000000000000000000000000000000000000000",
        SUB               => sub,
        SUB_EN            => '1',
        SUB_AD            => '0',
        SUB_AL_N          => '1',
        SUB_SD_N          => '1',
        SUB_SL_N          => '1',
        SUB_BYPASS        => '1',
        ARSHFT17          => '0',
        ARSHFT17_EN       => '1',
        ARSHFT17_AD       => '0',
        ARSHFT17_AL_N     => '1',
        ARSHFT17_SD_N     => '1',
        ARSHFT17_SL_N     => '1',
        ARSHFT17_BYPASS   => '1',
        FDBKSEL           => '0',
        FDBKSEL_EN        => '1',
        FDBKSEL_AD        => '0',
        FDBKSEL_AL_N      => '1',
        FDBKSEL_SD_N      => '1',
        FDBKSEL_SL_N      => '1',
        FDBKSEL_BYPASS    => '1',
        CDSEL             => '0',
        CDSEL_EN          => '1',
        CDSEL_AD          => '0',
        CDSEL_AL_N        => '1',
        CDSEL_SD_N        => '1',
        CDSEL_SL_N        => '1',
        CDSEL_BYPASS      => '1',
        OVFL_CARRYOUT_SEL => '0',
        SIMD              => '0',
        DOTP              => '0'   );
  END GENERATE;

  g4_mult : IF (((FPGA_FAMILY=19) OR (FPGA_FAMILY=24) OR (FPGA_FAMILY=25))
                                                  AND (MULT_ADD /= 1)) GENERATE
    mac_0 : MACC
      PORT MAP (
        CLK(0)            => clk,
        CLK(1)            => clk,
        A                 => mcand_a,
        A_EN              => ea_w,
        A_ARST_N          => arstn_a,
        A_SRST_N          => rstn_a_w,
        A_BYPASS          => BY_REGA,
        B                 => mcand_b,
        B_EN              => eb_w,
        B_ARST_N          => arstn_b,
        B_SRST_N          => rstn_b_w,
        B_BYPASS          => BY_REGB,
        C                 => "00000000000000000000000000000000000000000000",
        C_EN              => "11",
        C_ARST_N          => "11",
        C_SRST_N          => "11",
        C_BYPASS          => "11",
        CARRYIN           => '0',
        P                 => pout,
        CDOUT             => open,
        P_EN              => ep_w,
        P_ARST_N          => arstn_p,
        P_SRST_N          => rstn_p_w,
        P_BYPASS          => BY_REGP,
        OVFL_CARRYOUT     => open,
        CDIN              => "00000000000000000000000000000000000000000000",
        SUB               => '0',
        SUB_EN            => '1',
        SUB_AD            => '0',
        SUB_AL_N          => '1',
        SUB_SD_N          => '1',
        SUB_SL_N          => '1',
        SUB_BYPASS        => '1',
        ARSHFT17          => '0',
        ARSHFT17_EN       => '1',
        ARSHFT17_AD       => '0',
        ARSHFT17_AL_N     => '1',
        ARSHFT17_SD_N     => '1',
        ARSHFT17_SL_N     => '1',
        ARSHFT17_BYPASS   => '1',
        FDBKSEL           => '0',
        FDBKSEL_EN        => '1',
        FDBKSEL_AD        => '0',
        FDBKSEL_AL_N      => '1',
        FDBKSEL_SD_N      => '1',
        FDBKSEL_SL_N      => '1',
        FDBKSEL_BYPASS    => '1',
        CDSEL             => '0',
        CDSEL_EN          => '1',
        CDSEL_AD          => '0',
        CDSEL_AL_N        => '1',
        CDSEL_SD_N        => '1',
        CDSEL_SL_N        => '1',
        CDSEL_BYPASS      => '1',
        OVFL_CARRYOUT_SEL => '0',
        SIMD              => '0',
        DOTP              => '0'   );
  END GENERATE;

  g5_add : IF ((FPGA_FAMILY = 26) AND (MULT_ADD = 1)) GENERATE
    macc_0 : MACC_PA
      PORT MAP (
        CLK                   => clk,
        AL_N                  => nGrst,
        A                     => mcand_a,
        A_BYPASS              => a_bp_g5,
        A_SRST_N              => a_rs_g5,
        A_EN                  => a_en_g5,
        B                     => mcand_b,
        B_BYPASS              => b_bp_g5,
        B_SRST_N              => b_rs_g5,
        B_EN                  => b_en_g5,
        D                     => "111111111111111111",
        D_ARST_N              => nGrst,
        D_BYPASS              => '0',
        D_SRST_N              => '0',
        D_EN                  => '1',
        CARRYIN               => '0',
        C                     => addend_c,
        C_BYPASS              => c_bp_g5,
        C_ARST_N              => c_ar_g5,
        C_SRST_N              => c_rs_g5,
        C_EN                  => c_en_g5,
        CDIN                  => "000000000000000000000000000000000000000000000000",
        P                     => pout,
        OVFL_CARRYOUT         => open,
        CDOUT                 => open,
        P_EN                  => p_en_g5,
        P_SRST_N              => p_rs_g5,
        P_BYPASS              => p_bp_g5,
        PASUB                 => '0',
        PASUB_BYPASS          => '0',
        PASUB_AD_N            => '0',
        PASUB_SL_N            => '0',
        PASUB_SD_N            => '0',
        PASUB_EN              => '1',
        SUB                   => sub,
        SUB_EN                => '1',
        SUB_AD_N              => '1',
        SUB_SD_N              => '1',
        SUB_SL_N              => '1',
        SUB_BYPASS            => '1',
        ARSHFT17              => '0',
        ARSHFT17_EN           => '1',
        ARSHFT17_AD_N         => '1',
        ARSHFT17_SD_N         => '1',
        ARSHFT17_SL_N         => '1',
        ARSHFT17_BYPASS       => '1',
        CDIN_FDBK_SEL         => "00",
        CDIN_FDBK_SEL_BYPASS  => '1',
        CDIN_FDBK_SEL_AD_N    => "11",
        CDIN_FDBK_SEL_SD_N    => "11",
        CDIN_FDBK_SEL_SL_N    => '1',
        CDIN_FDBK_SEL_EN      => '1',
        OVFL_CARRYOUT_SEL     => '0',
        SIMD                  => '0',
        DOTP                  => '0'  );
  END GENERATE;

  g5_mult : IF ((FPGA_FAMILY = 26) AND (MULT_ADD /= 1)) GENERATE
    macc_0 : MACC_PA
      PORT MAP (
        CLK                   => clk,
        AL_N                  => nGrst,
        A                     => mcand_a,
        A_BYPASS              => a_bp_g5,
        A_SRST_N              => a_rs_g5,
        A_EN                  => a_en_g5,
        B                     => mcand_b,
        B_BYPASS              => b_bp_g5,
        B_SRST_N              => b_rs_g5,
        B_EN                  => b_en_g5,
        D                     => "111111111111111111",
        D_ARST_N              => nGrst,
        D_BYPASS              => '0',
        D_SRST_N              => '0',
        D_EN                  => '1',
        CARRYIN               => '1',
        C                     => "111111111111111111111111111111111111111111111111",
        C_BYPASS              => '0',
        C_ARST_N              => nGrst,
        C_SRST_N              => '0',
        C_EN                  => '1',
        CDIN                  => "000000000000000000000000000000000000000000000000",
        P                     => pout,
        OVFL_CARRYOUT         => open,
        CDOUT                 => open,
        P_EN                  => p_en_g5,
        P_SRST_N              => p_rs_g5,
        P_BYPASS              => p_bp_g5,
        PASUB                 => '0',
        PASUB_BYPASS          => '0',
        PASUB_AD_N            => '0',
        PASUB_SL_N            => '0',
        PASUB_SD_N            => '0',
        PASUB_EN              => '1',
        SUB                   => '0',
        SUB_EN                => '1',
        SUB_AD_N              => '1',
        SUB_SD_N              => '1',
        SUB_SL_N              => '1',
        SUB_BYPASS            => '1',
        ARSHFT17              => '0',
        ARSHFT17_EN           => '1',
        ARSHFT17_AD_N         => '1',
        ARSHFT17_SD_N         => '1',
        ARSHFT17_SL_N         => '1',
        ARSHFT17_BYPASS       => '1',
        CDIN_FDBK_SEL         => "00",
        CDIN_FDBK_SEL_BYPASS  => '1',
        CDIN_FDBK_SEL_AD_N    => "11",
        CDIN_FDBK_SEL_SD_N    => "11",
        CDIN_FDBK_SEL_SL_N    => '1',
        CDIN_FDBK_SEL_EN      => '1',
        OVFL_CARRYOUT_SEL     => '0',
        SIMD                  => '0',
        DOTP                  => '0'   );
  END GENERATE;

END ARCHITECTURE rtl;




------------------------------------------------------------------------------/
--                    ____  ____  ____  _   _  ____  ____
--                   (  _ \(_  _)(_  _)( )_( )( ___)(  _ \
--                    )(_) )_)(_   )(   ) _ (  )__)  )   /
--                   (____/(____) (__) (_) (_)(____)(_)\_)
--
------------------------------------------------------------------------------/
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
USE work.dds_rtl_pack.all;

--                        +-+-+-+-+ +-+-+-+ +-+-+-+-+
--                        |L|F|S|R| |L|U|T| |I|n|i|t|
--                        +-+-+-+-+ +-+-+-+ +-+-+-+-+
ENTITY dds_lfsr_lut IS
  GENERIC (
    FPGA_FAMILY           : INTEGER := 26;
    SIMUL_RAM             : INTEGER := 1;
    DBG                   : INTEGER := 0  );    --1-simulation mux; 0-RAM
  PORT (
    clk                   : IN STD_LOGIC;
    nGrst                 : IN STD_LOGIC;
    rA                    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    aggr_poly             : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
    -- Initialization ports
    slow_clk              : IN STD_LOGIC;
    lfsr_wEn              : IN STD_LOGIC;
    lfsr_wA               : IN STD_LOGIC_VECTOR(3 DOWNTO 0) );
END ENTITY dds_lfsr_lut;

ARCHITECTURE rtl OF dds_lfsr_lut IS
  COMPONENT lfsrRAM
    GENERIC ( FPGA_FAMILY : INTEGER := 26;
              SIMUL_RAM   : INTEGER := 0  );
    PORT (
      rClk                    : IN STD_LOGIC;
      wClk                    : IN STD_LOGIC;
      wEn                     : IN STD_LOGIC;
      wA                      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      rA                      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      Q                       : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)  );
  END COMPONENT;
  SIGNAL ap                    : STD_LOGIC_VECTOR(5 DOWNTO 0);

BEGIN
  main : IF (DBG = 0) GENERATE
    lfsr_lut_0 : lfsrRAM
      GENERIC MAP (
        FPGA_FAMILY  => FPGA_FAMILY,
        SIMUL_RAM    => SIMUL_RAM  )
      PORT MAP (
        rClk  => clk,
        wClk  => slow_clk,
        wEn   => lfsr_wEn,
        wA    => lfsr_wA,
        -- Read ports
        rA    => rA,
        Q     => aggr_poly  );
  END GENERATE;

--  LFSR 6-bit table; LFSR length = 21, Poly = 140000
--   0   0
--   1   28000
--   2   50000
--   3   78000
--   4   a0000
--   5   88000
--   6   f0000
--   7   d8000
--   8   140000
--   9   168000
--  10   110000
--  11   138000
--  12   1e0000
--  13   1c8000
--  14   1b0000
--  15   198000

  simul : IF (DBG = 1) GENERATE

    PROCESS (rA)
    BEGIN
      CASE rA IS
        WHEN "0000" =>  ap <= "000000";
        WHEN "0001" =>  ap <= "000101";
        WHEN "0010" =>  ap <= "001010";
        WHEN "0011" =>  ap <= "001111";
        WHEN "0100" =>  ap <= "010100";
        WHEN "0101" =>  ap <= "010001";
        WHEN "0110" =>  ap <= "011110";
        WHEN "0111" =>  ap <= "011011";
        WHEN "1000" =>  ap <= "101000";
        WHEN "1001" =>  ap <= "101101";
        WHEN "1010" =>  ap <= "100010";
        WHEN "1011" =>  ap <= "100111";
        WHEN "1100" =>  ap <= "111100";
        WHEN "1101" =>  ap <= "111001";
        WHEN "1110" =>  ap <= "110110";
        WHEN "1111" =>  ap <= "110011";
        WHEN OTHERS =>  ap <= "000000";
      END CASE;
    END PROCESS;

    -- Replicate 2-clk delay to match the actual lfsrRAM
    dlyMatch_0 : dds_kitDelay_reg
      GENERIC MAP ( BITWIDTH  => 6,
                    DELAY     => 2 )
      PORT MAP (
        nGrst =>  nGrst,
        rst   =>  '0',
        clk   =>  clk,
        clkEn =>  '1',
        inp   =>  ap,
        outp  =>  aggr_poly );
  END GENERATE;
END ARCHITECTURE rtl;




-- 21-bit Galois LFSR updates by 4 bits per clock
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
USE work.dds_rtl_pack.all;

ENTITY dds_lfsr IS
  GENERIC ( FPGA_FAMILY : INTEGER := 26;
            SIMUL_RAM   : INTEGER := 1  );
  PORT (
    clk                   : IN STD_LOGIC;
    nGrst                 : IN STD_LOGIC;
    rstn                  : IN STD_LOGIC;
    init                  : IN STD_LOGIC;
    lfsr                  : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
    -- LFSR LUT initialization ports
    slow_clk              : IN STD_LOGIC;
    lfsr_wEn              : IN STD_LOGIC;
    lfsr_wA               : IN STD_LOGIC_VECTOR(3 DOWNTO 0)  );
END ENTITY dds_lfsr;

ARCHITECTURE rtl OF dds_lfsr IS
  COMPONENT dds_lfsr_lut
    GENERIC (
      FPGA_FAMILY           : INTEGER := 26;
      SIMUL_RAM             : INTEGER := 1;
      DBG                   : INTEGER := 0  );    --1-simulation mux; 0-RAM
    PORT (
      clk                   : IN STD_LOGIC;
      nGrst                 : IN STD_LOGIC;
      rA                    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      aggr_poly             : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
      -- Initialization ports
      slow_clk              : IN STD_LOGIC;
      lfsr_wEn              : IN STD_LOGIC;
      lfsr_wA               : IN STD_LOGIC_VECTOR(3 DOWNTO 0) );
  END COMPONENT;

  SIGNAL aggr_poly             : STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL lfsr_ctrl_4bits       : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL lfsri            : STD_LOGIC_VECTOR(20 DOWNTO 0);
BEGIN
  lfsr <= lfsri;
  lfsr_ctrl_4bits <= lfsri(11 DOWNTO 8);

  -- LFSR LUT has 2-clk latency: rA and rD pipes. Use the four bits output
  -- advanced by 2 clk to negate the latency
  -- LFSR LUT initialization ports
  lfsr_lut_0 : dds_lfsr_lut
    GENERIC MAP ( FPGA_FAMILY  => FPGA_FAMILY,
                  SIMUL_RAM    => SIMUL_RAM  )
    PORT MAP (
      clk        => clk,
      nGrst      => nGrst,
      rA         => lfsr_ctrl_4bits,
      aggr_poly  => aggr_poly,
      slow_clk   => slow_clk,
      lfsr_wen   => lfsr_wEn,
      lfsr_wa    => lfsr_wA  );

  -- Initialize LFSR with 1; shift to the righ by 4 taps
  PROCESS (nGrst, clk)
  BEGIN
    IF (nGrst = '0') THEN
      lfsri <= "100000000000000000000";
    ELSIF (clk'EVENT AND clk = '1') THEN
      IF (init = '1') THEN
        lfsri <= "100000000000000000000";
      ELSE
        lfsri(20 DOWNTO 17) <= aggr_poly(5 DOWNTO 2);
        lfsri(16 DOWNTO 15) <= lfsri(20 DOWNTO 19) XOR aggr_poly(1 DOWNTO 0);
        lfsri(14 DOWNTO 0) <= lfsri(18 DOWNTO 4);
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE rtl;




LIBRARY ieee;
  USE ieee.std_logic_1164.all;
USE work.dds_rtl_pack.all;

ENTITY dds_dither IS
  GENERIC ( FPGA_FAMILY : INTEGER := 26;
            SIMUL_RAM   : INTEGER := 1  );
  PORT (
    clk             : IN STD_LOGIC;
    rstn            : IN STD_LOGIC;
    nGrst           : IN STD_LOGIC;
    init            : IN STD_LOGIC;		-- Bring lfsr_wEn here
    dither          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    slow_clk        : IN STD_LOGIC;		-- LFSR LUT initialization
    lfsr_wEn        : IN STD_LOGIC;   -- LUT initialization
    lfsr_wA         : IN STD_LOGIC_VECTOR(3 DOWNTO 0)  ); -- LUT initialization
END ENTITY dds_dither;

ARCHITECTURE rtl OF dds_dither IS
  COMPONENT dds_lfsr
    GENERIC ( FPGA_FAMILY : INTEGER := 26;
              SIMUL_RAM   : INTEGER := 1  );
    PORT (
      clk                   : IN STD_LOGIC;
      nGrst                 : IN STD_LOGIC;
      rstn                  : IN STD_LOGIC;
      init                  : IN STD_LOGIC;
      lfsr                  : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
      -- LFSR LUT initialization ports
      slow_clk              : IN STD_LOGIC;
      lfsr_wEn              : IN STD_LOGIC;
      lfsr_wA               : IN STD_LOGIC_VECTOR(3 DOWNTO 0)  );
  END COMPONENT;

  SIGNAL lfsr : STD_LOGIC_VECTOR(20 DOWNTO 0);
BEGIN
  lfsr_0 : dds_lfsr
    GENERIC MAP (
      FPGA_FAMILY  => FPGA_FAMILY,
      SIMUL_RAM    => SIMUL_RAM   )
    PORT MAP (
      clk       => clk,
      nGrst     => nGrst,
      rstn      => rstn,
      init      => init,
      lfsr      => lfsr,
      -- LFSR LUT initialization ports
      slow_clk  => slow_clk,
      lfsr_wen  => lfsr_wEn,
      lfsr_wa   => lfsr_wA  );

  dither <= lfsr(3 DOWNTO 0);
END ARCHITECTURE rtl;



--                             +-+-+-+-+ +-+-+-+
--                             |L|F|S|R| |L|U|T|
--                             +-+-+-+-+ +-+-+-+
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
USE work.dds_rtl_pack.all;

-- LFSR LUT is of a fixed size 16x6
ENTITY lfsrRAM IS
  GENERIC ( FPGA_FAMILY : INTEGER := 26;
            SIMUL_RAM   : INTEGER := 0  );
  PORT (
    rClk                    : IN STD_LOGIC;
    wClk                    : IN STD_LOGIC;
    wEn                     : IN STD_LOGIC;
    wA                      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    rA                      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    Q                       : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)  );
END ENTITY lfsrRAM;

ARCHITECTURE rtl OF lfsrRAM IS
  COMPONENT rtg4_lfsr_uram IS
    port( A_DOUT : out   std_logic_vector(5 downto 0);
          B_DOUT : out   std_logic_vector(5 downto 0);
          C_DIN  : in    std_logic_vector(5 downto 0);
          A_ADDR : in    std_logic_vector(3 downto 0);
          B_ADDR : in    std_logic_vector(3 downto 0);
          C_ADDR : in    std_logic_vector(3 downto 0);
          A_CLK  : in    std_logic;
          C_CLK  : in    std_logic;
--02/03/17          C_BLK  : in    std_logic;
          C_WEN  : in    std_logic  );
  END COMPONENT;

  COMPONENT g4_lfsr_uram IS
    port( A_DOUT : out   std_logic_vector(5 downto 0);
          B_DOUT : out   std_logic_vector(5 downto 0);
          C_DIN  : in    std_logic_vector(5 downto 0);
          A_ADDR : in    std_logic_vector(3 downto 0);
          B_ADDR : in    std_logic_vector(3 downto 0);
          C_ADDR : in    std_logic_vector(3 downto 0);
          A_CLK  : in    std_logic;
          C_CLK  : in    std_logic;
          C_WEN  : in    std_logic  );
  END COMPONENT;

  COMPONENT g5_lfsr_uram IS
    port( rD    : out   std_logic_vector(5 downto 0);
          wD    : in    std_logic_vector(5 downto 0);
          rAddr : in    std_logic_vector(3 downto 0);
          wAddr : in    std_logic_vector(3 downto 0);
          rClk  : in    std_logic;
          wClk  : in    std_logic;
          wEn   : in    std_logic        );
  END COMPONENT;

  COMPONENT lfsr_table IS
    PORT (
      index :  IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      outp  : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)  );
  END COMPONENT;

  SIGNAL wD : STD_LOGIC_VECTOR(5 DOWNTO 0);

BEGIN

  lfsr_table_0 : lfsr_table
    PORT MAP (  index  => wA,
                outp   => wD );

  dbg_model : IF (SIMUL_RAM = 1) GENERATE
    simul_ram_0 : dds_kitRam_fabric
      GENERIC MAP (
        WIDTH     => 6,
        LOGDEPTH  => 4,
        DEPTH     => 16,
        RA_PIPE   => 1,
        RD_PIPE   => 1  )
      PORT MAP (
        nGrst        => '1',
        RCLOCK       => rClk,
        WCLOCK       => wClk,
        WRB          => wEn,
        RDB          => '1',
        rstDataPipe  => '0',
        DI           => wD,
        RADDR        => rA,
        WADDR        => wA,
        DO           => Q  );
  END GENERATE;

  g4_uram : IF((SIMUL_RAM/=1) AND ((FPGA_FAMILY=19)OR(FPGA_FAMILY=24))) GENERATE
    g4_uram_0 : g4_lfsr_uram
      PORT MAP (
        A_DOUT  => Q,
        B_DOUT  => open,
        C_DIN   => wD,
        A_ADDR  => rA,
        B_ADDR  => (OTHERS=>'X'),
        C_ADDR  => wA,
        A_CLK   => rClk,
        C_CLK   => wClk,
        C_WEN   => wEn  );
  END GENERATE;

  rtg4_uram : IF ((SIMUL_RAM /= 1) AND (FPGA_FAMILY = 25)) GENERATE
    rtg4_uram_0 : rtg4_lfsr_uram
      PORT MAP (
        A_DOUT  => Q,
        B_DOUT  => open,
        C_DIN   => wD,
        A_ADDR  => rA,
        B_ADDR  => (OTHERS=>'X'),
        C_ADDR  => wA,
        A_CLK   => rClk,
        C_CLK   => wClk,
--02/03/17        C_BLK   => '1',
        C_WEN   => wEn  );
  END GENERATE;


  g5_uram : IF ((SIMUL_RAM /= 1) AND (FPGA_FAMILY = 26)) GENERATE
    g5_uram_0 : g5_lfsr_uram
      PORT MAP (
        rD     => Q,
        wD     => wD,
        rAddr  => rA,
        wAddr  => wA,
        rClk   => rClk,
        wClk   => wClk,
        wEn    => wEn   );
  END GENERATE;

END ARCHITECTURE rtl;




LIBRARY ieee;
  USE ieee.std_logic_1164.all;
USE work.dds_rtl_pack.all;

ENTITY lfsr_table IS
  PORT (
    index :  IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    outp  : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)  );
END ENTITY lfsr_table;

ARCHITECTURE rtl OF lfsr_table IS
BEGIN
  PROCESS (index)
  BEGIN
    CASE index IS
      WHEN "0000" =>
        outp <= "000000";     -- 0x0
      WHEN "0001" =>
        outp <= "000101";     -- 0x28000
      WHEN "0010" =>
        outp <= "001010";     -- 0x50000
      WHEN "0011" =>
        outp <= "001111";     -- 0x78000
      WHEN "0100" =>
        outp <= "010100";     -- 0xa0000
      WHEN "0101" =>
        outp <= "010001";     -- 0x88000
      WHEN "0110" =>
        outp <= "011110";     -- 0xf0000
      WHEN "0111" =>
        outp <= "011011";     -- 0xd8000
      WHEN "1000" =>
        outp <= "101000";     -- 0x140000
      WHEN "1001" =>
        outp <= "101101";     -- 0x168000
      WHEN "1010" =>
        outp <= "100010";     -- 0x110000
      WHEN "1011" =>
        outp <= "100111";     -- 0x138000
      WHEN "1100" =>
        outp <= "111100";     -- 0x1e0000
      WHEN "1101" =>
        outp <= "111001";     -- 0x1c8000
      WHEN "1110" =>
        outp <= "110110";     -- 0x1b0000
      WHEN "1111" =>
        outp <= "110011";     -- 0x198000
      WHEN OTHERS =>
        NULL;
    END CASE;
  END PROCESS;
END ARCHITECTURE rtl;




-- Version: v12.100 12.100.7.5
library ieee;
use ieee.std_logic_1164.all;
--library polarfire;
--use polarfire.all;

ENTITY g5_lfsr_uram IS
    port( rD    : out   std_logic_vector(5 downto 0);
          wD    : in    std_logic_vector(5 downto 0);
          rAddr : in    std_logic_vector(3 downto 0);
          wAddr : in    std_logic_vector(3 downto 0);
          rClk  : in    std_logic;
          wClk  : in    std_logic;
          wEn   : in    std_logic        );
END g5_lfsr_uram;

ARCHITECTURE DEF_ARCH of g5_lfsr_uram IS
  component RAM64x12
    generic (MEMORYFILE:string := "");
    port( BLK_EN        : in    std_logic := 'U';
          BUSY_FB       : in    std_logic := 'U';
          R_ADDR        : in    std_logic_vector(5 downto 0) := (others => 'U');
          R_ADDR_AD_N   : in    std_logic := 'U';
          R_ADDR_AL_N   : in    std_logic := 'U';
          R_ADDR_BYPASS : in    std_logic := 'U';
          R_ADDR_EN     : in    std_logic := 'U';
          R_ADDR_SD     : in    std_logic := 'U';
          R_ADDR_SL_N   : in    std_logic := 'U';
          R_CLK         : in    std_logic := 'U';
          R_DATA_AD_N   : in    std_logic := 'U';
          R_DATA_AL_N   : in    std_logic := 'U';
          R_DATA_BYPASS : in    std_logic := 'U';
          R_DATA_EN     : in    std_logic := 'U';
          R_DATA_SD     : in    std_logic := 'U';
          R_DATA_SL_N   : in    std_logic := 'U';
          W_ADDR        : in    std_logic_vector(5 downto 0) := (others => 'U');
          W_CLK         : in    std_logic := 'U';
          W_DATA        : in    std_logic_vector(11 downto 0) := (others => 'U');
          W_EN          : in    std_logic := 'U';
          ACCESS_BUSY   : out   std_logic;
          R_DATA        : out   std_logic_vector(11 downto 0)  );
  end component;

  component GND
    port(Y : out std_logic);
  end component;

  component VCC
    port(Y : out std_logic);
  end component;

    signal \ACCESS_BUSY[0][0]\, \VCC\, \GND\, ADLIB_VCC
         : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc6, nc2, nc5, nc4, nc3, nc1 : std_logic;

begin

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    g5_lfsr_uram_R0C0 : RAM64x12
      port map(BLK_EN => \VCC\, BUSY_FB => \GND\, R_ADDR(5) =>
        \GND\, R_ADDR(4) => \GND\, R_ADDR(3) => rAddr(3),
        R_ADDR(2) => rAddr(2), R_ADDR(1) => rAddr(1), R_ADDR(0)
         => rAddr(0), R_ADDR_AD_N => \VCC\, R_ADDR_AL_N => \VCC\,
        R_ADDR_BYPASS => \GND\, R_ADDR_EN => \VCC\, R_ADDR_SD =>
        \GND\, R_ADDR_SL_N => \VCC\, R_CLK => rClk, R_DATA_AD_N
         => \VCC\, R_DATA_AL_N => \VCC\, R_DATA_BYPASS => \GND\,
        R_DATA_EN => \VCC\, R_DATA_SD => \GND\, R_DATA_SL_N =>
        \VCC\, W_ADDR(5) => \GND\, W_ADDR(4) => \GND\, W_ADDR(3)
         => wAddr(3), W_ADDR(2) => wAddr(2), W_ADDR(1) =>
        wAddr(1), W_ADDR(0) => wAddr(0), W_CLK => wClk,
        W_DATA(11) => \GND\, W_DATA(10) => \GND\, W_DATA(9) =>
        \GND\, W_DATA(8) => \GND\, W_DATA(7) => \GND\, W_DATA(6)
         => \GND\, W_DATA(5) => wD(5), W_DATA(4) => wD(4),
        W_DATA(3) => wD(3), W_DATA(2) => wD(2), W_DATA(1) =>
        wD(1), W_DATA(0) => wD(0), W_EN => wEn, ACCESS_BUSY =>
        \ACCESS_BUSY[0][0]\, R_DATA(11) => nc6, R_DATA(10) => nc2,
        R_DATA(9) => nc5, R_DATA(8) => nc4, R_DATA(7) => nc3,
        R_DATA(6) => nc1, R_DATA(5) => rD(5), R_DATA(4) => rD(4),
        R_DATA(3) => rD(3), R_DATA(2) => rD(2), R_DATA(1) =>
        rD(1), R_DATA(0) => rD(0));

    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);
end DEF_ARCH;




-- Version: v11.7 SP1 11.7.1.14
library ieee;
use ieee.std_logic_1164.all;
--library smartfusion2;
--use smartfusion2.all;

entity g4_lfsr_uram is
    port( A_DOUT : out   std_logic_vector(5 downto 0);
          B_DOUT : out   std_logic_vector(5 downto 0);
          C_DIN  : in    std_logic_vector(5 downto 0);
          A_ADDR : in    std_logic_vector(3 downto 0);
          B_ADDR : in    std_logic_vector(3 downto 0);
          C_ADDR : in    std_logic_vector(3 downto 0);
          A_CLK  : in    std_logic;
          C_CLK  : in    std_logic;
          C_WEN  : in    std_logic  );
end g4_lfsr_uram;

architecture DEF_ARCH of g4_lfsr_uram is
  component RAM64x18
    generic (MEMORYFILE:string := "");
    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_ADDR_CLK    : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ADDR_SRST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_ADDR_ARST_N : in    std_logic := 'U';
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_ADDR_EN     : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(9 downto 0) := (others => 'U');
          B_ADDR_CLK    : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ADDR_SRST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_ADDR_ARST_N : in    std_logic := 'U';
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_ADDR_EN     : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(9 downto 0) := (others => 'U');
          C_CLK         : in    std_logic := 'U';
          C_ADDR        : in    std_logic_vector(9 downto 0) := (others => 'U');
          C_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          C_WEN         : in    std_logic := 'U';
          C_BLK         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_ADDR_LAT    : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_EN          : in    std_logic := 'U';
          B_ADDR_LAT    : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          C_EN          : in    std_logic := 'U';
          C_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          SII_LOCK      : in    std_logic := 'U'  );
  end component;

  component GND
    port(Y : out std_logic);
  end component;

  component VCC
    port(Y : out std_logic);
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc24, nc1, nc8, nc13, nc16, nc19, nc20, nc9, nc22,
        nc14, nc5, nc21, nc15, nc3, nc10, nc7, nc17, nc4, nc12,
        nc2, nc23, nc18, nc6, nc11 : std_logic;

begin

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    g4_lfsr_uram_R0C0 : RAM64x18
      port map(A_DOUT(17) => nc24, A_DOUT(16) => nc1, A_DOUT(15)
         => nc8, A_DOUT(14) => nc13, A_DOUT(13) => nc16,
        A_DOUT(12) => nc19, A_DOUT(11) => nc20, A_DOUT(10) => nc9,
        A_DOUT(9) => nc22, A_DOUT(8) => nc14, A_DOUT(7) => nc5,
        A_DOUT(6) => nc21, A_DOUT(5) => A_DOUT(5), A_DOUT(4) =>
        A_DOUT(4), A_DOUT(3) => A_DOUT(3), A_DOUT(2) => A_DOUT(2),
        A_DOUT(1) => A_DOUT(1), A_DOUT(0) => A_DOUT(0),
        B_DOUT(17) => nc15, B_DOUT(16) => nc3, B_DOUT(15) => nc10,
        B_DOUT(14) => nc7, B_DOUT(13) => nc17, B_DOUT(12) => nc4,
        B_DOUT(11) => nc12, B_DOUT(10) => nc2, B_DOUT(9) => nc23,
        B_DOUT(8) => nc18, B_DOUT(7) => nc6, B_DOUT(6) => nc11,
        B_DOUT(5) => B_DOUT(5), B_DOUT(4) => B_DOUT(4), B_DOUT(3)
         => B_DOUT(3), B_DOUT(2) => B_DOUT(2), B_DOUT(1) =>
        B_DOUT(1), B_DOUT(0) => B_DOUT(0), BUSY => OPEN,
        A_ADDR_CLK => A_CLK, A_DOUT_CLK => A_CLK, A_ADDR_SRST_N
         => \VCC\, A_DOUT_SRST_N => \VCC\, A_ADDR_ARST_N => \VCC\,
        A_DOUT_ARST_N => \VCC\, A_ADDR_EN => \VCC\, A_DOUT_EN =>
        \VCC\, A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, A_ADDR(9)
         => \GND\, A_ADDR(8) => \GND\, A_ADDR(7) => \GND\,
        A_ADDR(6) => A_ADDR(3), A_ADDR(5) => A_ADDR(2), A_ADDR(4)
         => A_ADDR(1), A_ADDR(3) => A_ADDR(0), A_ADDR(2) => \GND\,
        A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, B_ADDR_CLK =>
        \VCC\, B_DOUT_CLK => \VCC\, B_ADDR_SRST_N => \VCC\,
        B_DOUT_SRST_N => \VCC\, B_ADDR_ARST_N => \VCC\,
        B_DOUT_ARST_N => \VCC\, B_ADDR_EN => \VCC\, B_DOUT_EN =>
        \VCC\, B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_ADDR(9)
         => \GND\, B_ADDR(8) => \GND\, B_ADDR(7) => \GND\,
        B_ADDR(6) => B_ADDR(3), B_ADDR(5) => B_ADDR(2), B_ADDR(4)
         => B_ADDR(1), B_ADDR(3) => B_ADDR(0), B_ADDR(2) => \GND\,
        B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, C_CLK => C_CLK,
        C_ADDR(9) => \GND\, C_ADDR(8) => \GND\, C_ADDR(7) =>
        \GND\, C_ADDR(6) => C_ADDR(3), C_ADDR(5) => C_ADDR(2),
        C_ADDR(4) => C_ADDR(1), C_ADDR(3) => C_ADDR(0), C_ADDR(2)
         => \GND\, C_ADDR(1) => \GND\, C_ADDR(0) => \GND\,
        C_DIN(17) => \GND\, C_DIN(16) => \GND\, C_DIN(15) =>
        \GND\, C_DIN(14) => \GND\, C_DIN(13) => \GND\, C_DIN(12)
         => \GND\, C_DIN(11) => \GND\, C_DIN(10) => \GND\,
        C_DIN(9) => \GND\, C_DIN(8) => \GND\, C_DIN(7) => \GND\,
        C_DIN(6) => \GND\, C_DIN(5) => C_DIN(5), C_DIN(4) =>
        C_DIN(4), C_DIN(3) => C_DIN(3), C_DIN(2) => C_DIN(2),
        C_DIN(1) => C_DIN(1), C_DIN(0) => C_DIN(0), C_WEN =>
        C_WEN, C_BLK(1) => \VCC\, C_BLK(0) => \VCC\, A_EN =>
        \VCC\, A_ADDR_LAT => \GND\, A_DOUT_LAT => \GND\,
        A_WIDTH(2) => \GND\, A_WIDTH(1) => \VCC\, A_WIDTH(0) =>
        \VCC\, B_EN => \VCC\, B_ADDR_LAT => \VCC\, B_DOUT_LAT =>
        \VCC\, B_WIDTH(2) => \GND\, B_WIDTH(1) => \VCC\,
        B_WIDTH(0) => \VCC\, C_EN => \VCC\, C_WIDTH(2) => \GND\,
        C_WIDTH(1) => \VCC\, C_WIDTH(0) => \VCC\, SII_LOCK =>
        \GND\);

    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);
end DEF_ARCH;



-- Version: v11.7 SP1 11.7.1.14
library ieee;
use ieee.std_logic_1164.all;
--library rtg4;
--use rtg4.all;

entity rtg4_lfsr_uram is
    port( A_DOUT : out   std_logic_vector(5 downto 0);
          B_DOUT : out   std_logic_vector(5 downto 0);
          C_DIN  : in    std_logic_vector(5 downto 0);
          A_ADDR : in    std_logic_vector(3 downto 0);
          B_ADDR : in    std_logic_vector(3 downto 0);
          C_ADDR : in    std_logic_vector(3 downto 0);
          A_CLK  : in    std_logic;
          C_CLK  : in    std_logic;
          C_WEN  : in    std_logic  );
end rtg4_lfsr_uram;

architecture DEF_ARCH of rtg4_lfsr_uram is
  component RAM64x18_RT
    generic (MEMORYFILE:string := "");
    port( BUSY            : out   std_logic;
          A_DB_DETECT     : out   std_logic;
          B_DB_DETECT     : out   std_logic;
          A_DOUT          : out   std_logic_vector(17 downto 0);
          B_DOUT          : out   std_logic_vector(17 downto 0);
          A_SB_CORRECT    : out   std_logic;
          B_SB_CORRECT    : out   std_logic;
          A_ADDR          : in    std_logic_vector(6 downto 0) := (others => 'U');
          B_ADDR          : in    std_logic_vector(6 downto 0) := (others => 'U');
          C_ADDR          : in    std_logic_vector(6 downto 0) := (others => 'U');
          A_BLK           : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_BLK           : in    std_logic_vector(1 downto 0) := (others => 'U');
          C_BLK           : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_CLK           : in    std_logic := 'U';
          B_CLK           : in    std_logic := 'U';
          C_CLK           : in    std_logic := 'U';
          C_DIN           : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR_EN       : in    std_logic := 'U';
          B_ADDR_EN       : in    std_logic := 'U';
          A_DOUT_EN       : in    std_logic := 'U';
          B_DOUT_EN       : in    std_logic := 'U';
          A_ADDR_SRST_N   : in    std_logic := 'U';
          B_ADDR_SRST_N   : in    std_logic := 'U';
          A_DOUT_SRST_N   : in    std_logic := 'U';
          B_DOUT_SRST_N   : in    std_logic := 'U';
          C_WEN           : in    std_logic := 'U';
          DELEN           : in    std_logic := 'U';
          SECURITY        : in    std_logic := 'U';
          ECC             : in    std_logic := 'U';
          ECC_DOUT_BYPASS : in    std_logic := 'U';
          A_WIDTH         : in    std_logic := 'U';
          B_WIDTH         : in    std_logic := 'U';
          C_WIDTH         : in    std_logic := 'U';
          A_DOUT_BYPASS   : in    std_logic := 'U';
          B_DOUT_BYPASS   : in    std_logic := 'U';
          A_ADDR_BYPASS   : in    std_logic := 'U';
          B_ADDR_BYPASS   : in    std_logic := 'U';
          ARST_N          : in    std_logic := 'U'  );
  end component;

  component GND
    port(Y : out std_logic);
  end component;

  component VCC
    port(Y : out std_logic);
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc24, nc1, nc8, nc13, nc16, nc19, nc20, nc9, nc22,
        nc14, nc5, nc21, nc15, nc3, nc10, nc7, nc17, nc4, nc12,
        nc2, nc23, nc18, nc6, nc11 : std_logic;

begin

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    rtg4_lfsr_uram_R0C0 : RAM64x18_RT
      port map(BUSY => OPEN, A_DB_DETECT => OPEN, B_DB_DETECT =>
        OPEN, A_DOUT(17) => nc24, A_DOUT(16) => nc1, A_DOUT(15)
         => nc8, A_DOUT(14) => nc13, A_DOUT(13) => nc16,
        A_DOUT(12) => nc19, A_DOUT(11) => nc20, A_DOUT(10) => nc9,
        A_DOUT(9) => nc22, A_DOUT(8) => nc14, A_DOUT(7) => nc5,
        A_DOUT(6) => nc21, A_DOUT(5) => A_DOUT(5), A_DOUT(4) =>
        A_DOUT(4), A_DOUT(3) => A_DOUT(3), A_DOUT(2) => A_DOUT(2),
        A_DOUT(1) => A_DOUT(1), A_DOUT(0) => A_DOUT(0),
        B_DOUT(17) => nc15, B_DOUT(16) => nc3, B_DOUT(15) => nc10,
        B_DOUT(14) => nc7, B_DOUT(13) => nc17, B_DOUT(12) => nc4,
        B_DOUT(11) => nc12, B_DOUT(10) => nc2, B_DOUT(9) => nc23,
        B_DOUT(8) => nc18, B_DOUT(7) => nc6, B_DOUT(6) => nc11,
        B_DOUT(5) => B_DOUT(5), B_DOUT(4) => B_DOUT(4), B_DOUT(3)
         => B_DOUT(3), B_DOUT(2) => B_DOUT(2), B_DOUT(1) =>
        B_DOUT(1), B_DOUT(0) => B_DOUT(0), A_SB_CORRECT => OPEN,
        B_SB_CORRECT => OPEN, A_ADDR(6) => \GND\, A_ADDR(5) =>
        \GND\, A_ADDR(4) => \GND\, A_ADDR(3) => A_ADDR(3),
        A_ADDR(2) => A_ADDR(2), A_ADDR(1) => A_ADDR(1), A_ADDR(0)
         => A_ADDR(0), B_ADDR(6) => \GND\, B_ADDR(5) => \GND\,
        B_ADDR(4) => \GND\, B_ADDR(3) => B_ADDR(3), B_ADDR(2) =>
        B_ADDR(2), B_ADDR(1) => B_ADDR(1), B_ADDR(0) => B_ADDR(0),
        C_ADDR(6) => \GND\, C_ADDR(5) => \GND\, C_ADDR(4) =>
        \GND\, C_ADDR(3) => C_ADDR(3), C_ADDR(2) => C_ADDR(2),
        C_ADDR(1) => C_ADDR(1), C_ADDR(0) => C_ADDR(0), A_BLK(1)
         => \VCC\, A_BLK(0) => \VCC\, B_BLK(1) => \VCC\, B_BLK(0)
         => \VCC\, C_BLK(1) => \VCC\, C_BLK(0) => \VCC\, A_CLK
         => A_CLK, B_CLK => \GND\, C_CLK => C_CLK, C_DIN(17) =>
        \GND\, C_DIN(16) => \GND\, C_DIN(15) => \GND\, C_DIN(14)
         => \GND\, C_DIN(13) => \GND\, C_DIN(12) => \GND\,
        C_DIN(11) => \GND\, C_DIN(10) => \GND\, C_DIN(9) => \GND\,
        C_DIN(8) => \GND\, C_DIN(7) => \GND\, C_DIN(6) => \GND\,
        C_DIN(5) => C_DIN(5), C_DIN(4) => C_DIN(4), C_DIN(3) =>
        C_DIN(3), C_DIN(2) => C_DIN(2), C_DIN(1) => C_DIN(1),
        C_DIN(0) => C_DIN(0), A_ADDR_EN => \VCC\, B_ADDR_EN =>
        \VCC\, A_DOUT_EN => \VCC\, B_DOUT_EN => \VCC\,
        A_ADDR_SRST_N => \VCC\, B_ADDR_SRST_N => \VCC\,
        A_DOUT_SRST_N => \VCC\, B_DOUT_SRST_N => \VCC\, C_WEN =>
        C_WEN, DELEN => \GND\, SECURITY => \GND\, ECC => \GND\,
        ECC_DOUT_BYPASS => \GND\, A_WIDTH => \GND\, B_WIDTH =>
        \GND\, C_WIDTH => \GND\, A_DOUT_BYPASS => \GND\,
        B_DOUT_BYPASS => \VCC\, A_ADDR_BYPASS => \GND\,
        B_ADDR_BYPASS => \VCC\, ARST_N => \VCC\);

    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);
end DEF_ARCH;



--                  _   _   _   _   _   _     _   _   _   _
--                 / \ / \ / \ / \ / \ / \   / \ / \ / \ / \
--                ( D | i | t | h | e | r ) ( E | n | d | s )
--                 \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/

