class Repeat < ActiveRecord::Base
  belongs_to :programs

  attr_protected :id

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  before_destroy :check_for_actives  #JBB need to test this.

  def check_for_actives
    if (Program.where('repeats = ?',self.id).count) > 0
      errors[:base] << "Programs are still associated with this repeat schedule, so it cannot be deleted"
      false
    end
  end
end
