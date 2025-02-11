lazy val vexCoreConfig = ProjectConfig.load().get("vexcores")

lazy val spinalVersion = vexCoreConfig.get("spinalVersion").asText
lazy val vexRiscvRepo = vexCoreConfig.at("/vexriscv/url").asText
lazy val vexRiscvCommitHash = vexCoreConfig.at("/vexriscv/commit").asText

lazy val root = (project in file("."))
  .settings(
    inThisBuild(List(
      organization := "org.codeberg.kollectra",
      scalaVersion := vexCoreConfig.get("scalaVersion").asText,
      version      := "0.1.0"
    )),
    name := "KollectraCores",
    libraryDependencies ++= Seq(
	  "com.github.spinalhdl" %% "spinalhdl-core" % spinalVersion,
      "com.github.spinalhdl" %% "spinalhdl-lib" % spinalVersion,
      compilerPlugin("com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinalVersion),
    )
  ).dependsOn(vexRiscv)

lazy val vexRiscv = RootProject(uri(s"$vexRiscvRepo#$vexRiscvCommitHash"))

fork := true
