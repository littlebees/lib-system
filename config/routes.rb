Rails.application.routes.draw do
  get 'librarians/get_lent_book'
  get 'librarians/lent_this_book'
  get 'librarians/show'
  get 'readers/show'
  get 'users/login'
  get 'users/logout'
  #devise_for :users
  post '/login' => 'users#login'
  get '/logout' => 'users#logout'

  resources :books do
    resources :copies do
      member do
        patch :read
        patch :reserve
        patch :borrow
      end
    end
  end

  resource :reader, :only => :show do
    resources :copies, :only => [:show, :index] do
      member do
        patch :take_reserved
        patch :return_it
      end
    end
  end

  resource :librarian, :only => :show do
    collection do
      patch :get_lent_book
      patch :lent_this_book
    end
  end
end
