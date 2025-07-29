function docker_stop_all -d "Stop all running Docker containers and clean up exited ones"
    # Stop all running containers
    set -l running_containers (docker ps -q)
    if test -n "$running_containers"
        docker stop $running_containers
        echo "Stopped running containers."
    else
        echo "No running Docker containers found."
    end

    # Clean up all exited containers
    set -l exited_containers (docker ps -a -q -f status=exited)
    if test -n "$exited_containers"
        docker rm $exited_containers
        echo "Cleaned up exited containers."
    else
        echo "No exited Docker containers to clean up."
    end
end
