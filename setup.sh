#Manjaro installation

sudo pacman -Sy ruby
gem install jekyll
gem install rubygems-bundler
cd ~/github/linlinzhao.github.io
bundler update

bundle exec jekyll build
bundle exec jekyll serve
