# Parent class to ActiveRecord models
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
