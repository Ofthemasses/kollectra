package kollectra
import spinal.core._
import spinal.core.sim._

object KollectraSim {
  def main(args: Array[String]): Unit = {
    SimConfig
      .withIVerilog
      .addSimulatorFlag("-v")
      .addRunFlag("-v")
      .withWave
      .compile(new KollectraHarness)
      .doSim { dut =>
        dut.io.power  #= true

        fork {
          while(true) {
            dut.io.clk165 #= false; sleep(3)
            dut.io.clk165 #= true;  sleep(3)
          }
        }

        dut.io.resetn #= false
        sleep(50)
        dut.io.resetn #= true

        sleep(1000000)
      }
  }
}
