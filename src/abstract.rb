module Abstract

  # Interface for declaratively indicating that one or more methods are to be
  # treated as abstract methods, only to be implemented in child classes.
  #
  # Arguments:
  # - methods (Symbol or Array) list of method names to be treated as
  #   abstract base methods
  #
  def abstract_methods(*methods)
    methods.each do |method_name|

      define_method method_name do
        raise NotImplementedError, "This is an abstract base method (#{method_name}). Implement in your subclass."
      end

    end
  end
end
