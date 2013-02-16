# General functionaluty

class Object
  def test
    # account = Account.new name: "max", age: 23, balance: 100.1
    # user = User.new name: "max", age: 23, balance: 100.1
    # user.account = account
    # user.save

    account = Account.new name: "max", age: 23, balance: 100.1
    user = User.new name: "max", age: 23, balance: 100.1
    account.user = user
    account.save

    User.where(id: 340).first
    User.order(:id).all
    User.order('id').all
    User.order('id desc').all
    User.order('id asc, name desc').all
    User.select(:id).all
    User.select('id').all
    User.select('id, name').all
    # p User.find_by_name "bob"
    # user.hobbys
    # user.hibbys.create title: "football"
    nil
  end
end

