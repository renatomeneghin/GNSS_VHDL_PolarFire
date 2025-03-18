-- ***************************************************************************/
--Microsemi Corporation Proprietary and Confidential
--Copyright 2016 Microsemi Corporation. All rights reserved.
--
--ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
--ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
--IN ADVANCE IN WRITING.
--
--Description:  CoreDDS RTL
--              RTL Package
--
--Revision Information:
--Date         Description
--28Oct2016    Initial Release
--
--SVN Revision Information:
--SVN $Revision: $
--SVN $Data: $
--
--Resolved SARs
--SAR     Date    Who         Description
--
--Notes:
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE std.textio.all;
USE IEEE.NUMERIC_STD.all;

PACKAGE dds_rtl_pack IS

  FUNCTION to_logic   ( x : integer) return std_logic;
  FUNCTION to_logic   ( x : boolean) return std_logic;
  FUNCTION to_integer ( sig : std_logic_vector) return integer;
  function to_integer ( x : boolean) return integer;
  FUNCTION to_signInteger ( din : std_logic_vector ) return integer;
  FUNCTION reductionAnd (x: std_logic_vector) RETURN std_logic;
  FUNCTION reductionOr (x: std_logic_vector) RETURN std_logic;
  FUNCTION reductionXor (x: std_logic_vector) RETURN std_logic;

  FUNCTION kit_resize (a:IN signed; len: IN integer) RETURN signed;
  FUNCTION kit_resize (a:IN unsigned; len: IN integer) RETURN unsigned;

  -- convert std_logic to std_logic_vector and back
  FUNCTION vectorize (s: std_logic)        return std_logic_vector;
  FUNCTION vectorize (v: std_logic_vector) return std_logic_vector;
  FUNCTION scalarize (v: in std_logic_vector) return std_logic;

  -- Shift Left Logical: leftShiftL(bbbbb, 2) = bbb00;
  FUNCTION leftShiftL (arg: STD_LOGIC_VECTOR; count: NATURAL)
                                                        RETURN STD_LOGIC_VECTOR;
  -- Shift Right Logical: rightShiftL(bbbbb, 2) = 00bbb;
  FUNCTION rightShiftL (ARG: STD_LOGIC_VECTOR; COUNT: NATURAL)
                                                        RETURN STD_LOGIC_VECTOR;
  -- Shift Right Arithmetic: rightShiftA(sbbbb, 2) = sssbb;
  FUNCTION rightShiftA (ARG: STD_LOGIC_VECTOR; COUNT: NATURAL)
                                                        RETURN STD_LOGIC_VECTOR;
  FUNCTION bit_reverse( sig : std_logic_vector; WIDTH : INTEGER)
                                                        RETURN STD_LOGIC_VECTOR;
  function ceil_log2 (N : positive) return natural;
  function ceil_log3 (N : positive) return natural;
  function antilog2 (k : natural) return positive;
  function intMux (a, b : integer; sel : boolean ) return integer;
  function intMux3 (a, b, c : integer; sel : integer ) return integer;

  function sign_ext (inp: std_logic_vector; OUTWIDTH, UNSIGN: natural)
            return std_logic_vector;
  FUNCTION trigon_const (RC_const : integer ) RETURN std_logic_vector;   
  FUNCTION sub_const (COM_POLARITY : integer ) RETURN std_logic_vector;       
  FUNCTION binary_to_one_hot (binary : STD_LOGIC_VECTOR; binary_size : NATURAL;
                              enable : STD_LOGIC) RETURN STD_LOGIC_VECTOR;

