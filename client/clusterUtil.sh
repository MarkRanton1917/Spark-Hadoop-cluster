function clusterUtil {

	cluster_id="pi@192.168.1.101"
	cluster_hadoop_bin="/home/pi/Software/Hadoop/hadoop-3.3.1/bin"

	function namenodeCmd {
		ssh $cluster_id "$@"
	}

	function utilCpHdfs {
		tmp_dir="/home/pi/SSH/tmp"
		scp $1 $cluster_id:$tmp_dir
		namenodeCmd "$cluster_hadoop_bin/hadoop fs -put $tmp_dir/* hdfs://$2; rm $tmp_dir/*"
	}

	function util_Hdfs {
		namenodeCmd "$cluster_hadoop_bin/hadoop fs $1 hdfs://$2"
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

		elif [[ $2 == "-put" ]]; then

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
	else
		showError "ce" $1
		return -1
	fi
}
