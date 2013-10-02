class AdministrationController < ApplicationController

	http_basic_authenticate_with :name => "Emilia", :password => "Uzunova"
end
