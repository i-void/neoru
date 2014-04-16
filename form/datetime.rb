class Neo::Form::Datetime < Neo::Form::Input
  attr_accessor :opts
  def initialize(opts)
    #name,label=nil,value='',attr={}, label_attr={}
    @opts = opts
    super(@opts[:name],@opts[:label],@opts[:attr],@opts[:label_attr])
  end

  def to_tag
    input_tag = '<input type="text" class="form-control" value="" readonly '
    input_tag += 'value="'+@opts[:value]+'" ' unless @opts[:value].blank?
    input_tag += get_attr_string.to_s + '/>'

    '
    <div class="input-append date" id="'+@opts[:name]+'"">
      '+input_tag+'
      <span class="add-on"><i class="icon-th"></i></span>
    </div>

    <script type="text/javascript">
      $(function () {
        $("#'+@opts[:name]+'").datetimepicker({
          language: "tr",
          format: "dd MM yyyy - hh:ii",
          autoclose: true,
          todayBtn: true,
          pickerPosition: "bottom-left"
        });
      });
    </script>'
  end
end