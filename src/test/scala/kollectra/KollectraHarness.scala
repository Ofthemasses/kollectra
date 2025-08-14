package kollectra
import spinal.core._

class KollectraHarness extends Component {
  val io = new Bundle {
    val clk165    = in Bool()
    val power     = in Bool()
    val resetn    = in Bool()
  }

  val dut   = new Kollectra
  val dram  = new SdramModelBB

  dut.io.clk    := io.clk165
  dut.io.power  := io.power
  dut.io.resetn := io.resetn
  dut.io.timerInterrupt    := False
  dut.io.externalInterrupt := False

  dram.Clk   := dut.io.sdram.clk
  dram.Cke   := dut.io.sdram.cke
  dram.Cs_n  := dut.io.sdram.csn
  dram.Ras_n := dut.io.sdram.rasn
  dram.Cas_n := dut.io.sdram.casn
  dram.We_n  := dut.io.sdram.wen
  dram.Addr  := dut.io.sdram.a.asBits
  dram.Ba    := dut.io.sdram.ba.asBits
  dram.Dqm   := dut.io.sdram.dqm.asBits

  dram.Dq <> dut.io.sdram.d
}
