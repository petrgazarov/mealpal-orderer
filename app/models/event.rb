class Event < ActiveRecord::Base
  validates :details, presence: true

  belongs_to :user
end
