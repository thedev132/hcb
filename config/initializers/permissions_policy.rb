# Define an application-wide HTTP permissions policy. For further
# information see https://developers.google.com/web/updates/2018/06/feature-policy
#

# @msw: We conservatively restrict features across the app to provide a secure
# default– individual controllers can opt-in to permissions like this:
# https://api.rubyonrails.org/v6.1.0/classes/ActionController/PermissionsPolicy.html

Rails.application.config.permissions_policy do |f|
  f.camera      :none
  f.gyroscope   :none
  f.microphone  :none
  f.usb         :none
  f.geolocation :none
  f.fullscreen  :none
  f.payment     :none
end
