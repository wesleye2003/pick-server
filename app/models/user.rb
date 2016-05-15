class User < ActiveRecord::Base
  has_secure_password

  has_many  :genre_selections
  has_many  :genres, through: :genre_selections
  has_many  :artist_roles
  has_many  :roles, through: :artist_roles

  has_many  :received_pickings, class_name: "Picking", foreign_key: :receiver_id
  has_many  :sent_pickings, class_name: "Picking", foreign_key: :sender_id

  has_many  :requested_picks, through: :sent_pickings, source: :receiver
  has_many  :pick_requests, through: :received_pickings, source: :sender

  has_many  :searched_roles
  has_many  :s_roles, through: :searched_roles, source: :role

  def pickings
    pickings = []
    Picking.where(sender: self, status: true).each do |pic|
      pickings << pic.receiver
    end
    Picking.where(receiver: self, status: true).each do |pic|
      pickings << pic.sender
    end
    pickings.uniq
  end

  def pending_picks
    pickings = []
    self.sent_pickings.where(status: false).each do |pic|
      pickings << pic.receiver
    end
    self.received_pickings.where(status: false).each do |pic|
      pickings << pic.sender
    end
    pickings.uniq
  end

  def sent_requests
    requests = []
    Picking.where(receiver: self).find_each do |pic|
      requests << pic.sender
    end
    requests
  end

  def approve_picking(other_user)
    p = self.sent_pickings.find_by(receiver_id: other_user.id)
    q = self.received_pickings.find_by(sender_id: other_user.id)
    if p
      p.status = true
      p.save
    end
    if q
      q.status = true
      q.save
    end
  end

  def request(receiver)
    Picking.create(sender_id: self.id, receiver_id: receiver.id, status: false)
  end

  def is_picking?(user)
    Picking.where(sender: self, status: true).find_each do |pic|
      return true if pic.receiver === user
    end
    false
  end

  def destroy_data
    self.received_relationships.destroy_all
    self.sent_relationships.destroy_all
  end
end
