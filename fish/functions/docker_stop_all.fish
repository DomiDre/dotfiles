function docker_stop_all -d "Stop all running Docker containers"
    set -l running_containers (docker ps -q)
    if test -n "$running_containers"
        docker stop $running_containers
    else
        echo "No running Docker containers found."
    end
end
