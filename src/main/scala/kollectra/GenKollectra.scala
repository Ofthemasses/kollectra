package kollectra

import spinal.core._
import kollectra.cores._
import kollectra.blackboxes._

class Kollectra extends Component {
  val io = new Bundle {
    val clk        = in Bool()
    val power      = in Bool()
    val resetn     = in Bool()
    val ready      = out Bool()
    val currstate  = out UInt(4 bits)

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

  val core = new Area{
    val cpu = KollectraCore.cpu()
  }

  val ramController = new W9825G6KH6ControllerBlackBox

  io.clk        <> ramController.io.clk        
  io.power      <> ramController.io.power      
  io.resetn     <> ramController.io.resetn     
  io.ready      <> ramController.io.ready      
  io.currstate  <> ramController.io.currstate  

  io.sdram_clk  <> ramController.io.sdram_clk  
  io.sdram_cke  <> ramController.io.sdram_cke  
  io.sdram_csn  <> ramController.io.sdram_csn  
  io.sdram_rasn <> ramController.io.sdram_rasn 
  io.sdram_casn <> ramController.io.sdram_casn 
  io.sdram_wen  <> ramController.io.sdram_wen  
  io.sdram_a    <> ramController.io.sdram_a    
  io.sdram_ba   <> ramController.io.sdram_ba   
  io.sdram_dqm  <> ramController.io.sdram_dqm  
  io.sdram_d    <> ramController.io.sdram_d    
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
