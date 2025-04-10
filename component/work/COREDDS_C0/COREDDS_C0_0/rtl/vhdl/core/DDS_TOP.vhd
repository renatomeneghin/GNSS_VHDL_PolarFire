--****************************************************************
--Microsemi Corporation Proprietary and Confidential
--Copyright 2016 Microsemi Corporation.  All rights reserved
--
--ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
--ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
--IN ADVANCE IN WRITING.
--
--Description: CoreDDS
--             Top level module
--
--Rev:
--v3.0 11/02/2016
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
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.std_logic_unsigned.all;
USE work.dds_rtl_pack.all;

ENTITY COREDDS_C0_COREDDS_C0_0_COREDDS IS
  GENERIC (
    PH_ACC_BITS             : INTEGER := 24;
    PH_INC_MODE             : INTEGER := 0;
    PH_INC                  : INTEGER := 1000000;
    SIN_ON                  : INTEGER := 1;
    COS_ON                  : INTEGER := 1;
    SIN_POLARITY            : INTEGER := 0;
    COS_POLARITY            : INTEGER := 0;
    FREQ_OFFSET_BITS        : INTEGER := 3;
    PH_OFFSET_MODE          : INTEGER := 0;
    PH_OFFSET_CONST         : INTEGER := 1;
    PH_OFFSET_BITS          : INTEGER := 3;
    PH_CORRECTION           : INTEGER := 0;
    QUANTIZER_BITS          : INTEGER := 8;
    OUTPUT_BITS             : INTEGER := 18;
    LATENCY                 : INTEGER := 3;
    URAM_MAXDEPTH           : INTEGER := 0;
    FPGA_FAMILY             : INTEGER := 26;
    DIE_SIZE                : INTEGER := 15;
    -- Use in Standalone only
    MAX_FULL_WAVE_LOGDEPTH  : INTEGER := 9    );
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
END ENTITY COREDDS_C0_COREDDS_C0_0_COREDDS;

