class Neo::Form::Datetime < Neo::Form::Input
  attr_accessor :opts

  def initialize(opts)
    super(opts)
  end

  def to_tag
    input_tag = '<input type="text" class="form-control" value="" readonly '
    input_tag += 'value="'+@opts[:value]+'" ' unless @opts[:value].blank?
    input_tag += get_attr_string.to_s + '/>'
    input_tag += error_html

    '
    <div class="input-append date" id="'+@opts[:name]+'"">
      '+input_tag+'
      <span class="add-on"><i class="icon-th"></i></span>
    </div>

    <script type="text/javascript">
      window.onload = function(){
        $("#'+@opts[:name]+'").datetimepicker({
          language: "tr",
          format: "dd MM yyyy - hh:ii",
          autoclose: true,
          todayBtn: true,
          pickerPosition: "bottom-left"
        });
      };
    </script>'
  end
end