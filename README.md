# zabbix-grafana-on-raspberry

## Instructions
### Install Dependencies
```bash
sudo apt-get update
sudo apt-get install curl git ca-certificates
sudo apt-get install binutils gcc make libc-dev
sudo apt-get install ruby ruby-dev  # for fpm
sudo apt-get install rpm            # for rpmbuild, used indirectly by grafana (call to fpm)
sudo apt-get install libfontconfig1 libicu52 libjpeg62-turbo  # for my phantomjs binary !
```
Install go 1.5.2 from hypriot :
```bash
curl -L https://github.com/hypriot/golang-armbuilds/releases/download/v1.5.2/go1.5.2.linux-armv7.tar.gz | tar -xz -C /usr/local
export PATH=/usr/local/go/bin:$PATH
```
Install nodejs :
```bash
cd /tmp
curl -L https://nodejs.org/dist/latest-v5.x/node-v5.12.0-linux-armv7l.tar.xz | tar xfJ  -                                                       && \
mv -t /usr/local/bin     node-v5.12.0-linux-armv7l/bin/*
mv -t /usr/local/include node-v5.12.0-linux-armv7l/include/*
mv -t /usr/local/lib     node-v5.12.0-linux-armv7l/lib/*
mv -t /usr/local/share   node-v5.12.0-linux-armv7l/share/*
```
Install fpm :
```bash
gem install fpm
```
Finally, install your `phantomjs` binary. For example :
```bash
wget https://github.com/anisimovev/zabbix-grafana-on-raspberry/raw/master/phantomjs_2.0.0_armhf.deb
sudo dpkg -i /tmp/phantomjs_2.0.0_armhf.deb
```

### Build Grafana
The good news is you mainly have to follow the official
[instructions](https://github.com/grafana/grafana/blob/v2.6.0/docs/sources/project/building_from_source.md)
with just a few modifications.
```bash
export GOPATH=/tmp/graf-build
mkdir -p $GOPATH
cd $GOPATH
go get github.com/grafana/grafana
cd $GOPATH/src/github.com/grafana/grafana
git checkout v3.1.1
go run build.go setup    
$GOPATH/bin/godep restore   
npm install
npm install -g grunt-cli
cd $GOPATH/src/github.com/grafana/grafana
```
Now, the fix for `phantomjs`.
```bash
export LOC=./node_modules/karma-phantomjs-launcher/node_modules/phantomjs/lib/location.js
echo "module.exports.location = \"`which phantomjs`\"" > $LOC
echo "module.exports.platform = \"linux\"" >> $LOC
echo "module.exports.arch = \"arm\"" >> $LOC
```
Finally,
```bash
go run build.go build package
```
The packages are in `./dist`
