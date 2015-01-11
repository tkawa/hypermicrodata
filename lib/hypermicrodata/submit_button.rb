module Hypermicrodata
  class SubmitButton < Property
    attr_reader :form, :method

    def initialize(button, form)
      @button = button
      @form = form.dup
      @excluded_fields = {}
      setup!
    end

    def value
      "#{action_url}?#{query_string}"
    end

    def action_url
      @form.action
    end

    def params
      @form.build_query
    end

    def query_string
      build_query_string(params)
    end

    def names
      (node['itemprop'] || '').split(' ')
    end

    def rels
      rel = (node['rel'] || node['data-rel'] || @button.dom_class || '')
      rel.split(' ')
    end

    def item
      nil
    end

    def link?
      true
    end

    def submit_button?
      true
    end

    def node
      @button.node
    end

    private
    def setup!
      if method_field = @form.fields.find { |f| f.name == '_method' }
        # overload POST
        @method = method_field.value.upcase
        @excluded_fields['_method'] = method_field
      else
        @method = @form.method
      end
      @form.add_button_to_query(@button) # formをdupしているのでOK
    end

    def template_fields
      @template_fields ||= begin
        fields = @form.fields.reject {|field| field.is_a?(Mechanize::Form::Hidden) }
        Hash[fields.map {|field| [field.name, field] }]
      end
    end

    def build_query_string(parameters)
      parameters.map do |name, value|
        if field = template_fields[name]
          [CGI.escape(name.to_s), "{#{field.type}}"].join("=")
        elsif !@excluded_fields[name]
          # WEBrick::HTTP.escape* has some problems about m17n on ruby-1.9.*.
          [CGI.escape(name.to_s), CGI.escape(value.to_s)].join("=")
        end
      end.compact.join('&')
    end
  end
end
