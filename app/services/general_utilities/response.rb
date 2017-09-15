class Response

  def initialize(*args)
    for arg in args
      add_response(arg)
    end
  end

  def add_error(variable_name, status, body)
    add_response(variable_name)
    message = "Status: #{status} => #{body}"
    instance_variable_set("@#{variable_name}", message)
  end

  def ok?
    self.instance_variables.empty?
  end

  def get_errors
    str = ''

    for var in instance_variables
      value = self.instance_variable_get(var.to_s)
      str += value unless value.nil?
    end

    str
  end

  private

  def create_accessors(arg)
    self.class_eval("def #{arg};@#{arg};end")
    self.class_eval("def #{arg}=(val);@#{arg}=val;end")
  end

  def add_response(arg)
    instance_variable_set("@#{arg}", nil)
    create_accessors(arg)
  end

end
