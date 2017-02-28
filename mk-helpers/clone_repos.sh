source data/creds.env
source mk-helpers/env.vars
eval $(docker-machine env $machine)

DIR="module5_app"
mkdir ../$DIR
cd ../$DIR

for i in ubuntu ruby mongodb blog_ui blog_backend blog; do
  echo "Trying to clone $i repo"
  git clone http://$GITLAB_USER:$GITLAB_PASSWORD@$module5_host/module5/$i.git;
done

find . -type f -name Dockerfile -exec sed -i '' s/changeme/$DOCKERHUB_USER/ {} +
echo "Change dir to $DIR for working with Gitlab repo"
