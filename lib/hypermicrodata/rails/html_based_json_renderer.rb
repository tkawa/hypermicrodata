module Hypermicrodata
  module Rails
    module HtmlBasedJsonRenderer
      def initialize
        super
        @_render_based_html_options = {}
      end

      def set_location(location)
        location_url = url_for(location)
        @_render_based_html_options[:location] = location_url
        response.headers['Content-Location'] = location_url
      end

      def set_profile_path(path)
        @_render_based_html_options[:profile_path] = view_context.path_to_asset(path)
      end

      def render_based_html(*args)
         lookup_context.formats.first
        if m = lookup_context.formats.first.to_s.match(/json$/)
          json_format = m.pre_match.to_sym
          json = Hypermicrodata::Extract.new(render_to_string(formats: :html), @_render_based_html_options).to_json(json_format)
          render(json: json)
        else
          render(*args)
        end
      end

      def default_render(*args)
        render_based_html(*args)
      end
    end
  end
end
