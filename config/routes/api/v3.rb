namespace :v3 do
  resources :foot_notes, only: :show

  resources :chapters, only: [:index, :show] do
    member do
      get :info, to: 'chapter_infos#show'
    end

    resources :verses, only: [:index, :show] do
      resources :audio_files, only: [:index]
    end
  end

  resources :juzs, only: [:show, :index]
  resources :pages, only: [:show]

  namespace :options do
    get :default
    get :translations
    get :recitations
    get :tafsirs
    get :languages
    get :media_content
    get :chapter_info
  end

  get 'search', to: 'search#index'
  get 'suggest', to: 'suggest#index'
end