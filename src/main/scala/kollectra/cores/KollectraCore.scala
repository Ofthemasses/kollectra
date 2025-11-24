package kollectra.cores

import kollectra.blackboxes._
import vexriscv.plugin._
import vexriscv.{plugin, VexRiscv, VexRiscvConfig}
import vexriscv.ip.{DataCacheConfig}
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
          prediction = DYNAMIC_TARGET,
          catchAccessFault = true,
          compressedGen = true
        ),
        new DBusCachedPlugin(
          config = new DataCacheConfig(
            cacheSize = 4096,
            bytePerLine = 16,
            wayCount = 1,
            addressWidth = 32,
            cpuDataWidth = 32,
            memDataWidth = 32,
            catchAccessError = false,
            catchIllegal = false,
            catchUnaligned = true
          )
        ),
        new StaticMemoryTranslatorPlugin(
          ioRange = _(31 downto 28) === 0xF
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
          executeInsertion = true
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
        new MulPlugin,
        new DivPlugin,
        new BranchPlugin(
          earlyBranch = false,
          catchAddressMisaligned = true 
        )
      )
    )
  val cpu = new VexRiscv(config)

  val io = new Bundle {
    val iBus = master(Axi4ReadOnly(IBusSimpleBus.getAxi4Config()))
    val dBus = master(cpu.config.plugins.collectFirst {
        case p: DBusCachedPlugin => p.dBus
    }.get.toAxi4Shared())
    val timerInterrupt = in Bool()
    val externalInterrupt = in Bool()
  }

  for(plugin <- config.plugins) plugin match{
    case plugin : IBusSimplePlugin => io.iBus <> plugin.iBus.toAxi4ReadOnly()
    case plugin : CsrPlugin => {
      plugin.timerInterrupt := io.timerInterrupt
      plugin.externalInterrupt := io.externalInterrupt
    }
    case _ =>
  }
}
