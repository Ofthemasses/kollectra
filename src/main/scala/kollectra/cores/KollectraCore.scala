package kollectra.cores

import kollectra.blackboxes._
import vexriscv.plugin._
import vexriscv.{plugin, VexRiscv, VexRiscvConfig}
import spinal.core._
import spinal.lib.bus.amba4.axi._
import spinal.lib._

case class KollectraCore() extends Component {

  val config = VexRiscvConfig(
      plugins = List(
        new IBusSimplePlugin(
          resetVector = 0x80000000l,
          cmdForkOnSecondStage = false,
          cmdForkPersistence = true,
          prediction = STATIC,
          catchAccessFault = true,
          compressedGen = true
        ),
        new DBusSimplePlugin(
          catchAddressMisaligned = false,
          catchAccessFault = false
        ),
        new CsrPlugin(CsrPluginConfig.smallest),
        new DecoderSimplePlugin(
          catchIllegalInstruction = false
        ),
        new RegFilePlugin(
          regFileReadyKind = plugin.SYNC,
          zeroBoot = false
        ),
        new IntAluPlugin,
        new SrcPlugin(
          separatedAddSub = false,
          executeInsertion = false
        ),
        new LightShifterPlugin,
        new HazardSimplePlugin(
          bypassExecute           = false,
          bypassMemory            = false,
          bypassWriteBack         = false,
          bypassWriteBackBuffer   = false,
          pessimisticUseSrc       = false,
          pessimisticWriteRegFile = false,
          pessimisticAddressMatch = false
        ),
        new BranchPlugin(
          earlyBranch = false,
          catchAddressMisaligned = false
        )
      )
    )
  val cpu = new VexRiscv(config)

  val io = new Bundle {
    val iBus = master(Axi4ReadOnly(IBusSimpleBus.getAxi4Config()))
    val dBus = master(Axi4(DBusSimpleBus.getAxi4Config()))
    val timerInterrupt = in Bool()
    val externalInterrupt = in Bool()
  }

  for(plugin <- config.plugins) plugin match{
    case plugin : IBusSimplePlugin => io.iBus <> plugin.iBus.toAxi4ReadOnly()
    case plugin : DBusSimplePlugin => io.dBus <> plugin.dBus.toAxi4()
    case plugin : CsrPlugin => {
      plugin.timerInterrupt := io.timerInterrupt
      plugin.externalInterrupt := io.externalInterrupt
    }
    case _ =>
  }
}
