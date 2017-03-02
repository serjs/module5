source data/creds.env
source mk-helpers/env.vars
eval $(docker-machine env $machine)

DIR="module5_app"
mkdir ../$DIR
cd ../$DIR

for i in ubuntu ruby mongodb blog_ui blog_backend blog; do
  printf "Trying to clone $i repo\n"
  git clone http://$GITLAB_USER:$GITLAB_PASSWORD@$module5_host/module5/$i.git;
done

if [[ "$OSTYPE" == "linux-gnu" ]]; then
   find . -type f -name Dockerfile -exec sed -i "s/changeme/$DOCKERHUB_USER/" {} +
elif [[ "$OSTYPE" == "darwin"* ]]; then
   find . -type f -name Dockerfile -exec sed -i '' s/changeme/$DOCKERHUB_USER/ {} +
fi

echo "Change dir to $DIR for working with Gitlab repo"

for i in ubuntu ruby mongodb blog_ui blog_backend blog; do
  printf "Push updated changes"
  cd $i; git commit -am "Up"; \
  git push origin master; \
  cd ../
done