ARCHITECTURE rtl OF COREDDS_C0_COREDDS_C0_0_COREDDS IS

  COMPONENT dds_LUT_initializer
    GENERIC ( RAM_LOGDEPTH    : INTEGER;
              SLOWCLK_DIV     : INTEGER;
              LOG_SLOWCLK_DIV : INTEGER );
    PORT (
      clk       : IN STD_LOGIC;
      nGrst     : IN STD_LOGIC;
      ext_rstn  : IN STD_LOGIC;
      ext_init  : IN STD_LOGIC;
      init_over : OUT STD_LOGIC;
      rstn      : OUT STD_LOGIC;
      slow_clk  : OUT STD_LOGIC;
      sico_wEn  : OUT STD_LOGIC;                                  
      sico_wA   : OUT STD_LOGIC_VECTOR(RAM_LOGDEPTH-1 DOWNTO 0);  
      lfsr_wEn  : OUT STD_LOGIC;                        
      lfsr_wA   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) );   
  END COMPONENT;
  
  COMPONENT COREDDS_C0_COREDDS_C0_0_sin_cos_lut
    GENERIC (
      QUANTIZER_BITS  : INTEGER;	
      WIDTH           : INTEGER;
      QUARTER_WAVE    : INTEGER;
      SIN_ON          : INTEGER;
      COS_ON          : INTEGER;
      SIN_POLARITY    : INTEGER;
      COS_POLARITY    : INTEGER;
      FPGA_FAMILY     : INTEGER;
      URAM_MAXDEPTH   : INTEGER;
      PIPE4           : INTEGER;
      PIPE4EXT        : INTEGER;
      PIPE5           : INTEGER;
      PIPE6           : INTEGER;
      PIPE7           : INTEGER;
      SIMUL_RAM       : INTEGER );
    PORT (    
      nGrst           : IN STD_LOGIC;
      wClk            : IN STD_LOGIC;
      rClk            : IN STD_LOGIC;
      wEn             : IN STD_LOGIC;
      wA              : IN STD_LOGIC_VECTOR(intMux(QUANTIZER_BITS, QUANTIZER_BITS-3, QUARTER_WAVE=1)-1 DOWNTO 0);
      full_wave_addr  : IN STD_LOGIC_VECTOR(QUANTIZER_BITS-1 DOWNTO 0);
      sino            : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      coso            : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)  );
  END COMPONENT COREDDS_C0_COREDDS_C0_0_sin_cos_lut;
  
  COMPONENT dds_quantizer IS
    GENERIC (
      PH_ACC_BITS             : INTEGER;
      PH_INC_MODE             : INTEGER;
      PH_INC                  : INTEGER;
      QUANTIZER_BITS          : INTEGER;
      FREQ_OFFSET_BITS        : INTEGER;
      PH_OFFSET_MODE          : INTEGER;
      PH_OFFSET_CONST         : INTEGER;
      PH_OFFSET_BITS          : INTEGER;
      PH_CORRECTION           : INTEGER;
      PIPE1                   : INTEGER;
      PIPE2                   : INTEGER;
      PIPE3                   : INTEGER;
      -- LFSR LUT initialization params
      FPGA_FAMILY             : INTEGER;
      SIMUL_RAM               : INTEGER );
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
  END COMPONENT dds_quantizer;
  
  COMPONENT trig_cor IS
    GENERIC (
      PH_ACC_BITS             : INTEGER;
      QUANTIZER_BITS          : INTEGER;
      LATENCY                 : INTEGER;
      FPGA_FAMILY             : INTEGER;
      SIN_ON                  : INTEGER;
      COS_ON                  : INTEGER;
      SIN_POLARITY            : INTEGER;
      COS_POLARITY            : INTEGER;
      OUTPUT_BITS             : INTEGER;
      PIPE4EXT                : INTEGER;
      PIPE6                   : INTEGER;
      PIPE7                   : INTEGER;
      PIPE8                   : INTEGER;
      PIPE9                   : INTEGER;
      PIPE10                  : INTEGER;
      PIPE11                  : INTEGER );
    PORT (
      clk                     : IN STD_LOGIC;
      rstn                    : IN STD_LOGIC;
      nGrst                   : IN STD_LOGIC;
      ph_accum_in             : IN STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
      sinA                    : IN STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
      cosA                    : IN STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
      sin_o                   : OUT STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
      cos_o                   : OUT STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0)  );
  END COMPONENT trig_cor;

  constant SIMUL_RAM : INTEGER := 0;
  constant QUARTER_WAVE : INTEGER := intMux(0, 1, QUANTIZER_BITS>MAX_FULL_WAVE_LOGDEPTH); 
  constant RAM_LOGDEPTH : INTEGER := intMux(QUANTIZER_BITS-3, QUANTIZER_BITS, QUARTER_WAVE=0);
                                    
  -- Trigonometric correction takes both sin and cos of the quantized angle to
  -- calculate the correction. Thus must build both LUT's if PH_CORRECTION==2
  constant SIN_ONI  : INTEGER := intMux(SIN_ON, 1, PH_CORRECTION=2);
  constant COS_ONI  : INTEGER := intMux(COS_ON, 1, PH_CORRECTION=2);
                                    
  -- Calculate pipe values        
  constant PIPE1  : INTEGER := intMux(0, 1, LATENCY>1);
  constant PIPE2  : INTEGER := intMux(0, 1, ((PH_OFFSET_MODE/=0) OR (PH_CORRECTION=1)) AND (LATENCY>1) );
  constant PIPE3  : INTEGER := intMux(0, 1, (PH_CORRECTION=0) AND (QUANTIZER_BITS<PH_ACC_BITS) AND (LATENCY>1) );   --01/16/17
  -- PIPE 4                       
  -- LSRAM always have the rA pipe on - it cannot be turned off. To follow this
  -- behavior on uRAM, where rA pipe is optional, we'll keep PIPE4 always on
  constant PIPE4  : INTEGER := 1;
  constant PIPE4EXT : INTEGER := intMux(0, 1, LATENCY>1);
  constant PIPE5  : INTEGER := intMux(0, 1, LATENCY>0);
  constant PIPE6  : INTEGER := intMux(0, 1, LATENCY>2);
  constant PIPE7  : INTEGER := intMux(0, 1, (QUARTER_WAVE>0) AND (LATENCY>1));
  -- Trigonometric Correction pipes
  constant PIPE8  : INTEGER := intMux(0, 1, (PH_CORRECTION=2) AND (PIPE4=1) );
  constant PIPE9  : INTEGER := intMux(0, 1, (PH_CORRECTION=2) AND (PIPE5=1) );
  constant PIPE10 : INTEGER := intMux(0, 1, (PH_CORRECTION=2) AND (LATENCY>2) );
  constant PIPE11 : INTEGER := intMux(0, 1, (PH_CORRECTION=2) AND (LATENCY>1) );
  constant PIPE_PH_INC : INTEGER := PIPE2+PIPE3+PIPE4+PIPE5+PIPE6+PIPE7+PIPE10+PIPE11;
  constant PIPE_PH_OFFS: INTEGER := PIPE_PH_INC+PIPE1;
  
  constant SLOWCLK_DIV      : INTEGER := 4;
  constant LOG_SLOWCLK_DIV  : INTEGER := 2;  

  SIGNAL rstni, rstn_full_wave_addr        : STD_LOGIC;
  SIGNAL slow_clk       : STD_LOGIC;
  SIGNAL lfsr_wEn       : STD_LOGIC;
  SIGNAL sico_wEn       : STD_LOGIC;
  SIGNAL lfsr_wA        : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL lfsr_rA        : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL lfsr_Q         : STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL full_wave_addr : STD_LOGIC_VECTOR(QUANTIZER_BITS-1 DOWNTO 0);
  SIGNAL sico_wA        : STD_LOGIC_VECTOR(RAM_LOGDEPTH-1 DOWNTO 0);
  SIGNAL sino           : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL coso           : STD_LOGIC_VECTOR(OUTPUT_BITS-1 DOWNTO 0);
  SIGNAL ph_acc_s       : STD_LOGIC_VECTOR(PH_ACC_BITS-1 DOWNTO 0);
  SIGNAL init_overi     : STD_LOGIC;
  
