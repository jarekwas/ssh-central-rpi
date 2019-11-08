# Konfiguracja Głównego RPI

Projekt zawiera 
* Dokumentacje konfiguracji systemu operacyjnego na Raspberry Pi
* Konfiguracje Pipeline do obsługi procesu CI i CD dla Projektu

By odpalić CI i CD potrzebny jest jeszcze Gitlab.

## Intrukcja instalacji i konfiguracji systemu operacyjnego RPI

### Utils

Odczyt temperatury CPU

```
vcgencmd measure_temp
```


### Procedura konfiguracji systemu

#### Włączenie SSH
https://www.raspberrypi.org/documentation/remote-access/ssh/

```
sudo systemctl enable ssh
sudo systemctl start ssh
```

#### Dodatkowe pakiety

```
apt-get update
apt-get install -y vim git aptitude
```


#### Instalacja Dokera
https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl
```
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi
sudo apt-get install libffi-dev
sudo apt-get install -y python python-pip
sudo pip install docker-compose
```

```
docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  klud/gitlab-runner
```

No i jeszcze trzeba go zarejestrować w swoim gitlabie ;).

#### Przygotowanie obrazu docker compose dla arm
https://www.berthon.eu/2017/getting-docker-compose-on-raspberry-pi-arm-the-easy-way/

```
mkdir src
cd src
git clone https://github.com/docker/compose.git
cd compose
git checkout release
cp -i Dockerfile Dockerfile.armhf
sed -i -e 's/^FROM debian\:/FROM armhf\/debian:/' Dockerfile.armhf
sed -i -e 's/x86_64/armel/g' Dockerfile.armhf
docker build -t docker-compose:armhf -f Dockerfile.armhf .
```

Tu w powstałym dokerze nalezy poprawić na:
```
ARG RUNTIME_DEBIAN_VERSION=stretch-slim
```

#### Rekonfiguracja runnera

Tak by:
- pozwalał na odpalanie obrazów privilaged - by móc deploy na arduino robić
- by nie pobierał obrazw ktore ma (czyli uzywal naszego cicd).

```
docker exec -it gitlab-runner bash
vi /etc/gitlab-runner/config.toml
```

https://docs.gitlab.com/runner/configuration/advanced-configuration.html

 - dodać - pull_policy = "if-not-present"
 - zmienić - privileged = true

 ```yml
 [runners.docker]                                                      
    pull_policy = "if-not-present"                                    
    tls_verify = false                 
    image = "alpine"           
    privileged = true                                             
    disable_entrypoint_overwrite = false                           
    oom_kill_disable = false                                  
    disable_cache = false                                        
    volumes = ["/var/run/docker.sock:/var/run/docker.sock","/cache"]
    shm_size = 0                   
```

#### Instalacja Arduino Cli 
https://github.com/arduino/arduino-cli

```
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
```
