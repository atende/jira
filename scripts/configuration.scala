import scala.xml.XML
import scala.xml.transform._
import scala.xml._
import java.nio.file.StandardCopyOption.REPLACE_EXISTING
import java.nio.file.Files.copy
import java.nio.file.Paths.get
import java.nio.file.Files.exists

class ProxyTransform(port: Int, proxyName: String, proxyPort: Int, scheme: String, secured: Boolean) extends RewriteRule {

  override def transform(n: Node): Seq[Node] = n match {
    case e: Elem if (e.label == "Connector" && (e \ "@port").text == port.toString) =>
        e % Attribute(None, "proxyName", Text(proxyName), Null) %
        Attribute(None, "proxyPort", Text(proxyPort.toString()), Null) %
        Attribute(None, "scheme", Text(scheme), Null) %
        Attribute(None, "secured", Text(secured.toString()), Null)
    case other => other
  }
}

class AddConnectorTransform(newPort: Int) extends RewriteRule {
    override def transform(n: Node): Seq[Node] = n match {
        case e: Elem if e.label == "Connector" =>
          Seq(e,e % Attribute(None, "port", Text(newPort.toString()), Null))
        case other => other
    }
}

val PROXY_PORT = sys.env.get("PROXY_PORT").getOrElse("80").toInt
val PROXY_SCHEME = sys.env.get("PROXY_SCHEME").getOrElse("http")
val PROXY_SECURED = sys.env.get("PROXY_SECURED").getOrElse("false").toBoolean
val SOFTWARE_NAME = sys.env.get("SOFTWARE_NAME").getOrElse("noSoftwareName")
val TOMCAT_LOCATION = sys.env.get("TOMCAT_LOCATION").getOrElse(s"/opt/${SOFTWARE_NAME}")
val SECONDARY_NO_SSL_PORT = sys.env.get("SECONDARY_NO_SSL_PORT")
val VIRTUAL_HOST = sys.env.get("VIRTUAL_HOST")
val SOFTWARE_PORT = sys.env("SOFTWARE_PORT").toInt

val tomcatFile = TOMCAT_LOCATION + "/conf/server.xml"
val tomcatFileOriginal = TOMCAT_LOCATION + "/conf/server.original.xml"

implicit def toPath (filename: String) = get(filename)
if(!exists(tomcatFileOriginal)){
   copy (tomcatFile, tomcatFileOriginal , REPLACE_EXISTING)
}

val tomcatXml = XML.loadFile(tomcatFileOriginal)

var finalTransformation: Node = tomcatXml
if(SECONDARY_NO_SSL_PORT.isDefined){
    finalTransformation = new RuleTransformer(new AddConnectorTransform(SECONDARY_NO_SSL_PORT.get.toInt))(finalTransformation)
}
if(VIRTUAL_HOST.isDefined) {
   finalTransformation = new RuleTransformer(new ProxyTransform(SOFTWARE_PORT, VIRTUAL_HOST.get, PROXY_PORT, PROXY_SCHEME, PROXY_SECURED))(finalTransformation)
}
XML.save(TOMCAT_LOCATION + "/conf/server.xml", finalTransformation, "UTF-8", true, null)



