class User < FileStorage::Base
  has_one :account
end