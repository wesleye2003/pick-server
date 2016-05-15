require 'soundcloud'
class UsersController < ApplicationController
	# def index
		
	# end

	def create 
		@user = User.new (params)
		if @user.save
			status 200
			render :json @user
		else
			status 400
		end
	end

	def show
		@user = User.find(params[:id])
		render :json
	end

	def by_zip
		@user = User.where(zipcode: params[:zip])
		render :json @users
	end

	def pickings
		@user =  User.find(params[:id])
		@pickings = @user.pickings
		render :json @pickings
	end
	# def callback
	# 	# create client object with app credentials
	# 	client = Soundcloud.new({:client_id => ENV['SOUNDCLOUD_CLIENT_ID'],
	# 				                  :client_secret => ENV['SOUNDCLOUD_CLIENT_SECRET'],
	# 	                        :redirect_uri => 'http://localhost:3000/callback',
	# 	                        :display => 'popup'})

	# 	# exchange authorization code for access token
	# 	code = params[:code]
	# 	if params[:error]
	# 		redirect_to "/"
	# 	else
	# 		access_token = client.exchange_token(:code => code)
	# 		sc_auth = Soundcloud.new(:access_token => access_token.access_token)
	# 		sc_user = sc_auth.get('/me')
	# 		user = User.find_or_initialize_by(username: sc_user.username,
	# 																			avatar_url: sc_user.avatar_url,
	# 																			permalink: sc_user.permalink_url,
	# 																			soundcloud_id: sc_user.id)
	# 		user.soundcloud_access_token = access_token.access_token
	# 		if user.save
	# 			session[:user_id] = user.soundcloud_access_token
	# 		end
	# 	end

	# end

end