package kollectra.blackboxes
import spinal.core._

class W9825G6KH6ControllerBlackBox extends BlackBox {
  val io = new Bundle {
    val clk         = in Bool()
    val power       = in Bool()
    val resetn      = in Bool()

    val cmd = new Bundle {
      val valid   = in Bool()
      val ready   = out Bool()
      val addr    = in UInt(26 bits)
      val we      = in Bool()
      val wstrb   = in UInt(2 bits)
    }

    val wdata_valid = in Bool()
    val wdata_ready = out Bool()
    val wdata 		= in UInt(16 bits)

	val rdata_valid = out Bool()
	val rdata_ready = in Bool()
	val rdata = out UInt(16 bits)

    val sdram = new Bundle {
      val clk  = out Bool()
      val cke  = out Bool()
      val csn  = out Bool()
      val rasn = out Bool()
      val casn = out Bool()
      val wen  = out Bool()
      val a    = out UInt(13 bits)
      val ba   = out UInt(2 bits)
      val dqm  = out UInt(2 bits)
      val d    = inout(Analog(Bits(16 bits)))
    }
  }

  addRTLPath("./rtl/w9825g6kh_6_controller.v")
  setDefinitionName("w9825g6kh_6_controller")
  noIoPrefix()

}

