# Parent class to all controllers
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  APP_VERSION = Rails.configuration.app_version
end
