class SnpCracklePop < Padrino::Application
  register Padrino::Mailer
  register Padrino::Helpers

  ##
  # Application configuration options
  #
  # set :raise_errors, true     # Show exceptions (default for development)
  # set :public, "foo/bar"      # Location for static assets (default root/public)
  # set :reload, false          # Reload application files (default in development)
  # set :default_builder, "foo" # Set a custom form builder (default 'StandardFormBuilder')
  # set :locale_path, "bar"     # Set path for I18n translations (defaults to app/locale/)
  # enable  :sessions           # Disabled by default
  disable :flash              # Disables rack-flash (enabled by default if sessions)
  # layout  :my_layout          # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
  #

  configure :development do
    # Uncomment next 2 lines to test error handling.
    #set :raise_errors, false
    #disable :show_exceptions
  end

  class << self

    # Overwrite Padrino's default errors.
    def default_errors!
      error NCBI::Document::NotFound do
        @exception = env['sinatra.error']
        haml :'shared/exception'
      end
    end

    def refetch_action(model_class)
      get :refetch, with: :id do
        object = model_class.find_by_ncbi_id(params[:id])
        object.refetch!
        redirect url(model_class.name.tableize.to_sym, :show, id: object.ncbi_id)
      end
    end

    def download_action(model_class)
      post :download do
        # Only supports 1 id per line, no commas.
        ids = params[:ids].split
        data = model_class.with_ncbi_ids(ids).to_csv
        file_name = "#{model_class.humanize.pluralize} #{Time.now}.csv"
        csv data, file_name
      end
    end

  end

  get '/' do
    haml :'home/index'
  end

  get :search do
    database = params[:database]
    term = params[:q]
    redirect url(database.to_sym, :search, q: term)
  end

end
