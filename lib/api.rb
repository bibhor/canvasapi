class API
	attr_reader :error_code
	include HTTParty
	#URL to get token from
	base_uri 'canvas-api.herokuapp.com'
	format :json
	ERROR_CODE_1 = "Invalid Course Id"
	ERROR_CODE_2 = "Invalid HTTP Response"
	ERROR_CODE_3 = "Unable to get token from API"
	ERROR_CODE_4 = "Invalid Page Id or Per Page"
	API_URL = "/api/v1/courses"
	TOKEN_URL = "/api/v1/tokens"
	
	def initialize
		@error_code = nil
	end

	# This function will get the token from cache or set it to cache after getting from the API from getTokenFromAPI
	# Params:
	# Returns: token string 
	def getToken
		unless Rails.cache.exist?('token')
			token = getTokenFromAPI
			Rails.cache.write('token', token)	
		end
		token = Rails.cache.read('token');
		return token
	end

	# This function will create an AuthHeader hash that can be used in the API request using token
	# Params:
	# Returns: AuthHeader
	def getAuthHeader
		token = getToken
		val = "Token " << token
		return { "Authorization" => val}
	end

	# This function will get Course list from the API
	# Params:
	# Returns: Course from canvas api
	def getCourses
		return getFromAPI(API_URL)
	end

	# This function will get course info for a single course
	# Params: course_id which is passed through the URL
	# Returns: Course data from API
	def getCourse(course_id)
		i_course_id = numberOrNil(course_id)
		if(i_course_id.nil? || i_course_id < 0)
			@error_code = ERROR_CODE_1
			return nil
		end
		return getFromAPI(API_URL+"/"+course_id)
	end

	# This function will get courses for a particular page
	# Params: page_id, per_page
	# Returns: Courses for a page
	def getCoursePage(page_id, per_page)
		i_page_id = numberOrNil(page_id)
		i_per_page = numberOrNil(per_page)
		if(i_page_id.nil? || i_page_id < 0 || i_per_page.nil? || i_per_page < 0)
			@error_code = ERROR_CODE_4
			return nil
		end
		return getFromAPI(API_URL+"?page="+i_page_id+"&per_page"+per_page)
	end

	# This function will get courses for a particular page
	# Params: course_id
	# Returns: enroll status
	def enroll(course_id)
		i_course_id = numberOrNil(course_id)
		if(i_course_id.nil? || i_course_id < 0)
			@error_code = ERROR_CODE_4
			return nil
		end
		return postEnroll(API_URL+"/"+course_id+"/enrollments")
	end

	# This function will get token from the API using the httpparty
	# Params: 
	# Returns: Course data from API
	def getTokenFromAPI
		response = self.class.post(TOKEN_URL)
		if((response.code.eql? 200) || (response.code.eql? 201))
			return response["token"]
		else
			@error_code = ERROR_CODE_3
			return nil
		end
	end

	# This function will try to enroll for a course
	# Params: 
	# Returns: enroll status
	def postEnroll(url)
		header = getAuthHeader
		response = self.class.post(url, 
					:headers => header, 
					:body => {"type"=> "student", "user"=> {"name" => "Test User"}})
		puts response
		if((response.code.eql? 201))
			return response
		else
			@error_code = ERROR_CODE_3
			return nil
		end
		return nil
	end

	# This function will get data from the API url
	# Params: 
	# Returns: response from API or error code
	def getFromAPI(url)
		header = getAuthHeader
		unless(header.nil?)
			response = self.class.get(url, :headers => header)
			if(response.code.eql? 200)
				return response
			else
				@error_code = ERROR_CODE_2 
				return nil
			end
		end
		return nil
	end

	
	# This function will convert url string to int. This is a general utility function that might be used elsewhere also
	# Params: 
	# Returns: int. used to return courseid
	def numberOrNil(string)
		num = string.to_i
		return num if num.to_s == string
	end	

end
