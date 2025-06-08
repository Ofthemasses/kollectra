package kollectra.blackboxes
import spinal.core._

class W9825G6KH6ControllerBlackBox extends BlackBox {
  val io = new Bundle {
    val clk         = in Bool()
    val power       = in Bool()
    val resetn      = in Bool()

	val cmd_valid   = in Bool()
	val cmd_ready   = out Bool()
	val cmd_addr    = in UInt(26 bits)
	val cmd_we     	= in Bool()
	val cmd_wstrb   = in UInt(2 bits)

	val wdata_valid = in Bool()
	val wdata_ready = out Bool()
	val wdata 		= in UInt(16 bits)

	val rdata_valid = out Bool()
	val rdata_ready = in Bool()
	val rdata = out UInt(16 bits)

    val sdram_clk  = out Bool()
    val sdram_cke  = out Bool()
    val sdram_csn  = out Bool()
    val sdram_rasn = out Bool()
    val sdram_casn = out Bool()
    val sdram_wen  = out Bool()
    val sdram_a    = out UInt(13 bits)
    val sdram_ba   = out UInt(2 bits)
    val sdram_dqm  = out UInt(2 bits)
    val sdram_d    = inout(Analog(Bits(16 bits)))
  }

  addRTLPath("./rtl/w9825g6kh_6_controller.v")
  setDefinitionName("w9825g6kh_6_controller")
  noIoPrefix()

}

