import org.apache.spark.sql.SparkSession
import org.apache.spark.ml.classification.LogisticRegression
import org.apache.log4j._

object Main {
  def main(args: Array[String]): Unit = {

    Logger.getLogger("org").setLevel(Level.ERROR)

    val session = SparkSession
      .builder
      .appName("Mnist Logistic Regression")
      .master("yarn")
      .getOrCreate

    val mnistTrainDataset = datasetUtil.getDataset(session, "hdfs:///data/MNIST/MNIST_train.txt")
    val mnistEvalDataset = datasetUtil.getDataset(session, "hdfs:///data/MNIST/MNIST_train.txt")

    mnistTrainDataset.printSchema

    val regression = new LogisticRegression()
      .setMaxIter(100)
      .setRegParam(0.001)
      .setElasticNetParam(0.005)
      .setFamily("multinomial")

    val mnistRegression = regression.fit(mnistTrainDataset).evaluate(mnistEvalDataset)

    println(s"Accuracy: ${mnistRegression.accuracy}, precision: ${mnistRegression.precisionByLabel.mkString("Array(", ", ", ")")}")

    session.close
  }
}
