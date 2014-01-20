Neo.use 'view'
module Neo
	class Controller
		attr_accessor :renderer,:layout
		def render(params)
			if @layout.blank?
				return Neo::View.new.render(params)
			else
				view_html =  Neo::View.new.render(params)
				params[:content] = view_html
				content = Neo::View.new(@layout).render(params)
				return Neo::Response.html(content)
			end
		end

		def redirect(url)
			return Neo::Response.redirect(url)
		end

		def render_view(view,params)
			content = Neo::View.new(view).render(params)
			return Neo::Response.html(content)
		end
	end
end