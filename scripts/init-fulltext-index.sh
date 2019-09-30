#!/bin/sh
attempts=12
sleep_time=10s

if [ ! -z $1 ] && [ ! -z $2 ]; then
	# start graphdb
	/opt/graphdb/bin/graphdb -s &
	gdb_pid=$!
	echo "GraphDB started with pid=$gdb_pid."

	# generate the SPARQL query for FTS index
	iquery=$(./gen-graphdb-fts-config.sh $2)

	# try to init the FTS index
	while [ $attempts -gt 0 ]
	do
		sleep $sleep_time
		echo "$iquery"
		status=$(curl -o /dev/null -w "%{http_code}" --request POST -H "Content-Type: application/sparql-update" http://localhost:7200/repositories/$1/statements --data "$iquery")
		case "$status" in
			2* ) 
				break
				;;
			* )
				echo "Failed to connect, next try in $sleep_time. Status Code: $status"
				attempts=`expr $attempts - 1`
				;;
		esac
	done

	kill -9 $gdb_pid
else
	echo "Repository ID as well as a name for FTS index must be specified." 1>&2
	exit 1
fi
