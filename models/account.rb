class Account < FileStorage::Base
  belongs_to :user
end