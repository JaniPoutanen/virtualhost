setxkbmap fi
sudo apt-get update
sudo apt-get -y install puppet git
git clone https://github.com/janipoutanen/virtualhost.git
cd start
bash apply.sh
