# Proxy allowed requests to backend services
class BackendProxy < Rack::Proxy
  # Rack-proxy method that can decide to pass request to Rails app or proxy to other host
  # Can use Rails application models for the decision
  def perform_request(env)
    request = Rack::Request.new(env)
    if request.path =~ /\.foo/
      env["HTTP_HOST"] = "bar"
      env["SERVER_PORT"] = 80
      super(env)
    else
      @app.call(env)
    end
  end

  # Rack-proxy method that allows adding response headers
  # Example: headers['X-Foo'] = "bar"
  def rewrite_response(triplet)
    status, headers, response = triplet
    # TODO: tbd.
    [status, headers, response]
  end

  protected

  # Adds headers to a request
  # Example (in #perform_request):
  #   add_headers(env, "x-foo" => "bar")
  # @param env Hash the Rack env variable for the request
  # @param headers Hash the headers to be added, key is header name, value is header value
  def add_headers(env, headers)
    return env unless headers.is_a?(Hash)
    headers.each do |name, value|
      env[headername_to_envkey(name.to_s)] = value
    end
    env
  end

  # Changes proxied request path with a regular expression replace
  # Example (in #perform_request):
  #   change_path(env, /^(.*)$/, '/foo/\1')  # adds /foo before all paths
  # @param env Hash the Rack env variable for the request
  # @param pattern Regexp regular expression to match on the request path
  # @param replacement String string to replace matches (can reference match groups from the pattern with \1, etc.)
  def change_path(env, pattern, replacement)
    orig_path = env["REQUEST_PATH"]
    new_path = orig_path.gsub(pattern, replacement).gsub(%r{/+}, "/")
    env["REQUEST_PATH"] = new_path
    env["REQUEST_URI"] = env["REQUEST_PATH"] + "?" + env["QUERY_STRING"]
    env["PATH_INFO"] = new_path
    env
  end

  # Converts header name to Rack env variable key
  # This means
  #   * prepend HTTP_
  #   * change - to _
  #   * convert to all uppercase
  def headername_to_envkey(headername)
    "HTTP_" + headername.tr("-", "_").upcase
  end
end
