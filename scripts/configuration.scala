import scala.xml.XML
import scala.xml.transform._
import scala.xml._
import java.nio.file.StandardCopyOption.REPLACE_EXISTING
import java.nio.file.StandardOpenOption.APPEND
import java.nio.file.Files.copy
import java.nio.file.Paths.get
import java.nio.file.Files.exists
import java.nio.file.{Paths, Files}
import java.nio.charset.StandardCharsets

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

class SeraphSSOTransform(app: String) extends RewriteRule {
  override def transform(n: Node): Seq[Node] = n match {
    case e: Elem if e.label == "authenticator" =>
      e % Attribute(None, "class", Text(this.classConfig()), Null)
    case other => other
  }
  def classConfig(): String = {
    app match {
      case "jira" => "com.atlassian.jira.security.login.SSOSeraphAuthenticator"
      case "bamboo" => "com.atlassian.crowd.integration.seraph.v25.BambooAuthenticator"
      case "confluence" => "com.atlassian.confluence.user.ConfluenceCrowdSSOAuthenticator"
      case _ => ""
    }
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
val CROWD_URL = sys.env.get("CROWD_URL")
val CROWD_PASSWORD = sys.env.get("CROWD_PASSWORD")
val CROWD_APPLICATION_NAME = sys.env.get("CROWD_APPLICATION_NAME")

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
val softwareHome = if(SOFTWARE_NAME == "confluence") TOMCAT_LOCATION + s"/confluence" else TOMCAT_LOCATION + s"/atlassian-${SOFTWARE_NAME}"
val seraphFile = softwareHome + "/WEB-INF/classes/seraph-config.xml"
val crowdPropertiesFile = softwareHome + "/WEB-INF/classes/crowd.properties"
val stashConfigProperties = "/opt/stash-home/shared/stash-config.properties"
val stashConfigPropertiesOriginal = "/opt/stash-home/shared/stash-config.original.properties"
for {
  crowdUrl <- CROWD_URL
  crowdPassword <- CROWD_PASSWORD
  crowdAppName <- CROWD_APPLICATION_NAME
} yield {
  if(SOFTWARE_NAME != "stash"){
    val seraphXml = XML.loadFile(seraphFile)
    val seraphTransform = new RuleTransformer(new SeraphSSOTransform(SOFTWARE_NAME))(seraphXml)
    XML.save(seraphFile, seraphTransform)
    val crowdProperties = createCrowProperties(crowdAppName, crowdPassword, crowdUrl)
    Files.write(Paths.get(crowdPropertiesFile), crowdProperties.getBytes(StandardCharsets.UTF_8))
  }else {
    if(exists(stashConfigPropertiesOriginal)){
      copy (stashConfigPropertiesOriginal, stashConfigProperties, REPLACE_EXISTING)
      Files.write(Paths.get(stashConfigProperties), "plugin.auth-crowd.sso.enabled=true".getBytes(StandardCharsets.UTF_8), APPEND)
    }else if(exists(stashConfigProperties)){
      copy (stashConfigProperties, stashConfigPropertiesOriginal, REPLACE_EXISTING)
      Files.write(Paths.get(stashConfigProperties),"plugin.auth-crowd.sso.enabled=true".getBytes(StandardCharsets.UTF_8), APPEND)
    }else{
      Files.createFile(stashConfigPropertiesOriginal)
      Files.write(Paths.get(stashConfigProperties), "plugin.auth-crowd.sso.enabled=true".getBytes(StandardCharsets.UTF_8))
    }

  }
}

def createCrowProperties(appName: String, appPassword: String, crowdUrl: String, sessionValidationInterval: Int = 2) = {
  s"""
  |application.name  $appName
  |application.login.url ${crowdUrl}/crowd/console/
  |application.password $appPassword
  |crowd.server.url ${crowdUrl}/crowd/services/
  |session.validationinterval $sessionValidationInterval
  |session.isauthenticated                 session.isauthenticated
  |session.tokenkey                        session.tokenkey
  |session.lastvalidation                  session.lastvalidation
  |bamboo.crowd.cache.minutes          60
  """.stripMargin
}