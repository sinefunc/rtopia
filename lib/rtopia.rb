require 'uri'
require 'cgi'

module Rtopia
  # In order to be able to do `Rtopia::R`, Rtopia needs to extend itself
  extend self

  # Usage:
  #
  #    R(:items) # => /items
  #    
  #    @person = Person.new # has a to_param of john-doe
  #    R(@person) # => '/john-doe'
  #    R(@person, :posts) # => '/john-doe/posts'
  #    R(@person, :posts, :replied) # => '/john-doe/posts/replied'
  #
  #    @entry = Entry.create # has an id of 1001 for example and Ruby1.9
  #    R(@entry) # => '/1001'
  #    R(:entry, @entry) # => '/entry/1001'
  #   
  #    R(:search, :q => 'Ruby', :page => 1) => '/search?q=Ruby&page=1'
  #    R(:q => 'Ruby', :page => 1) => '?q=Ruby&page=1'
  #    R(:q => ['first, 'second']) => '?q[]=first&q[]=second'
  #    R(:user => { :lname => 'Doe', :fname => 'John' })
  #    => '?user[lname]=Doe&user[fname]=John'
  #
  def R(*args)
    hash = args.last.is_a?(Hash) ? args.pop : {}

    # No args, so we opt to make ?q=Ruby&page=1 style URIs
    if hash.any? and args.empty?
      '?' + query_string(hash)
    else
      r = args.unshift('/').map { |arg| to_param(arg) }.join('/').squeeze('/')
      if hash.any?
        r << '?'
        r << query_string(hash)
      end
      r
    end
  end

private
  def query_string(hash)
    hash.inject([]) { |arr, (key, value)|
      if value.is_a?(Array)
        value.each do |e|
          arr << key_value("#{key}[]", e)
        end
        arr
      elsif value.is_a?(Hash)
        value.each do |namespace, deeper|
          arr << key_value("#{key}[#{namespace}]", deeper)
        end
        arr
      else
        arr << key_value(key, value)
      end
    }.join('&')
  end

  def key_value(k, v)
    '%s=%s' % [CGI.escape(k.to_s), URI.escape(to_param(v))]
  end

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
