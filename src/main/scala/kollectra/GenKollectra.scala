package kollectra

import spinal.core._
import kollectra.cores._
import kollectra.interfaces._
import spinal.lib._
import spinal.lib.bus.amba4.axi._

class Kollectra extends Component {
  val io = new Bundle {
    val clk        = in Bool()
    val power      = in Bool()
    val resetn     = in Bool()
    val timerInterrupt = in Bool()
    val externalInterrupt = in Bool()
  }

  val core = new KollectraCore

  val sdramBridge = new W9825G6KH6AxiBridge

  val axiCrossbar = Axi4CrossbarFactory()
  axiCrossbar.addSlaves(
    sdramBridge.io.axi -> (0x00000000L, 32 MiB)
  )

  axiCrossbar.addConnections(
    core.io.dBus -> List(sdramBridge.io.axi),
    core.io.iBus -> List(sdramBridge.io.axi)
  )

  axiCrossbar.build()

  io.clk <> sdramBridge.io.clk
  io.power <> sdramBridge.io.power
  io.resetn <> sdramBridge.io.resetn
  io.timerInterrupt <> core.io.timerInterrupt
  io.externalInterrupt <> core.io.externalInterrupt
}

object GenKollectra {
  def main(args: Array[String]): Unit = {
    val report = SpinalConfig(
      targetDirectory = "generated",
      mode = Verilog
    ).generate(new Kollectra)
    report.mergeRTLSource("mergeRTL")
  }
}
