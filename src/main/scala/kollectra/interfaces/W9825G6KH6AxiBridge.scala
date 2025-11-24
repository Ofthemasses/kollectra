package kollectra.interfaces

import kollectra.blackboxes.W9825G6KH6ControllerBlackBox
import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba4.axi._

class W9825G6KH6AxiBridge extends Component {
  val io = new Bundle {
    val axi = slave(Axi4(Axi4Config(
		addressWidth = 26,
		dataWidth    = 32,
		idWidth      = 4,
		useId        = true,
		useRegion    = false,
		useBurst     = true,
		useLock      = false,
		useCache     = false,
		useProt      = false,
		useQos       = false,
		useLen       = true,
		useSize      = true,
		useLast      = true,
		useResp      = true
    )))

    val sdramCtrl = new Bundle {
      val cmd = new Bundle {
        val valid   = out Bool()
        val ready   = in Bool()
        val addr    = out UInt(26 bits)
        val we      = out Bool()
        val wstrb   = out UInt(2 bits)
      }

      val wdata_valid = out Bool()
      val wdata_ready = in Bool()
      val wdata 		= out UInt(16 bits)

      val rdata_valid = in Bool()
      val rdata_ready = out Bool()
      val rdata = in UInt(16 bits)
    }
  }


  object State extends SpinalEnum {
    val Idle, StartWrite, WriteLo, WriteHi, WriteResp, ReadCmd, ReadWait, ReadResp = newElement()
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

  val burstCounter = Reg(UInt(4 bits))

  io.sdramCtrl.cmd.valid := False
  io.sdramCtrl.cmd.addr  := 0
  io.sdramCtrl.cmd.we    := False
  io.sdramCtrl.cmd.wstrb := 0
  io.sdramCtrl.wdata_valid := False
  io.sdramCtrl.wdata := 0
  io.sdramCtrl.rdata_ready := False

  io.axi.aw.ready := False
  io.axi.w.ready  := False
  io.axi.b.valid  := False
  io.axi.b.id     := writeId
  io.axi.b.resp   := B"00"

  io.axi.ar.ready := False
  io.axi.r.valid  := False
  io.axi.r.id     := readId
  io.axi.r.data   := 0
  io.axi.r.resp   := B"00"
  io.axi.r.last   := True

  switch(state) {
    is(State.Idle) {
      when (io.sdramCtrl.cmd.ready){
        io.axi.ar.ready := True
        io.axi.aw.ready := True
        io.axi.w.ready  := True
      }

      when(io.axi.aw.fire && io.axi.w.fire) {
        state := State.StartWrite
      } elsewhen(io.axi.ar.fire) {
        state := State.ReadCmd
      }
    }

    is(State.StartWrite) {
      writeAddr := io.axi.aw.addr
      writeData := io.axi.w.data
      writeStrb := io.axi.w.strb
      writeId   := io.axi.aw.id
      when(io.sdramCtrl.cmd.ready) {
        io.sdramCtrl.cmd.valid := True
        io.sdramCtrl.cmd.addr := writeAddr
        io.sdramCtrl.cmd.we := True
      } elsewhen (io.sdramCtrl.wdata_ready) {
        burstCounter := 3
        state := State.WriteLo
      }
    }

    is(State.WriteLo) {
      io.sdramCtrl.cmd.wstrb := ~writeStrb(1 downto 0).asUInt

      io.sdramCtrl.wdata := writeData(15 downto 0).asUInt
      io.sdramCtrl.wdata_valid := True
      state := State.WriteHi
    }

    is(State.WriteHi) {
      when(burstCounter === 0){
        state := State.WriteResp
      } otherwise {
        io.sdramCtrl.cmd.wstrb := ~writeStrb(3 downto 2).asUInt

        io.sdramCtrl.wdata := writeData(31 downto 16).asUInt
        io.sdramCtrl.wdata_valid := True
        burstCounter := burstCounter - 1
        state := State.WriteLo
      }
    }

    is(State.WriteResp) {
      io.axi.b.valid := True
      when(io.axi.b.ready) {
        state := State.Idle
      }
    }

    is(State.ReadCmd) {
      readAddr := io.axi.ar.addr
      readId := io.axi.ar.id
      when(io.sdramCtrl.cmd.ready) {
        io.sdramCtrl.cmd.valid := True
        io.sdramCtrl.cmd.addr := readAddr
        io.sdramCtrl.cmd.we := False
        state := State.ReadWait
      }
    }

    is(State.ReadWait) {
      io.sdramCtrl.cmd.valid := True
      io.sdramCtrl.rdata_ready := True
      when(io.sdramCtrl.rdata_valid) {
        readLo := io.sdramCtrl.rdata
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
}

