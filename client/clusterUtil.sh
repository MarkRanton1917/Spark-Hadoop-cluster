function clusterUtil {

	cluster_id="pi@192.168.1.101"
	cluster_home="/home/pi"
	cluster_ssh_tmp="$cluster_home/SSH/tmp"
	cluster_hadoop_home="$cluster_home/Software/Hadoop/hadoop-3.3.1"
	cluster_spark_home="$cluster_home/Software/Spark/spark-3.2.1"

	function namenodeCmd {
		ssh $cluster_id "$@"
	}

	function utilCpHdfs {
		scp $1 $cluster_id:$cluster_ssh_tmp
		namenodeCmd "$cluster_hadoop_home/bin/hadoop fs -put $cluster_ssh_tmp/* hdfs://$2; rm $cluster_ssh_tmp/*"
	}

	function util_Hdfs {
		namenodeCmd "$cluster_hadoop_home/bin/hadoop fs $1 hdfs://$2"
	}

	function utilTurnOn {
		namenodeCmd "$cluster_hadoop_home/sbin/start-dfs.sh && $cluster_hadoop_home/sbin/start-yarn.sh"
	}

	function utilTurnOff {
		namenodeCmd "$cluster_hadoop_home/sbin/stop-all.sh"
	}

	function utilPowerOff {
		utilTurnOff
		namemodeCmd ""
	}

	function utilRun {
		scp $1 $cluster_id:$cluster_ssh_tmp
		jar_name=`basename $1`
		namenodeCmd "source .bashrc; $cluster_spark_home/bin/spark-submit --class Main --master yarn --deploy-mode client \
		--conf spark.executor.memory=$2 $cluster_ssh_tmp/$jar_name; rm $cluster_ssh_tmp/*"
	}

	function showError {
		if [[ $1 == "an" ]]; then echo "[!] ClusterUtil: wrong arguments" #arguments number
		elif [[ $1 == "ae" ]]; then echo "[!] ClusterUtil: file $2 does not exist" #argument exists
		elif [[ $1 == "ce" ]]; then echo "[!] ClusterUtil: unknown command/flag $2" #command exists
		fi
	}

	if [[ $1 == "cmd" ]]; then
		shift
		namenodeCmd $@

	elif [[ $1 == "hdfs" ]]; then

		if [[ $# -lt 2 ]]; then
			showError "an"
			return -1
		fi

		if [[ $2 == "-put" ]]; then

			if [[ $# -ne 4 ]]; then
				showError "an"
				return -1

			elif ! [[ -e $3 ]]; then
				showError "ae" $3
				return -1
			fi

			utilCpHdfs $3 $4

		elif [[ $2 == "-rm" ]] || [[ $2 == "-rmdir" ]] || [[ $2 == "-mkdir" ]] || [[ $2 == "-ls" ]]; then

			if [[ $# -ne 3 ]]; then
				showError "an"
				return -1
			fi

			util_Hdfs $2 $3

		else
			showError "ce" $2
			return -1
		fi

	elif [[ $1 == "state" ]]; then

		if [[ $# -ne 2 ]]; then
			showError "an"
			return -1
		fi

		if [[ $2 == "-trnOn" ]]; then
			utilTurnOn

		elif [[ $2 == "-trnOff" ]]; then
			utilTurnOff

		elif [[ $2 == "-pwrOff" ]]; then
			utilPowerOff
			namenodeCmd "clustercmd poweroff"
			poweroff

		else
			showError "ce" $2
			return -1
		fi

	elif [[ $1 == "run" ]]; then

		if [[ $# -ne 3 ]]; then
			showError "an"
			return -1
	 	fi

		if ! [[ -e $2 ]]; then
			showError "ae" $2
			return -1
		fi
		
		utilRun $2 $3

	else
		showError "ce" $1
		return -1
	fi
}
