Rails.application.routes.draw do
  scope defaults: { format: :json } do
    devise_for :users,
                path: '',
                controllers: { sessions: 'users/sessions',
                               registrations: 'users/registrations',
                               passwords: 'users/passwords' }
      resources :books do
        resources :copies, shallow: true do
          member do
            patch :read_book
            patch :put_it_back
          end
        end
      end

      resource :reader, :only => :show do
        collection do # copy_id=1
          patch :return_it
          patch :take_reserved
          patch :borrow
        end
      end

      resource :librarian, :only => :show do
        collection do # copy_id=1
          patch :get_lent_book
          patch :lend_this_book # copy_id=1&reader_id=1
        end
      end
  end
end
