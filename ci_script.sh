echo "Build Tag: $BUILD_TAG"
echo $PATH
whoami
pwd
ruby -v
date

echo "---START---"

bundle --no-color
bundle exec rake

echo "---END---"