--------------------------------------------------------------------------------

  COMPONENT dds_kitDelay_bit_reg
    GENERIC (DELAY  : INTEGER);
    PORT (nGrst, rst, clk, clkEn, inp : IN STD_LOGIC;
      outp                            : OUT STD_LOGIC  );
  END COMPONENT;

  COMPONENT dds_kitDelay_reg
    GENERIC ( BITWIDTH      : INTEGER;
              DELAY         : INTEGER  );
    PORT (nGrst, rst, clk, clkEn : in std_logic;
          inp : in std_logic_vector(BITWIDTH-1 DOWNTO 0);
          outp: out std_logic_vector(BITWIDTH-1 DOWNTO 0) );
  END COMPONENT;

  COMPONENT dds_kitCountS
    GENERIC ( WIDTH         : INTEGER := 16;
              DCVALUE       : INTEGER := 1;		-- state to decode
              BUILD_DC      : INTEGER := 1  );
    PORT (nGrst, rst, clk, clkEn, cntEn : IN STD_LOGIC;
      Q             : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      dc            : OUT STD_LOGIC   );		-- decoder output
  END COMPONENT;

  COMPONENT dds_kitDelay_reg_attr
    GENERIC(
      BITWIDTH : integer;
      DELAY:     integer  );
    PORT (nGrst, rst, clk, clkEn : in std_logic;
        inp : in std_logic_vector(BITWIDTH-1 DOWNTO 0);
        outp: out std_logic_vector(BITWIDTH-1 DOWNTO 0) );
  END COMPONENT;

  COMPONENT dds_signExt
    GENERIC (
      INWIDTH   : INTEGER := 16;
      OUTWIDTH  : INTEGER := 20;
      UNSIGN    : INTEGER := 0;     -- 0-signed conversion; 1-unsigned
      DROP_MSB  : INTEGER := 0  );
    PORT (
      inp             : IN STD_LOGIC_VECTOR(INWIDTH-1 DOWNTO 0);
      outp            : OUT STD_LOGIC_VECTOR(OUTWIDTH-1 DOWNTO 0)  );
  END COMPONENT;

  COMPONENT dds_kitRAM_fabric
    GENERIC (
      WIDTH     : INTEGER := 16;
      LOGDEPTH  : INTEGER := 8;
      DEPTH     : INTEGER := 1256;
      RA_PIPE   : INTEGER := 1;
      RD_PIPE   : INTEGER := 1   );
    PORT (
      nGrst           : IN STD_LOGIC;   -- nGrst for simulation only to init RAM
      RCLOCK          : IN STD_LOGIC;
      WCLOCK          : IN STD_LOGIC;
      WRB             : IN STD_LOGIC;
      RDB             : IN STD_LOGIC;
      rstDataPipe     : IN STD_LOGIC;
      DI              : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      RADDR           : IN STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
      WADDR           : IN STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
      DO              : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)  );
  END COMPONENT;
                  
  COMPONENT dds_kitSyncNgrst                                    
    GENERIC ( PULSE_WIDTH   : INTEGER := 1  );                    
    PORT (  nGrst, clk  : IN STD_LOGIC;                           
            pulse       : OUT STD_LOGIC;                          
            ext_rstn    : IN STD_LOGIC;                           
            rstn        : OUT STD_LOGIC );                        
  END COMPONENT;                                    
                  
END dds_rtl_pack;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

