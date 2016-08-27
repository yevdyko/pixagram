class User < ApplicationRecord
  acts_as_voter

  validates :username, presence: true, length: { minimum: 3, maximum: 12 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_attached_file :avatar, styles: { medium: '152x152#' }
  validates_attachment_content_type :avatar, content_type: %r{\Aimage\/.*\Z}
end
