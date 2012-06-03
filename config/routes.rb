OpenYourProject::Application.routes.draw do

  resources :pages, :only => ENV['CREATE_PAGES'] ? %w[ new create index ] : %w[ index ]

  root :to => ENV['CREATE_PAGES'] ? 'pages#new' : 'pages#index'

end
