#!/usr/bin/env bash
# b means cluster begins
# e means cluster stops
binary_name=sgx_raft_host

start_cluster() {
    pushd 0
    ../run.sh -d
    popd
    sleep 0.5

    pushd 1
    ../run.sh -d
    popd
    sleep 0.5

    pushd 2
    ../run.sh -d
    popd
}

stop_cluster() {
    echo kill all ${binary_name} processes
    # `sudo apt install psmisc` to get killall
    sudo killall -9 ${binary_name}
}

int_handler() {
    stop_cluster;
    exit;
}

while getopts "a:be" arg #选项后面的冒号表示该选项需要参数
do
        case $arg in
             a)
                echo "a's arg:$OPTARG" #参数存在$OPTARG中
                ;;
             b)
                # Firstly stop the running servers
                stop_cluster
                start_cluster
                trap int_handler SIGINT
                run=0
                while true
                do
                    echo Raft servers have been running for $run seconds;
                    sleep 10;
                    run=`expr $run + 10`;
                done
                ;;
             e)
                stop_cluster
                ;;
            #  v)
            #     echo "Using valgrind"
            #     running_cmd="valgrind --tool=memcheck --leak-check=full --log-file=valout_mem.txt"
            #     ;;
             ?)  #当有不认识的选项的时候arg为?
            echo "unknow argument"
        exit 1
        ;;
        esac
done

