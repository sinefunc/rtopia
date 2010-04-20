module Rtopia
  def self.R(*args)
    @rtopia ||= Object.new.extend(self)

    @rtopia.R(*args)
  end

  def R(*args)
    args.unshift('/').map { |arg| to_param(arg) }.join('/').squeeze('/')
  end

  def to_param_ruby19(object)
    if object.respond_to?(:to_param)
      object.to_param
    elsif object.respond_to?(:id)
      object.id
    else
      object.to_s
    end
  end

  def to_param_ruby18(object)
    if object.respond_to?(:to_param)
      object.to_param
    else
      object.to_s
    end
  end
  
  if RUBY_VERSION >= "1.9"
    alias to_param to_param_ruby19
  else
    alias to_param to_param_ruby18
  end
end