PACKAGE BODY dds_rtl_pack IS

  FUNCTION to_logic ( x : integer) return std_logic is
  variable y  : std_logic;
  begin
    if x = 0 then
      y := '0';
    else
      y := '1';
    end if;
    return y;
  end to_logic;


  FUNCTION to_logic( x : boolean) return std_logic is
    variable y : std_logic;
  begin
    if x then
      y := '1';
    else
      y := '0';
    end if;
    return(y);
  end to_logic;


  FUNCTION to_integer(sig : std_logic_vector) return integer is
    variable num : integer := 0;  -- descending sig as integer
  begin
    for i in sig'range loop
      if sig(i)='1' then
        num := num*2+1;
      else  -- take anything other than '1' as '0'
        num := num*2;
      end if;
    end loop;  -- i
    return num;
  end function to_integer;


  FUNCTION to_signInteger ( din : std_logic_vector ) return integer is
  begin
    return to_integer(signed(din));
  end to_signInteger;


  FUNCTION to_integer( x : boolean) return integer is
    variable y : integer;
  BEGIN
    if x then
      y := 1;
    else
      y := 0;
    end if;
    return(y);
  END to_integer;


  FUNCTION reductionAnd (x: std_logic_vector) RETURN std_logic IS
    VARIABLE r: std_logic := '1';
    BEGIN
      FOR i IN x'range LOOP
        r := r AND x(i);
      END LOOP;
      RETURN r;
  END FUNCTION reductionAnd;


  FUNCTION reductionOr (x: std_logic_vector) RETURN std_logic IS
    VARIABLE r: std_logic := '0';
    BEGIN
      FOR i IN x'range LOOP
        r := r OR x(i);
      END LOOP;
      RETURN r;
  END FUNCTION reductionOr;


  FUNCTION reductionXor (x: std_logic_vector) RETURN std_logic IS
    VARIABLE r: std_logic := '0';
    BEGIN
      FOR i IN x'range LOOP
        r := r XOR x(i);
      END LOOP;
      RETURN r;
  END FUNCTION reductionXor;


  -- Result: Resizes the SIGNED vector IN to the specified size.
  --         To create a larger vector, the new [leftmost] bit positions
  --         are filled with the sign bit.
  --         When truncating, the sign bit is retained along with the MSB's
  FUNCTION kit_resize(a:IN signed; len: IN integer) RETURN signed IS
  BEGIN
    IF a'length > len then
       RETURN a(len-1+a'right DOWNTO a'right);
    ELSE
      RETURN Resize(a,len);
    END IF;
  END kit_resize;


  -- Result: Resizes the UNSIGNED vector IN to the specified size.
  --         To create a larger vector, the new [leftmost] bit positions
  --         are filled with '0'. When truncating, the leftmost bits
  --         are dropped (!)
  FUNCTION kit_resize(a:IN unsigned; len: IN integer) RETURN unsigned IS
  BEGIN
    RETURN Resize(a,len);
  END kit_resize;


  -- Convert std_logic to std_logic_vector(0 downto 0) and back
  FUNCTION vectorize(s: std_logic) return std_logic_vector is
    variable v: std_logic_vector(0 downto 0);
  BEGIN
    v(0) := s;
    return v;
  END;


  FUNCTION vectorize(v: std_logic_vector) return std_logic_vector is
  BEGIN
    return v;
  END;


  -- scalarize returns an LSB
  FUNCTION scalarize(v: in std_logic_vector) return std_logic is
  BEGIN
    --assert v'length = 1
    --report "scalarize: output port must be single bit!"
    --severity FAILURE;
    return v(v'LEFT);
  END;


  -- Shift Left Logical: leftShiftL(bbbbb, 2) = bbb00;
  FUNCTION leftShiftL (arg: STD_LOGIC_VECTOR; count: NATURAL)
                                                      return STD_LOGIC_VECTOR is
    constant ARG_L: INTEGER := ARG'LENGTH-1;
    alias XARG: STD_LOGIC_VECTOR(ARG_L downto 0) is ARG;
    variable RESULT: STD_LOGIC_VECTOR(ARG_L downto 0) := (others => '0');
  BEGIN
    if COUNT <= ARG_L then
      RESULT(ARG_L downto COUNT) := XARG(ARG_L-COUNT downto 0);
    end if;
    return RESULT;
  END leftShiftL;


-- Shift Right Logical: rightShiftL(bbbbb, 2) = 00bbb;
  FUNCTION rightShiftL (ARG: STD_LOGIC_VECTOR; COUNT: NATURAL)
                                                      return STD_LOGIC_VECTOR is
    constant ARG_L: INTEGER := ARG'LENGTH-1;
    alias XARG: STD_LOGIC_VECTOR(ARG_L downto 0) is ARG;
    variable RESULT: STD_LOGIC_VECTOR(ARG_L downto 0) := (others => '0');
  begin
    if COUNT <= ARG_L then
      RESULT(ARG_L-COUNT downto 0) := XARG(ARG_L downto COUNT);
    end if;
    return RESULT;
  end rightShiftL;


-- Shift Right Arithmetic: rightShiftA(sbbbb, 2) = sssbb;
  function rightShiftA (ARG: STD_LOGIC_VECTOR; COUNT: NATURAL)
                                                      return STD_LOGIC_VECTOR is
    constant ARG_L: INTEGER := ARG'LENGTH-1;
    alias XARG: STD_LOGIC_VECTOR(ARG_L downto 0) is ARG;
    variable RESULT: STD_LOGIC_VECTOR(ARG_L downto 0);
    variable XCOUNT: NATURAL := COUNT;
  begin
    if ((ARG'LENGTH <= 1) or (XCOUNT = 0)) then return ARG;
    else
      if (XCOUNT > ARG_L) then XCOUNT := ARG_L;
      end if;
      RESULT(ARG_L-XCOUNT downto 0) := XARG(ARG_L downto XCOUNT);
      RESULT(ARG_L downto (ARG_L - XCOUNT + 1)) := (others => XARG(ARG_L));
    end if;
    return RESULT;
  end rightShiftA;


--  FUNCTION shftRA (x    :IN std_logic_vector(WORDSIZE-1 DOWNTO 0);
--                   shft :IN integer)
--                   RETURN std_logic_vector IS
--  VARIABLE x1 : bit_vector(WORDSIZE-1 DOWNTO 0);
--  BEGIN
--    x1 := To_bitvector(x) SRA shft;
--    RETURN(To_StdLogicVector(x1) );
--  END FUNCTION shftRA;


-- Reverse bits
  FUNCTION bit_reverse( sig : std_logic_vector; WIDTH : INTEGER) return STD_LOGIC_VECTOR is
    variable reverse : std_logic_vector(WIDTH-1 DOWNTO 0);
  BEGIN
    FOR i IN 0 TO WIDTH-1 LOOP
      reverse(i) := sig(WIDTH-1-i);
    END LOOP;
    return reverse;
  end function bit_reverse;


-- Log2
--04/19/17  function ceil_log2 (N : positive) return natural is
--04/19/17    variable tmp, res : integer;
--04/19/17  begin
--04/19/17    tmp:=1 ;
--04/19/17    res:=0;
--04/19/17    WHILE tmp < N LOOP
--04/19/17      tmp := tmp*2;
--04/19/17      res := res+1;
--04/19/17    END LOOP;
--04/19/17    return res;
--04/19/17  end ceil_log2;

  function ceil_log2 (N : positive) return natural is
    variable tmp, res : integer;
  begin
    IF (N < 2**30) THEN
      tmp:=1 ;
      res:=0;
      WHILE tmp < N LOOP
        tmp := tmp*2;
        res := res+1;
      END LOOP;
    ELSE
      res := 31;
    END IF;    
    return res;
  end ceil_log2;

  function antilog2 (k : natural) return positive is
    variable tmp, res : integer;
  begin
    tmp:=0 ;
    res:=1;
    WHILE tmp < k LOOP
      res := res*2;
      tmp := tmp+1;
    END LOOP;
    return res;
  end antilog2;

-- Log3
  function ceil_log3 (N : positive) return natural is
    variable tmp, res : integer;
  begin
    tmp:=1 ;
    res:=0;
    WHILE tmp < N LOOP
      tmp := tmp*3;
      res := res+1;
    END LOOP;
    return res;
  end ceil_log3;

-- Integer Mux: mimics a Verilog constant function sel ? b : a;
  function intMux (a, b : integer; sel : boolean ) return integer is
    variable tmp: integer;
  begin
    IF (sel=False) THEN tmp := a;
    ELSE tmp := b;
    END IF;
    return tmp;
  end intMux;

  function intMux3 (a, b, c : integer; sel : integer ) return integer is
    variable tmp: integer;
  begin
    IF    (sel=2) THEN tmp := c;
    ELSIF (sel=1) THEN tmp := b;
    ELSE               tmp := a;
    END IF;
    return tmp;
  end intMux3;

  -- Result: Resizes the vector inp to the specified size.
  -- To create a larger vector, the new [leftmost] bit positions are filled
  -- with the sign bit (if UNSIGNED==0) or 0's (if UNSIGNED==1).
  -- When truncating, the sign bit is retained along with the rightmost part
  -- (if UNSIGNED==0), or the leftmost bits are all dropped (if UNSIGNED==1)
  FUNCTION sign_ext (inp: std_logic_vector; OUTWIDTH, UNSIGN: natural)
            return std_logic_vector IS
    constant INWIDTH: INTEGER := inp'LENGTH;
    variable outp_s : signed  (OUTWIDTH-1 downto 0);
    variable outp_u : unsigned(OUTWIDTH-1 downto 0);
    variable res: STD_LOGIC_VECTOR(OUTWIDTH-1 downto 0);
  begin
    outp_s := RESIZE (signed(inp), OUTWIDTH);
    outp_u := RESIZE (unsigned(inp), OUTWIDTH);
    if UNSIGN=0 then res := std_logic_vector(outp_s);
    else             res := std_logic_vector(outp_u);
    end if;
    return res;
  END FUNCTION;

----------------------------------------------

  FUNCTION trigon_const (RC_const : integer ) RETURN std_logic_vector IS
    variable tmp: std_logic_vector(17 downto 0);
  BEGIN
    WITH RC_const SELECT
      tmp := "000000000110010010"       WHEN  6,    --X"00192"
             "000000001100100100"       WHEN  7,    --X"00324"
             "000000011001001000"       WHEN  8,    --X"00648"
             "000000110010010001"       WHEN  9,    --X"00C91"
             "000001100100100010"       WHEN  10,   --X"01922"
             "000011001001000100"       WHEN  11,   --X"03244"
             "000110010010001000"       WHEN  12,   --X"06488"
             "001100100100010000"       WHEN  13,   --X"0C910"
             "011001001000100000"       WHEN  14,   --X"19220"
             (OTHERS=>'0')  WHEN OTHERS;
    return tmp;
  end function;

-----------------------------------------------
  FUNCTION sub_const (COM_POLARITY : integer ) RETURN std_logic_vector IS
    variable tmp: std_logic_vector(1 downto 0);
  BEGIN
    WITH COM_POLARITY SELECT
      tmp := "10"       WHEN  10,
             "11"       WHEN  11,
             "11"       WHEN  12,
             "10"       WHEN  13,
             "10"       WHEN  100,
             "00"       WHEN  101,
             "00"       WHEN  102,
             "10"       WHEN  103,
             "10"       WHEN  110,
             "01"       WHEN  111,
             "01"       WHEN  112,
             "10"       WHEN  113,
             (OTHERS=>'0')  WHEN OTHERS;
    return tmp;
  end function;



  FUNCTION binary_to_one_hot (
      binary      : STD_LOGIC_VECTOR ;
      binary_size : NATURAL;
      enable      : STD_LOGIC  )
    RETURN STD_LOGIC_VECTOR is
      VARIABLE indx : INTEGER := to_integer(unsigned(binary));
      VARIABLE One_Hot_Var : STD_LOGIC_VECTOR(2**binary_size-1 downto 0);
    BEGIN
      One_Hot_Var := (others => '0');
      One_Hot_Var(indx) := enable;
      RETURN One_Hot_Var;
  END FUNCTION;

END dds_rtl_pack;
