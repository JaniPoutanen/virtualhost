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

    $ sudoedit /etc/apache2/sites-available/oliot.conf
  
    <VirtualHost *:80>
      DocumentRoot /home/xubuntu/public_html/

      <Directory /home/xubuntu/public_html/>
          Require all granted
      </Directory>
    </VirtualHost>
  
Otin janipoutaorg.conf käyttöön ja poistin oletus 000-default.conf käytöstä:

    $ sudo a2ensite oliot.conf  
    $ sudo a2dissite 000-default.conf
  
Käynnistin palvelimen uudelleen:

    $ sudo service apache2 restart 

Tein kansion public_html, johon tiedoston index.html. Tiedostoon kirjoitin vain tekstin HTML.

    $ mkdir public_html
    $ cd public_html/
    $ nano index.html

Muokkasin hosts tiedostoon oikeat sivut:

    $ sudoedit /etc/hosts
  
    127.0.0.1 oli.ot
    127.0.1.1 www.oli.ot
  
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

    $ sudo cp /etc/apache2/sites-available/oliot.conf oliot.conf.erb
    
Samoin /etc/hosts

    $ sudo cp /etc/hosts hosts.erb
    
Tein templates kansioon tiedoston index.html.erb, joka toimii mallina käyttäjän kotisivulle. Itse tiedoston mallina käytin [W3schoolin etusivua](https://www.w3schools.com/).
    
    $ sudoedit index.html.erb
    
Kirjoitin opettajan [mallin](https://github.com/terokarvinen/nukke) mukaan tiedostot start.sh ja apply.sh kansioon /home/xubuntu/virtualhost

Seuraavaksi tein kansioon manifests tiedoston inip.pp, josta useamman pienen kirjoitusvirheen kautta tuli seuraavanlainen:

        class virtualhost {
            package { 'apache2':
                    ensure => 'installed',
                    allowcdrom => 'true',
            }
            file { '/etc/apache2/sites-available/oliot.conf':
                    content => template('virtualhost/oliot.conf.erb'),
                    notify => Service['apache2'],
            }
            file { '/etc/hosts':
                    content => template('virtualhost/hosts.erb'),
                    notify => Service['apache2'],
            }
            file { '/home/xubuntu/public_html':
                    ensure => 'directory',
            }
        }

Nämä kaikki kansiot ja tiedostot tallensin vähitellen Gittiin. Kun olin valmis ajoin modulin kopioimalla start.sh tiedoston raw-version.
Kaikkien kirjoitusvirheiden ja polkujen muutosten jälkeen ei tullut enää virheilmoituksia ja pääsin testaamaan modulia selaimessa.
Näkyviin tuli Apachen testisivu. En ollut tehnyt komentoja

        sudo a2ensite 000-defaul.conf && a2dissite janipoutaorg.conf

Lisäsin oheiset komennot init.pp tiedostoon sivun https://www.puppetcookbook.com/posts/exec-a-command-in-a-manifest.html avulla. Oheiselta sivustolta selvitin aiemmin, kuinka tehdään kansio Puppetilla.

        class virtualhost {
            package { 'apache2':
                    ensure => 'installed',
                    allowcdrom => 'true',
            }
            file { '/etc/apache2/sites-available/oliot.conf':
                    content => template('virtualhost/oliot.conf.erb'),
                    require => Service['apache2'],
            }
            file { '/etc/hosts':
                    content => template('virtualhost/hosts.erb'),
                    require => Service['apache2'],
            }
            file { '/home/xubuntu/public_html':
                    ensure => 'directory',
            }
            file { '/home/xubuntu/public_html/index.html':
                    content => template('virtualhost/index.html.erb'),
                    require => File['/home/xubuntu/public_html'],
            }
            service { 'apache2':
                    ensure => 'true',
                    enable => 'true',
                    provider => 'systemd',
            }
            exec { 'a2ensite':
                    command => 'sudo a2ensite oliot.conf',
                    path => '/bin:/usr/bin:/sbin:/usr/sbin:',
                    require => File['/etc/apache2/sites-available/oliot.conf'],
            }
            exec { 'a2dissite':
                    command => 'sudo a2dissite 000-default.conf',
                    path => '/bin:/usr/bin:/sbin:/usr/sbin:',
                    notify => Service['apache2'],
            }
        }
  Nyt toimi:
  
  ![html](oli.ot.png]
  
  ## Yhteenveto
  
Harjoitus oli oikein opettavainen, vaikka viimeinen osa jäikin tällä erää tekemättä. Suurin ongelma on syntaksin opettelelu. Yrityksen ja erehdyksen kautta pääsin siedettävään lopputulokseen. En myöskään löytänyt aikaa selvittää kuinka sivun saisi muokattavaksi kullekin käyttäjälle. Nyt toimii vain käyttäjälle xubuntu ja vain osoitteeseen oli.ot.
