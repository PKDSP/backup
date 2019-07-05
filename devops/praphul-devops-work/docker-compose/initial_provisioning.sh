initial_pro_dir="${HOME}/initialprovisioning"
initial_pro_file="initial_pro_file"
docker-compose down
docker-compose up -d

if [ ! -f $initial_pro_dir/$initial_pro_file ];
then
        echo "file does not exists"
        container_id=`docker ps --no-trunc -qf name=app1`
        echo $container_id
        sleep 10
        docker exec -it $container_id /bin/sh -c "python csv_import.py"
        sudo touch $initial_pro_dir/$initial_pro_file
else
        echo "file exists"
fi