package kollectra
import spinal.core._

class SdramModelBB extends BlackBox {
  setDefinitionName("mt48lc16m16a2")
  addRTLPath("tests/w9825g6kh_6/rw/sim/mt48lc16m16a2.v")
  noIoPrefix()

  val Dq    = inout(Analog(Bits(16 bits)))
  val Addr  = in Bits(13 bits)
  val Ba    = in Bits(2 bits)
  val Clk   = in Bool()
  val Cke   = in Bool()
  val Cs_n  = in Bool()
  val Ras_n = in Bool()
  val Cas_n = in Bool()
  val We_n  = in Bool()
  val Dqm   = in Bits(2 bits)
}

