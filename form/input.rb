require 'hash_deep_merge'

class Neo::Form::Input
  attr_accessor :name,:errors,:label,:attr,:opts

  def initialize(opts)
    @name = opts[:name]
    @label = Neo::Form::Label.new(@name,opts[:label],opts[:label_attr])
    @errors = []
    @attr = !opts[:attr].nil? ? opts[:attr] : {}
    @validations = opts[:validations]
    @opts = opts
    set_validations
  end

  def set_validations
    @validations.each do |rule,params|
      validator = Neo::Form::Validations.const_get(rule.to_s.camelize).new(params)
      @attr = validator.get_tag_attributes.deep_merge @attr
    end unless @validations.nil?
  end

  # attributeleri diziden tag stringine çevirip getirir
  def get_attr_string
    if @attr.nil?
      ''
    else
      @attr.reduce('') do |attr, (k, v)|
        k = k.to_s
        attr += v.blank? ? k+' ' : k+'="'+v+'" '
      end
    end
  end

end
