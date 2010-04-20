module Rtopia
  def self.R(*args)
    @rtopia ||= Object.new.extend(self)

    @rtopia.R(*args)
  end

  # Pass any collection of objects
  # R will use it's :to_param, then :id (if ruby19), then :to_s
  #
  # Examples:
  #
  #    R(:items) # => /items
  #    
  #    @person = Person.new # has a to_param of john-doe
  #    R(@person) # => '/john-doe'
  #    R(@person, :posts) # => '/john-doe/posts'
  #    R(@person, :posts, :replied) # => '/john-doe/posts/replied'
  #
  #    @entry = Entry.create # has an id of 1001 for example
  #    R(@entry) # => '/1001'
  #    R(:entry, @entry) # => '/entry/1001'
  #   
  def R(*args)
    args.unshift('/').map { |arg| to_param(arg) }.join('/').squeeze('/')
  end

private
  # Primary difference of this method is that it checks if
  # the passed object has an :id method
  # after checking for a :to_param
  #
  def to_param_ruby19(object)
    if object.respond_to?(:to_param)
      object.to_param
    elsif object.respond_to?(:id)
      object.id
    else
      object.to_s
    end
  end
  
  # Since ruby 1.8 Objects all have a deprecated :id
  # method which is also the same as its :object_id
  # we can't just blindly check for an :id method
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
