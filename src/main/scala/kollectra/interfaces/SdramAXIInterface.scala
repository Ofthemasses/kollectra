//package kollectra.interfaces
//
//import spinal.core._
//import kollectra.blackboxes._
//import spinal.lib.bus.amba4.axi._
//import spinal.lib._
//import spinal.lib.io.TriState
//import spinal.lib.memory.sdram._
//import spinal.lib.memory.sdram.sdr._
//
//class W9825G6KH6Interface extends Bundle with IMasterSlave{
//  val ADDR  = Bits(13 bits)
//  val BA    = Bits(2 bits)
//  val DQ    = TriState(Bits(16 bits))
//  val DQM   = Bits(2 bits)
//  val CASn  = Bool()
//  val CKE   = Bool()
//  val CSn   = Bool()
//  val RASn  = Bool()
//
//  override def asMaster(): Unit = {
//    out(ADDR,BA,CASn,CKE,CSn,DQM,RASn)
//    master(DQ)
//  }
//}
//
//class SdramAXIInterface extends Component {
//  val io = new Bundle{
//    val axi = slave(Axi4(
//        Axi4Config(
//          addressWidth = 26,
//          dataWidth    = 32,
//          idWidth      = 4,
//		  useLock = false,
//		  useRegion = false,
//		  useCache = false,
//		  useProt = false,
//		  useQos = false
//        )
//      ))
//    val sdram = master(new W9825G6KH6Interface)
//    val clk        = in Bool()
//    val power      = in Bool()
//    val resetn     = in Bool()
//  }
//
//  val ramController = new W9825G6KH6ControllerBlackBox
//
//
//  def AXI4ToW9825G6KH6Bridge = new Area {
//      val axi = io.axi
//  }
//
//  io.clk <> ramController.io.clk
//  io.power <> ramController.io.power
//  io.resetn <> ramController.io.resetn
//}
//
