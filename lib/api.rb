#module Utility
  class API
	include HTTParty
	#URL to get token from
	base_uri 'canvas-api.herokuapp.com'
	format :json

	def self.getTokenFromAPI
		response = post("/api/v1/tokens")
		return response["token"]
	end

	def self.getToken
		unless Rails.cache.exist?('token')
			token = self.getTokenFromAPI()
			Rails.cache.write('token', token)	
		end
		token = Rails.cache.read('token');
		return token
	end

	def self.getAuthHeader
		token = self.getToken()
		val = "Token " << token
		return { "Authorization" => val}
	end

	def self.getCourses
		header = self.getAuthHeader()
		if(self.getToken())
			response = get(
				"/api/v1/courses",
				:headers => header
				);
			return response
		else
			puts "unable to get token"
		end
	end

	def self.getCourse(course_id)
		header = self.getAuthHeader()
		if(self.getToken())
			response = get(
				"/api/v1/courses/"+course_id,
				:headers => header
				);
			return response
		else
			puts "unable to get token"
		end
	end
  end


#puts API.getToken.inspect
#end
