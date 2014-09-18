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