source data/creds.env
source mk-helpers/env.vars
eval $(docker-machine env $machine)

for i in `seq 1 6`;
do
  docker-compose exec -T gitlab gitlab-rails runner "Ci::Variable.create :key => \"DOCKERHUB_USER\", :value => \"$DOCKERHUB_USER\", :gl_project_id => $i; \
    Ci::Variable.create :key => \"DOCKERHUB_PASSWORD\", :value => \"$DOCKERHUB_PASSWORD\", :gl_project_id => $i; \
    Ci::Variable.create :key => \"DEV_HOST\", :value => \"$module5_host\", :gl_project_id => $i"
done

docker-compose exec gitlab_runner gitlab-runner register -n
