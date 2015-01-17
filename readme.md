[Türkçe Döküman]

Neoru, Neo4j için geliştirilmiş bir web frameworktür. Hem development hem runtime'da hızlı olmayı hedefler.
=============================================================

Özellikleri
-----------
- Neo4j Orm ve model yapıları
- Template Sistemi ve template cache
- Otomatik, ya da konfigurasyona bağlı routing yapabilme
- I18N yerelleştirme ve dil özellikleri
- REST bazlı routing sistemi (GET, POST, DELETE, PUT)
- Event sistemi
- Kendi exceptionlarınızı oluşturabilme
- CSS, JS sıkıştırma özellikleriyle asset yöneticisi
- Sass, Compass, Erb, Haml, Slim, Coffeescript, Opal desteği
- Form sistemi
- Widget ve modül bazlı yapı (HMVC)
- Cronjob için konsol komutları yazabilme
- Data fixture yönetimi
- Unit Test için rspec, BDD için cucumber ve selenium entegrasyonu

Neoru şu anda birçok özelliği bakımından stabil durumdadır. Ancak otomatik test
sistemi ve versiyonlama dökümantasyon bittikten sonra eklenecektir. Dökümantasyon
ilk olarak Türkçe olarak tamamlanıp arkasından İngilizce'ye çevrilecektir.

Aşağıda uygulama iskeleti için yazmaya başladığım dökümantasyonun bir kısmı bulunmaktadır.
Dökümantasyon genişledikçe iskelet ve framework ayrı ayrı dökümantasyonlara sahip olacak.

Neoru İskeleti
==============
Bu iskelet sizin neoru ile ilk web uygulamanızın çatısını oluşturacak.
Bu döküman altında dosyaların işlevleri ile ilgili bilgiler bulacaksınız.

Ana dizinden başlayacak olursak. Neoru framework'umuze yardımcı olacak bazı dosyaların olduğunu görebilirsiniz.

### console.rb
Uygulamanızda yazdığınız tüm komutlar bu dosya sayesinde işlenir. Örnek olarak `User` modülü
altına yazdığınız hesabını aktif hale getirmeyenleri silen `delete_deactive` şeklinde bir komut(metod) olduğunu
düşünürsek bunu çalıştırmak için ana dizindeyken `ruby console.rb user:delete_deactive` demeniz yeterli olacaktır.

### Gemfile
Herhangi bir gem uygulamanız için gerekli olduğunda `gem 'gemin-ismi'` şeklinde bir satırı bu dosyaya ekleyerek
ve sistemde ister `bundler` kullanarak isterseniz de `gem install 'gemin-ismi'` yönergesi kullanarak
gem'i sisteme yükleyebilirsiniz. Gemfile ile ilgili daha geniş bilgiyi
[http://bundler.io/gemfile.html](http://bundler.io/gemfile.html)
adresinden bulabilirsiniz

### init_test.rb
Neoru test sistemi olarak cucumber, rspec ve selenium-webdriver kullanır. Cucumber için yazdığınız testlerden
hemen önce bu dosyayı include ederseniz, Neoru'yu init etmiş ve gerekli dosyaları otomatikmen yüklemiş olursunuz.


Selenium Kullanımı
------------------
    @selen = Neo::Selenium
    @selen.get 'http://yahoo.com'
    mail_btn = @selen.find 'li[data-suid="14782488"]>a'
    mail_btn.click
    user_input = @selen.find '#inputs input#username[type="text"][name="login"]'
    user_input.send_keys 'ribozom8@yahoo.com'
    pass = @selen.find '#inputs input#passwd[type="password"][name="passwd"]'
    pass.send_keys '123456'
    @selen.find('#pLabel').click
    @selen.find('#\.save').click

@author = 'Onur Eren Elibol'