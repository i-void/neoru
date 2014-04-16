describe 'Asset Manager' do

  it '#blah' do

    Neo::Params.module = 'main'
    Neo::Params.controller = 'main'
    Neo::Params.action = 'index'

    manager = Neo::Asset::Manager
    manager.init

    Neo::Params.env.should == 'dev'
  end

end