lazy val root = (project in file("."))
  .aggregate(vexriscv)
  .settings(
	name := "KollectraVexRiscvProject",
	version := "0.1",
	scalaVersion := "2.12.18",
	fork := true,
	libraryDependencies ++= Seq(
	  "com.github.spinalhdl" %% "spinalhdl-core" % "1.10.1"
	)
  )

lazy val vexriscv = (project in file("lib/VexRiscv"))
