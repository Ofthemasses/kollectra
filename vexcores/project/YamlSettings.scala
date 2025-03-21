import java.io.{File, FileInputStream, FileReader}
import com.fasterxml.jackson.module.scala.DefaultScalaModule
import com.fasterxml.jackson.databind.{JsonNode, ObjectMapper}
import org.yaml.snakeyaml.Yaml

object ProjectConfig {
  def load(): JsonNode = {
    val input = new FileInputStream(new File("../config.yaml"))
    val yaml = new Yaml()
    val mapper = new ObjectMapper().registerModules(DefaultScalaModule)
    val yamlObj = yaml.loadAs(input, classOf[Any])

    val jsonString = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(yamlObj)
    val jsonObj = mapper.readTree(jsonString)
    return jsonObj
  }
}
