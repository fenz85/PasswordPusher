module ApplicationHelper
  # Set the HTML title for the page with a trailing site identifier.
  def title(content)
    content_for(:html_title) { "#{content} | #{_('SafePass')}" }
  end

  # Set the HTML title for the page _without_ the trailing site identifier.
  # Used in Password#show/show_expired to hide SafePass branding
  def plain_title(content)
    content_for(:html_title) { content }
  end
end
