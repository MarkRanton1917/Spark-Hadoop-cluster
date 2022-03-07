import org.apache.spark.sql.{Dataset, SparkSession}
import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.ml.linalg

object datasetUtil {
  def getDataset(session: SparkSession, file: String): Dataset[Number] = {

    import session.implicits._

    val rawDataset = session
      .sparkContext
      .textFile(file)
      .map(_.split(","))
      .map(
        x =>
          Number(
            x.head.toInt,
            linalg.Vectors.dense(x.tail.map(_.toDouble / 255.0))
          )
      )
      .toDF

    new VectorAssembler()
      .setInputCols(Array("pixels"))
      .setOutputCol("features")
      .transform(rawDataset)
      .as[Number]
  }
}
