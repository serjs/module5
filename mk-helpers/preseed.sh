source mk-helpers/env.vars
source data/creds.env
#docker-machine create -d parallels --parallels-cpu-count 4 --parallels-disk-size "8440" --parallels-memory "4048" $machine
SRC_CERTS=~/.docker/machine/machines/$machine/*.pem
DST_CERTS=images/docker-git-compose/certs

printf "\nСоздаем сервер с Gitlab CI\n"
docker-machine create -d amazonec2 --amazonec2-root-size "60" --amazonec2-instance-type "t2.large" --amazonec2-region "eu-central-1" --amazonec2-subnet-id "subnet-ccbf57a5" $machine

source mk-helpers/env.vars

# Set machine vars
eval $(docker-machine env $machine)

# Create gitlab CI image
cp -r $SRC_CERTS $DST_CERTS
printf "\n\n\nСоздаем образ для CI агента\n"
docker build -t $DOCKERHUB_USER/docker:git-compose images/docker-git-compose
docker push $DOCKERHUB_USER/docker:git-compose

# Setup infrastructure
printf "\n\n\nПоднимаем инфраструктуру\n"
docker-compose up -d

while [ $(curl --write-out %{http_code} --silent --output /dev/null http://$module5_host/users/sign_in) -ne 200 ]; do
  # Убираем возможно регистрации на время мастер-класса
  printf "Выполняем настройки CI\n"
  docker-compose exec -T gitlab gitlab-rails runner "ApplicationSetting.last.update_attributes(signup_enabled: false)" > /dev/null

  printf "Создаем пользователя\n"
  # Создаем пользователя
  docker-compose exec -T gitlab gitlab-rails runner "user = User.find_by(email: 'admin@example.com'); user.password = \"$GITLAB_PASSWORD\"; user.password_confirmation = 'dockermk'; user.password_automatically_set = false; user.save" > /dev/null
done

printf "\n\nАдрес вашего сервера: $module5_host\n"
printf "Gitlab login: $GITLAB_USER\n"
printf "Gitlab password: $GITLAB_PASSWORD\n"
