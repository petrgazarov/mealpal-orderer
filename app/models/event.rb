class Event < ActiveRecord::Base
  validates :details, presence: true
end
