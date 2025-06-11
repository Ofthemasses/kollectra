package kollectra.interfaces

import kollectra.blackboxes.W9825G6KH6ControllerBlackBox
import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba4.axi._

class W9825G6KH6AxiBridge extends Component {
  val io = new Bundle {
    val axi = slave(Axi4(Axi4Config(
      addressWidth = 26,
      dataWidth = 32,
      idWidth = 4,
      useLock = false,
      useRegion = false,
      useCache = false,
      useProt = false,
      useQos = false
    )))

    val sdramCtrl = new W9825G6KH6ControllerBlackBox
    val clk       = in Bool()
    val power     = in Bool()
    val resetn    = in Bool()
  }

  object State extends SpinalEnum {
    val Idle, WaitWriteData, WriteLo, WriteHi, WriteResp, ReadCmd, ReadWait, ReadResp = newElement()
  }
  val state = RegInit(State.Idle)

  val writeAddr  = Reg(UInt(26 bits))
  val writeData  = Reg(Bits(32 bits))
  val writeStrb  = Reg(Bits(4 bits))
  val writeId    = Reg(UInt(4 bits))

  val readAddr   = Reg(UInt(26 bits))
  val readId     = Reg(UInt(4 bits))
  val readLo     = Reg(UInt(16 bits))
  val readingHi  = Reg(Bool()) init(False)

  io.sdramCtrl.io.cmd.valid := False
  io.sdramCtrl.io.cmd.addr  := 0
  io.sdramCtrl.io.cmd.we    := False
  io.sdramCtrl.io.cmd.wstrb := 0
  io.sdramCtrl.io.wdata_valid := False
  io.sdramCtrl.io.wdata := 0
  io.sdramCtrl.io.rdata_ready := False

  io.axi.aw.ready := False
  io.axi.w.ready := False
  io.axi.b.valid := False
  io.axi.b.id := writeId
  io.axi.b.resp := B"00"

  io.axi.ar.ready := False
  io.axi.r.valid := False
  io.axi.r.id := readId
  io.axi.r.data := 0
  io.axi.r.resp := B"00"
  io.axi.r.last := True


  switch(state) {
    is(State.Idle) {
      io.axi.ar.ready := True
      io.axi.aw.ready := True
      io.axi.w.ready  := True

      when(io.axi.aw.fire && io.axi.w.fire) {
        writeAddr := io.axi.aw.addr
        writeData := io.axi.w.data
        writeStrb := io.axi.w.strb
        writeId   := io.axi.aw.id
        state := State.WriteLo
      } elsewhen(io.axi.ar.fire) {
        readAddr := io.axi.ar.addr
        readId := io.axi.ar.id
        state := State.ReadCmd
      }
    }

    is(State.WriteLo) {
      when(io.sdramCtrl.io.cmd.ready) {
        io.sdramCtrl.io.cmd.valid := True
        io.sdramCtrl.io.cmd.addr := writeAddr
        io.sdramCtrl.io.cmd.we := True
        io.sdramCtrl.io.cmd.wstrb := writeStrb(1 downto 0).asUInt

        io.sdramCtrl.io.wdata := writeData(15 downto 0).asUInt
        io.sdramCtrl.io.wdata_valid := True

        when(io.sdramCtrl.io.wdata_ready) {
          when (writeStrb(3 downto 2).orR) {
            state := State.WriteHi
          } otherwise {
            state := State.WriteResp
          }
        }
      }
    }

    is(State.WriteHi) {
      when(io.sdramCtrl.io.cmd.ready) {
        io.sdramCtrl.io.cmd.valid := True
        io.sdramCtrl.io.cmd.addr := writeAddr | U(2)
        io.sdramCtrl.io.cmd.we := True
        io.sdramCtrl.io.cmd.wstrb := writeStrb(3 downto 2).asUInt

        io.sdramCtrl.io.wdata := writeData(31 downto 16).asUInt
        io.sdramCtrl.io.wdata_valid := True

        when(io.sdramCtrl.io.wdata_ready) {
          state := State.WriteResp
        }
      }
    }

    is(State.WriteResp) {
      io.axi.b.valid := True
      when(io.axi.b.ready) {
        state := State.Idle
      }
    }

    is(State.ReadCmd) {
      when(io.sdramCtrl.io.cmd.ready) {
        io.sdramCtrl.io.cmd.valid := True
        io.sdramCtrl.io.cmd.addr := readAddr
        io.sdramCtrl.io.cmd.we := False
        state := State.ReadWait
      }
    }

    is(State.ReadWait) {
      io.sdramCtrl.io.rdata_ready := True
      when(io.sdramCtrl.io.rdata_valid) {
        readLo := io.sdramCtrl.io.rdata
        state := State.ReadResp
      }
    }

    is(State.ReadResp) {
      io.axi.r.valid := True
      io.axi.r.data := Mux(readAddr(1),
        B(0, 16 bits) ## readLo.asBits,
        readLo.asBits ## B(0, 16 bits)
      )
      when(io.axi.r.ready) {
        state := State.Idle
      }
    }
  }

  io.clk <> io.sdramCtrl.io.clk
  io.power <> io.sdramCtrl.io.power
  io.resetn <> io.sdramCtrl.io.resetn
}
