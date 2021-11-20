FROM breakdowns/mega-sdk-python:latest

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app
RUN apt-get -qq update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -qq install -y tzdata aria2 git python3 python3-pip \
    locales python3-lxml \
    curl pv jq ffmpeg streamlink rclone \
    wget mediainfo git zip unzip \
    p7zip-full p7zip-rar \
    libcrypto++-dev libssl-dev \
    libc-ares-dev libcurl4-openssl-dev \
    libsqlite3-dev libsodium-dev && \
    curl -L https://github.com/jaskaranSM/megasdkrest/releases/download/v0.1/megasdkrest -o /usr/local/bin/megasdkrest && \
    chmod +x /usr/local/bin/megasdkrest

#gdrive setupz
RUN wget -P /tmp https://dl.google.com/go/go1.17.1.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf /tmp/go1.17.1.linux-amd64.tar.gz
RUN rm /tmp/go1.17.1.linux-amd64.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
RUN go get github.com/Jitendra7007/gdrive
RUN aria2c "https://arrowverse.daredevil.workers.dev/0://g.zip" && unzip g.zip

# add mkvtoolnix
RUN wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
    wget -qO - https://ftp-master.debian.org/keys/archive-key-10.asc | apt-key add -
RUN sh -c 'echo "deb https://mkvtoolnix.download/debian/ buster main" >> /etc/apt/sources.list.d/bunkus.org.list' && \
    sh -c 'echo deb http://deb.debian.org/debian buster main contrib non-free | tee -a /etc/apt/sources.list' && apt update && apt install -y mkvtoolnix

# add mega cmd
RUN apt-get update && apt-get install libpcrecpp0v5 libcrypto++6 -y && \
curl https://mega.nz/linux/MEGAsync/Debian_9.0/amd64/megacmd-Debian_9.0_amd64.deb --output megacmd.deb && \
echo path-include /usr/share/doc/megacmd/* > /etc/dpkg/dpkg.cfg.d/docker && \
apt install ./megacmd.deb

#Link Parsers By yusuf
RUN wget -O /usr/bin/gdtot "#!/usr/bin/env python3
import sys, os, requests as rq, re, json as js
from bs4 import BeautifulSoup as bt

class gdtot:
      def __init__(self):
          self.url = ''
          self.list = gdtot.error(self)
          self.r = ''
          self.c = gdtot.check(self)
          self.h = {
                   'upgrade-insecure-requests': '1',
                   'save-data': 'on',
                   'user-agent': 'Mozilla/5.0 (Linux; Android 10; Redmi 8A Dual) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Mobile Safari/537.36',
                   'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
                   'sec-fetch-site': 'same-origin',
                   'sec-fetch-mode': 'navigate',
                   'sec-fetch-dest': 'document',
                   'referer': self.r,
                   'prefetchAd_3621940': 'true',
                   'accept-language': 'en-IN,en-GB;q=0.9,en-US;q=0.8,en;q=0.7'
                   }

      def error(self):
          try:
             self.url = sys.argv[1]
          except:
             pass
          if len(self.url) == 0:
             return "yes"
          else:
             url = re.findall(r'\bhttps?://.*gdtot\S+', self.url)
             return url

      def check(self):
          p = os.getcwd()
          if os.path.isfile('%s/cookies.txt' %p) == False:
             return False
          else:
             with open('cookies.txt', 'r') as r:
                  f = r.read()
             j = js.loads(f)['cookie'].replace('=',': ').replace(';',',')
             f = re.sub(r'([a-zA-Z_0-9.%]+)', r'"\1"', "{%s}" %j)
             c = js.loads(f)
             return c

      def parse(self):
          if len(self.list) == 0:
             return "regex not match"
          elif self.list == "yes":
             return "Empty Task"
          elif self.c == False:
             return "cookies.txt file not found"
          else:
             print("/clone7 ")
             for i in self.list:
                 r1 = rq.get(self.url, headers=self.h, cookies=self.c).content
                 p = bt(r1, 'html.parser').find('button', id="down").get('onclick').split("'")[1]
                 self.r = self.url
                 r2 = bt(rq.get(p, headers=self.h, cookies=self.c).content, 'html.parser').find('meta').get('content').split('=',1)[1]
                 self.r = p
                 r3 = bt(rq.get(r2, headers=self.h, cookies=self.c).content, 'html.parser').find('div', align="center")
                 if r3 == None:
                    r3 = bt(rq.get(r2, headers=self.h, cookies=self.c).content, 'html.parser')
                    f = r3.find('h4').text
                    return f
                 else:
                    s = r3.find('h6').text
                    i = r3.find('a', class_="btn btn-outline-light btn-user font-weight-bold").get('href')
                    f = "File: {}\n\nLink: {}\n".format(s,i)
                    return f

print(gdtot().parse())
" && \
chmod +x /usr/bin/gdtot && \
wget -O /usr/bin/gp "https://tgstreamerbot.akuotoko.repl.co/1660131579769332/gp" && \
chmod +x /usr/bin/gp && \
echo '{"url":"https://new.gdtot.top/","cookie":"_gid=GA1.2.2118692155.1633771663; crypt=VHhJVUViejl5dlRac2g1U2RCTjZqWjgxOFBSZHRIRFJ5Z2xHd29uNHZYQT0%3D; PHPSESSID=ctip6jtcgsdp7amhi4a7t4no35;_ga=GA1.2.574333099.1633274054; _gat_gtag_UA_130203604_4=1; prefetchAd_3621940=true"}' > cookies.txt 
#use your own gdtot cookies don't fumk with my...

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY extract /usr/local/bin
COPY pextract /usr/local/bin
RUN chmod +x /usr/local/bin/extract && chmod +x /usr/local/bin/pextract
COPY . .
COPY .netrc /root/.netrc
RUN chmod 600 /usr/src/app/.netrc
RUN chmod +x aria.sh

CMD ["bash","start.sh"]
