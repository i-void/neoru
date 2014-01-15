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
				return Neo::View.new(@layout).render(params)
			end
		end

		def render_view(view,params)
			return Neo::View.new(view).render(params)
		end
	end
end