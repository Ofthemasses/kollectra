package kollectra.peripherals

import spinal.core._
import spinal.lib._
import spinal.lib.misc.HexTools
import spinal.lib.bus.amba4.axi._

case class BootRomAxi(hexPath: String, sizeBytes: Int, dataWidth: Int = 32) extends Component {
  val io = new Bundle {
    val axi = slave(Axi4ReadOnly(Axi4Config(
      addressWidth = 32,
      dataWidth    = dataWidth,
      idWidth      = 1,
      useRegion    = false,
      useBurst     = true,
      useLock      = false,
      useQos       = false,
      useCache     = false
    )))
  }

  val bytesPerBeat = dataWidth / 8
  val depth        = sizeBytes / bytesPerBeat

  val rom = Mem(Bits(dataWidth bits), depth)

  HexTools.initRam(rom, hexPath, 0x80000000L)

  val ar = io.axi.ar
  val r  = io.axi.r

  val arFire = ar.valid && ar.ready
  ar.ready := !r.valid || (r.valid && r.ready && r.last)

  val addrReg  = Reg(UInt(32 bits)) init(0)
  val lenReg   = Reg(UInt(8 bits))  init(0)
  val beatsRem = Reg(UInt(8 bits))  init(0)

  when(arFire){
    addrReg  := ar.addr
    lenReg   := ar.len
    beatsRem := ar.len + 1
  }

  val wordIndex = (addrReg >> log2Up(bytesPerBeat)).resized

  val rData = rom.readAsync(wordIndex)

  r.valid   := beatsRem =/= 0
  r.id      := ar.id
  r.data    := rData
  r.resp    := B"00"
  r.last    := beatsRem === 1

  when(r.fire){
    addrReg  := addrReg + bytesPerBeat
    beatsRem := beatsRem - 1
  }
}
