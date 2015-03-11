class HomeController < ApplicationController
	#default page which shows all the courses
	def index
		api = API.new
		response = api.getCourses();
		if(response)
			@courses = JSON.parse(response.body)
			@links = parseLinks(response.headers['Link'])
		else
			#Do something with error
			@error = api.error_code
			@courses = []
			@links = []
		end
  	
  	end

	#displays data for single course
	def show
		api = API.new
		response = api.getCourse(params[:id])
		if(response)
	  		@course = JSON.parse(response.body)
		else
			#Do something with error
			@error = api.error_code
			@course = {}
		end  
	end

	#shows page by page listing of course
	def page
		api = API.new
		response = api.getCoursePage(params[:page], params[:per_page])
		if(response)
			@courses = JSON.parse(response.body)
			@links = parseLinks(response.headers['Link'])
		else
			#Do something with error
			@error = api.error_code
			@courses = []
			@links = []
		end
		render "index"
	end

	#enroll in a course
	def enrollments
		api = API.new
		response = api.enroll(params[:id])
		if(response)
			@status = JSON.parse(response.body)
		else
			#Do something with error
			@error = api.error_code
			@status = {}
		end
	end

end
