class User < ActiveRecord::Base
  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :zipcode, presence: true

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

    SOUNDCLOUD_CLIENT_ID='50e414afb9a9f00311445bd1b9990164'
    SOUNDCLOUD_CLIENT_SECRET="b599269690a3b1ce433c9fa3de01be74"

  def self.soundcloud_client(options={})
    options = {
      :client_id     => SOUNDCLOUD_CLIENT_ID,
      :client_secret => SOUNDCLOUD_CLIENT_SECRET,
    }.merge(options)

    Soundcloud.new(options)
  end

  def soundcloud_client(options={})
    options= {
      :expires_at    => soundcloud_expires_at,
      :access_token  => soundcloud_access_token,
      :refresh_token => soundcloud_refresh_token
    }.merge(options)

    client = self.class.soundcloud_client(options)

    # define a callback for successful token exchanges
    # this will make sure that new access_tokens are persisted once an existing
    # access_token expired and a new one was retrieved from the soundcloud api
    client.on_exchange_token do
      self.update_attributes!({
        :soundcloud_access_token  => client.access_token,
        :soundcloud_refresh_token => client.refresh_token,
        :soundcloud_expires_at    => client.expires_at,
      })
    end

    client
  end


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
