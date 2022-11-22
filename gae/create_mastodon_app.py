

from mastodon import Mastodon

# Register your app! This only needs to be done once.

# Mastodon.create_app(
#      'year_progress',
#      api_base_url = 'https://techhub.social',
#      to_file = 'pytooter_clientcred.secret'
# )


# Now, create user secret for logging in.

mastodon = Mastodon(
    client_id = 'pytooter_clientcred.secret',
    api_base_url = 'https://techhub.social'
)
mastodon.log_in(
    'EMAIL_ADDRESS',
    'PASSWORD',
    to_file = 'pytooter_usercred.secret'
)