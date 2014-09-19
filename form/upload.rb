class Neo::Form::Upload < Neo::Form::Input
  attr_accessor :opts

  def initialize(opts)
    super(opts)
  end

  def to_tag
    @opts[:label] = Neo::trn 'Add File' if @opts[:label].nil?
    @attr = {class:''}.deep_merge @attr
    (@attr[:class] += ' btn upload-btn').strip!

    <<-UPLOAD_HTML_TEMPLATE
    <div progress="#{@opts[:name]}" class="upload-wrapper">

      <div class="upload-img-wrapper">
      </div>

      <div name="#{@opts[:name]}" id="#{@opts[:name]}" #{get_attr_string} >
        #{@opts[:label].if_nil{''}}
        #{error_html}
      </div>

      <div class="progress-wrapper">

        <div class="upload-progress">
          <div class="upload-progress-bar">
            <div class="upload-percent">
              %11
            </div>
          </div>
        </div>

      </div>


      <div style="clear:both;"></div>
    </div>
    UPLOAD_HTML_TEMPLATE
  end

end