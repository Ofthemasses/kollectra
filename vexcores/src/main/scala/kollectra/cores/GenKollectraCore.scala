package kollectra.cores

import spinal.core._
import vexriscv._
import vexriscv.plugin._

object GenKollectraCore {
  def main(args: Array[String]): Unit = {
	val cpuConfig = VexRiscvConfig(
	  plugins = List(
		new IBusSimplePlugin(
		  resetVector = 0x80000000L,
		  cmdForkOnSecondStage = true,
		  cmdForkPersistence = true
		),
		new DBusSimplePlugin(
		  catchAddressMisaligned = false,
		  catchAccessFault = false
		)
	  )
	)
	SpinalConfig(targetDirectory = "output/vexriscv").generateVerilog(new VexRiscv(cpuConfig))
  }
}


