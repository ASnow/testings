

Библиотека для эмитации ActiveRecord при работе с фаиловыми хранилищами.

Тестовое приложение
======
Для запуска тестового приложения наберите:
```
bundle install
bundle exec irb
```
Файловая структура библиотеки
======

Описание структуры данных хранится в:
```
FileStorage::Config["scheme_file"] = Dir.pwd + '/db/scheme/scheme.rb'
```
Сами данные хранятся в:
```
FileStorage::Config["db_folder"] = Dir.pwd + '/db/data'
FileStorage::Config["db_records_folder"] = FileStorage::Config["db_folder"] + '/records'
```
Переменные таблиц хранятся в:
```
FileStorage::Config["db_table_states_folder"] = FileStorage::Config["db_folder"] + '/last_ids'
```
Модели описывающие бизнес логику необходимо создавать в:
```
FileStorage::Config["models_folder"] = "./models"
```

Описание структур данных
======
Перед работой с библиотекой тербуется описать все структуры данных которые будут использоваться в файле схемы. Пример описаниея:
```ruby
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
```

В описании доступны следующие типы данных:
* primary - основной ключ, исползется integer с автоинкрементом, сложные ключи не поддерживаются пока, по умолчанию для таблицы создается id
* integer
* references
* string
* float
* date
* datetime

Модели
======

Описание модели
Модели должны наследоваться от класса [FileStorage::Base].
В модели могут быть определены связи [has_one] и [belongs_to]. Для связей автоматически определяются методы доступа.
В модели автоматически создаются методы доступа к атрибутам. Методы доступа могут быть переопредеены.
Значения аттрибутов хранятся в переменной экземпляра [@attributes].
Пример описания модели:
```ruby
class User < FileStorage::Base
  has_one :account

  def name= value
    @attributes["name"] = value.split(' ').first
  end
end
```

Прмер использования связей
```ruby
account = Account.new name: "max", age: 23, balance: 100.1
user = User.new name: "max", age: 23, balance: 100.1
account.user = user
account.save
```


При работе с моделями доступны методы класса:
* **where** - выборка данных по условиям, поддерживает только and условия, принимает в качестве рагумента хеш
* **order** - сортурует данные, принимает в качестве аргументов символ или строку. Например: 'id asc, name desc', :id
* **select** - определяет каке колонки выбирать, принимает в качестве аргументов символ или строку. Например: :id, 'id, name'
* **limit** - определет максимальное количество выбираемых записей, параметр только Integer
* **offset** - определяет смещение, параметр только Integer
* **first** - выбирает первую запись
* **all** - выбирает все записи
* **last** - выбирает последнюю запись

Пример запроса:
```ruby
User.where(name: 'max').order('id desc').limit(3).all
```

Зависимости/DEPENDENCIES
======

Для работы библиотеки требуются гемы:
* ActiveSupport
* I18n