BEGIN
  INIT_OVER <= init_overi;
  --                      +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+
  --                      |I|n|i|t|i|a|l|i|z|e| |L|U|T|s|
  --                      +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+
  dds_initializer_0 : dds_LUT_initializer
    GENERIC MAP ( RAM_LOGDEPTH  => RAM_LOGDEPTH,
        SLOWCLK_DIV     =>  SLOWCLK_DIV,
        LOG_SLOWCLK_DIV =>  LOG_SLOWCLK_DIV   )
    PORT MAP (
      clk        => CLK,
      nGrst      => NGRST,
      ext_rstn   => RSTN,
      ext_init   => INIT,
      init_over  => init_overi,
      -- Output rstni gets generated on nGrst as well as, on ext_rstn
      rstn       => rstni,
      slow_clk   => slow_clk,
      sico_wEn   => sico_wEn,
      sico_wA    => sico_wA,
      lfsr_wEn   => lfsr_wEn,
      lfsr_wA    => lfsr_wA  );
  
  -- Sin and Cos LUT's
  sin_cos_lut_0 : COREDDS_C0_COREDDS_C0_0_sin_cos_lut
    GENERIC MAP (
      QUANTIZER_BITS  => QUANTIZER_BITS,
      WIDTH           => OUTPUT_BITS,
      QUARTER_WAVE    => QUARTER_WAVE,
      SIN_ON          => SIN_ONI,
      COS_ON          => COS_ONI,
      SIN_POLARITY    => SIN_POLARITY,
      COS_POLARITY    => COS_POLARITY,
      FPGA_FAMILY     => FPGA_FAMILY,
      URAM_MAXDEPTH   => URAM_MAXDEPTH,
      PIPE4           => PIPE4,
      PIPE4EXT        => PIPE4EXT,
      PIPE5           => PIPE5,
      PIPE6           => PIPE6,
      PIPE7           => PIPE7,
      SIMUL_RAM       => SIMUL_RAM  )
    PORT MAP (
      nGrst           => NGRST,
      rClk            => CLK,
      wClk            => slow_clk,
      wEn             => sico_wEn,
      wA              => sico_wA,
      full_wave_addr  => full_wave_addr,
      sino            => sino,
      coso            => coso  );

  no_trig_corr : IF ((PH_CORRECTION/=2) OR (PH_ACC_BITS<=QUANTIZER_BITS)) GENERATE
    SINE <= sino;
    COSINE <= coso;
  END GENERATE;

  -- To start from 0 phase, reset the rA (full_wave_addr) by the INIT_OVER
  rstn_full_wave_addr <= rstni AND (NOT(init_overi));
  
  quantizer_0 : dds_quantizer
    GENERIC MAP (
      PH_ACC_BITS       => PH_ACC_BITS,
      PH_INC_MODE       => PH_INC_MODE,
      PH_INC            => PH_INC,
      QUANTIZER_BITS    => QUANTIZER_BITS,
      FREQ_OFFSET_BITS  => FREQ_OFFSET_BITS,
      PH_OFFSET_MODE    => PH_OFFSET_MODE,
      PH_OFFSET_CONST   => PH_OFFSET_CONST,
      PH_OFFSET_BITS    => PH_OFFSET_BITS,
      PH_CORRECTION     => PH_CORRECTION,
      PIPE1             => PIPE1,
      PIPE2             => PIPE2,
      PIPE3             => PIPE3,
      FPGA_FAMILY       => FPGA_FAMILY,
      SIMUL_RAM         => SIMUL_RAM  )
    PORT MAP (
      clk              => CLK,
      rstn             => rstn_full_wave_addr,
      nGrst            => NGRST,
      ext_freq_offset  => FREQ_OFFSET,
      freq_offset_we   => FREQ_OFFSET_WE,
      ext_ph_offset    => PH_OFFSET,
      ph_offset_we     => PH_OFFSET_WE,
      dith_init        => lfsr_wEn,
      ph_acc_s         => ph_acc_s,
      full_wave_addr   => full_wave_addr,
      -- LFSR LUT initialization ports
      slow_clk         => slow_clk,
      lfsr_wEn         => lfsr_wEn,
      lfsr_wA          => lfsr_wA  );
  
  -- No Trigonom correction if QUANTIZER_BITS = PH_ACC_BITS
  trgonom_corr : IF ((PH_CORRECTION = 2) AND (PH_ACC_BITS > QUANTIZER_BITS)) GENERATE
    trigonom_corr_0 : trig_cor
      GENERIC MAP (
        PH_ACC_BITS     => PH_ACC_BITS,
        QUANTIZER_BITS  => QUANTIZER_BITS,
        LATENCY         => LATENCY,
        FPGA_FAMILY     => FPGA_FAMILY,
        SIN_ON          => SIN_ON,
        COS_ON          => COS_ON,
        SIN_POLARITY    => SIN_POLARITY,
        COS_POLARITY    => COS_POLARITY,
        OUTPUT_BITS     => OUTPUT_BITS,
        PIPE4EXT        => PIPE4EXT,
        PIPE6           => PIPE6,
        PIPE7           => PIPE7,
        PIPE8           => PIPE8,
        PIPE9           => PIPE9,
        PIPE10          => PIPE10,
        PIPE11          => PIPE11   )
      PORT MAP (
        clk          => CLK,
        rstn         => RSTN,
        ngrst        => NGRST,
        ph_accum_in  => ph_acc_s,
        sina         => sino,
        cosa         => coso,
        sin_o        => SINE,
        cos_o        => COSINE  );
  END GENERATE;
  
END ARCHITECTURE rtl;




