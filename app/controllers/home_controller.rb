# Controller for the DAHLIA homepage.
class HomeController < ApplicationController
  protected

  def use_react_app
    ENV['HOME_PAGE_REACT'].to_s.casecmp('true').zero?
  end
end
