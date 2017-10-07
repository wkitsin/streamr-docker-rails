class User < ApplicationRecord
	def self.from_omniauth(auth)
		where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
		user.provider = auth.provider
		user.uid = auth.uid
		user.name = auth.info.name
		user.email = auth.info.email
		user.image = auth.info.image
		user.oauth_token = auth.credentials.token
		user.oauth_refresh_token = auth.credentials.refresh_token
		user.oauth_expires_at = Time.at(auth.credentials.expires_at)
		user.save!
		@user = user
		end
	end

	# def update_token(auth_hash)
	# 	byebug
	# 		self.oauth_token = auth_hash["credentials"]["token"]
	# 		self.save
 # 	end

		def update_token
			
			byebug
		   response    = RestClient.post ENV['GOOGLE_TOKEN_URI'], :grant_type => 'refresh_token', :refresh_token => self.oauth_refresh_token, :client_id => ENV['GOOGLE_CLIENT_ID'], :client_secret => ENV['GOOGLE_CLIENT_SECRET']
		   refreshhash = JSON.parse(response.body)
		   self.oauth_token     = refreshhash['access_token']
		   self.oauth_expires_at = DateTime.now + refreshhash["expires_in"].to_i.seconds
		   self.save

		end
		#
		# def token_expired?
		#   expiry = Time.at(self.oauth_expires_at)
		#   return true if expiry < Time.now # expired token, so we should quickly return
		#   token_expires_at = expiry
		#   save if changed?
		#   false # token not expired. :D
		# end

end
