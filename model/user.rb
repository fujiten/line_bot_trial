class User < ActiveRecord::Base
end

get '/users' do
  user = User.find(1)
  user.name
end

get '/users/create' do
  user = User.new(name: 'test1')
  user.save
end
