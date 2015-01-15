class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :roles
  has_many :birds

  validates_uniqueness_of :email
  validates_presence_of :email, :first_name, :last_name

  scope :big_year_members, ->() { where(big_year: true) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.species_count
    User.sel
  end
end
