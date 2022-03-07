name := "spark"
version := "1.0"
scalaVersion := "2.13.7"
libraryDependencies ++= Seq(
  "org.apache.spark" % "spark-core_2.13" % "3.2.1",
  "org.apache.spark" % "spark-sql_2.13" % "3.2.1",
  "org.apache.spark" % "spark-streaming_2.13" % "3.2.1",
  "org.apache.spark" % "spark-mllib_2.13" % "3.2.1",
  "org.jmockit" % "jmockit" % "1.34" % "test"
)
