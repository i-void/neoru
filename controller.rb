module Neo
  class Controller
    attr_accessor :renderer,:layout

    def render(params={})
      if @layout.blank?
        content = Neo::View.new.render(params)
        Neo::Response.html(content)
      else
        view_html =  Neo::View.new.render(params)
        params[:content] = view_html
        content = Neo::View.new(@layout).render(params)
        Neo::Response.html(content)
      end
    end

    def redirect(url)
      Neo::Response.redirect(url)
    end

    def render_view(view,params)
      content = Neo::View.new(view).render(params)
      Neo::Response.html(content)
    end
  end
end