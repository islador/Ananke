Ananke::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  # Swapped from false to true to ensure sidekiq workers are loaded. May not be necessary when sidekiq is fully implemented.
  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  ActionMailer::Base.smtp_settings = {
    :address => "smtp.mandrillapp.com",
    :port => 587,
    :domain => "ananke.pw",
    :user_name => "luke.isla@gmail.com",
    :password => "hkLx52qKlEi7pNZDOOrrgQ",
    :authentication => "plain"
  }
  #Development settings for action mailer
  #ActionMailer::Base.smtp_settings = {
  #  :address    => "smtp.gmail.com",
  #  :port       => 587,
  #  :domain     => "gmail.com",
  #  :user_name  => "luke.isla@gmail.com",
  #  :password   => "xojmeyuftghcsbvo",
  #  :authentication => "plain",
  #  :enable_starttls_auto => true
  #}

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  #Config added for Devise
  #In production, :host should be set to the actual host of your application.
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
end
