Rails.application.routes.draw do
  devise_for :users, defaults: { format: :json }, controllers: { sessions: 'users' }
  resources :books do
    resources :copies
  end

  resource :reader, :only => :show do
    member do
      get :tickets
      patch :borrow
      patch :read
      patch :take_reserved
      patch :return_it
    end
  end

  resource :librarian, :only => :show do
    collection do
      patch :get_lent_book
      patch :lend_this_book # copy_id=1&reader_id=1
    end
  end
end
