# virtualhost
Installs Apache2 server and creates virtualhost for user



Haaga-Helian kurssin Palvelinten Hallinta kolmas kotitehtävä. Opettajana kurssilla toimii Tero Karvinen. Tehtävän toimeksianto opettajan sivulla: http://terokarvinen.com/2017/aikataulu-%E2%80%93-palvelinten-hallinta-ict4tn022-2-%E2%80%93-5-op-uusi-ops-loppukevat-2017-p2.

*h3. a) Package-File-Server. Asenna ja konfiguroi jokin demoni package-file-server -tyyliin. Tee jokin muu asetus kuin tunnilla näytetty sshd:n portin vaihto.*

*b) Modulit Gitistä. Tee skripti, jolla saat nopeasti modulisi kloonattua GitHubista ja ajettua vaikkapa liverompulle. Voit katsoa mallia terokarvinen/nukke GitHub-varastosta.* 

*c) Vapaaehtoinen: Vaihda Apachen default VirtualHost Puppetilla siten, että sivut ovat jonkun kotihakemistossa ja niitä voi muokata normaalin käyttäjän oikeuksin.* 

*d) Vapaaehtoinen vaikea: Konfiguroi jokin muu demoni (kuin Apache tai SSH) Puppetilla.*

Laitteistona harjoituksessa toimi Lenovon IdeaPad G700, jonka suoritin on Intel Core i5-3230M 2,60GHz, RAM-muistia koneessa on 8 Gt. Xubuntun 64 bittinen 16.04 LTS versio toimii aiemmin tehdyn livetikun kautta.

Ajatuksena oli asentaa Apache sekä tehdä moduli, joka vaihtaa virtualhostin xubuntun kotihakemistoon

## Virtualhostin testaus

Ensin testasin virtualhostin toiminnan ilman Puppettia

Asensin Apachen

    $ sudo apt-get install apache2
  
Kirjoitin tiedoston janipoutaorg.conf apachen sites-available kansioon:

    $ sudoedit /etc/apache2/sites-available/janipoutaorg.conf
  
    <VirtualHost *:80>
      DocumentRoot /home/xubuntu/public_html/

      <Directory /home/xubuntu/public_html/>
          Require all granted
      </Directory>
    </VirtualHost>
  
Otin janipoutaorg.conf käyttöön ja poistin oletus 000-default.conf käytöstä:

    $ sudo a2ensite janipoutaorg.conf  
    $ sudo a2dissite 000-default.conf
  
Käynnistin palvelimen uudelleen:

    $ sudo service apache2 restart 

Tein kansion public_html, johon tiedoston index.html. Tiedostoon kirjoitin vain tekstin HTML.

    $ mkdir public_html
    $ cd public_html/
    $ nano index.html

Muokkasin hosts tiedostoon oikeat sivut:

    $ sudoedit /etc/hosts
  
    127.0.0.1 janipouta.org
    127.0.1.1 www.janipouta.org
  
Lopputulos toimi:

![screenshot](/html.png)

## Puppet modulin teko

Asensin Puppetin

    $ sudo apt-get -y install puppet

Siirryttyäni modules kansioon tein sinne kansion virtualhost, johon tein kansiot manifests ja templates

    $ sudo mkdir virtualhost
    cd virtualhost
    $ sudo mkdir manifests
    $ sudo mkdir templates
    
Siirryin templates kansioon ja kopioin sinne /etc/apache2/sites-available/janipoutaorg.conf tiedoston erb-päätteiseksi.

    $ sudo cp /etc/apache2/sites-available/janipoutaorg.conf janipoutaorg.conf.erb
    
Samoin /etc/hosts

    $ sudo cp /etc/hosts hosts.erb
    
Kirjoitin opettajan [mallin](https://github.com/terokarvinen/nukke) mukaan tiedostot start.sh ja apply.sh kansioon /home/xubuntu/virtualhost





