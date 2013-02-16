
FileStorage::SchemeBuilder.define do
  table :account do
    columns do
      integer :acc_int
      references :user
    end
    column :acc_str, :string
  end

  table :user do
    columns do
      integer :score
      float :balance
    end
    column :name, :string
  end
end
