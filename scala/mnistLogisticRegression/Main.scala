import org.apache.spark.sql.SparkSession
import org.apache.spark.ml.classification.LogisticRegression
import org.apache.log4j._

object Main {
  def main(args: Array[String]): Unit = {

    Logger.getLogger("org").setLevel(Level.ERROR)

    val session = SparkSession
      .builder
      .appName("Mnist Dataframe")
      .master("local[*]")
      .getOrCreate

    val mnistTrainDataset = datasetUtil.getDataset(session, "MNIST_train.txt")
    val mnistEvalDataset = datasetUtil.getDataset(session, "MNIST_test.txt")

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