class HomeController < ApplicationController
  def index
	response = API.getCourses();
	@courses = JSON.parse(response.body)
	@links = parseLinks(response.headers['Link'])
  end
  def show
	response = API.getCourse(params[:id]);
  	@course = JSON.parse(response.body)
  end
  def page
	response = API.getCoursePage(params[:page], )
	
  end

end
