package kollectra

import spinal.core._
import kollectra.cores._
import kollectra.blackboxes.W9825G6KH6ControllerBlackBox
import kollectra.interfaces._
import kollectra.peripherals._
import spinal.lib._
import spinal.lib.bus.amba4.axi._

class Kollectra extends Component {
  val io = new Bundle {
    val clk    = in Bool()
    val power  = in Bool()
    val resetn = in Bool()
    val timerInterrupt    = in Bool()
    val externalInterrupt = in Bool()
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

  val sysCd = ClockDomain(
    clock = io.clk,
    reset = io.resetn,
    config = ClockDomainConfig(
      clockEdge        = RISING,
      resetKind        = ASYNC,
      resetActiveLevel = LOW
    )
  )

  val area = new ClockingArea(sysCd) {
    val core        = new KollectraCore
    val sdramCtrl = new W9825G6KH6ControllerBlackBox
    val sdramBridge = new W9825G6KH6AxiBridge

    val bootRom     = new BootRomAxi(
      hexPath   = "firmware/build/main.hex",
      sizeBytes = 64 * 1024
    )

    val axiX = Axi4CrossbarFactory()
    axiX.addSlaves(
      sdramBridge.io.axi -> (0x00000000L, 32 MiB),
      bootRom.io.axi     -> (0x80000000L, 64 KiB)
    )
    axiX.addConnections(
      core.io.dBus -> List(sdramBridge.io.axi),
      core.io.iBus -> List(bootRom.io.axi)
    )
    axiX.build()

    io.sdram <> sdramCtrl.io.sdram;
    sdramCtrl.io.cmd <> sdramBridge.io.sdramCtrl.cmd

    sdramBridge.io.sdramCtrl.wdata_valid <> sdramCtrl.io.wdata_valid
    sdramBridge.io.sdramCtrl.wdata_ready <> sdramCtrl.io.wdata_ready
    sdramBridge.io.sdramCtrl.wdata <> sdramCtrl.io.wdata

	sdramBridge.io.sdramCtrl.rdata_valid <> sdramCtrl.io.rdata_valid
	sdramBridge.io.sdramCtrl.rdata_ready <> sdramCtrl.io.rdata_ready
	sdramBridge.io.sdramCtrl.rdata <> sdramCtrl.io.rdata

    core.io.timerInterrupt    := io.timerInterrupt
    core.io.externalInterrupt := io.externalInterrupt
    sdramCtrl.io.clk := io.clk
    sdramCtrl.io.power := io.power
    sdramCtrl.io.resetn := io.resetn
  }
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
