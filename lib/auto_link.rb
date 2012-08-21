def auto_link(text, *args, &block)#link = :all, html = {}, &block)
  return ''.html_safe if text.blank?

  options = args.size == 2 ? {} : args.extract_options! # this is necessary because the old auto_link API has a Hash as its last parameter
  unless args.empty?
    options[:link] = args[0] || :all
    options[:html] = args[1] || {}
  end
  options.reverse_merge!(:link => :all, :html => {})
  sanitize = (options[:sanitize] != false)
  sanitize_options = options[:sanitize_options] || {}
  text = conditional_sanitize(text, sanitize, sanitize_options).to_str
  case options[:link].to_sym
    when :all             then conditional_html_safe(auto_link_email_addresses(auto_link_urls(text, options[:html], options, &block), options[:html], &block), sanitize)
    when :email_addresses then conditional_html_safe(auto_link_email_addresses(text, options[:html], &block), sanitize)
    when :urls            then conditional_html_safe(auto_link_urls(text, options[:html], options, &block), sanitize)
  end
end

private

  AUTO_LINK_RE = %r{
      (?: ((?:ed2k|ftp|http|https|irc|mailto|news|gopher|nntp|telnet|webcal|xmpp|callto|feed|svn|urn|aim|rsync|tag|ssh|sftp|rtsp|afs):)// | www\. )
      [^\s<]+
    }x

  # regexps for determining context, used high-volume
  AUTO_LINK_CRE = [/<[^>]+$/, /^[^>]*>/, /<a\b.*?>/i, /<\/a>/i]

  AUTO_EMAIL_RE = /[\w.!#\$%+-]+@[\w-]+(?:\.[\w-]+)+/

  BRACKETS = { ']' => '[', ')' => '(', '}' => '{' }

  WORD_PATTERN = RUBY_VERSION < '1.9' ? '\w' : '\p{Word}'

  # Turns all urls into clickable links.  If a block is given, each url
  # is yielded and the result is used as the link text.
  def auto_link_urls(text, html_options = {}, options = {})
    link_attributes = html_options.stringify_keys
    text.gsub(AUTO_LINK_RE) do
      scheme, href = $1, $&
      punctuation = []

      if auto_linked?($`, $')
        # do not change string; URL is already linked
        href
      else
        # don't include trailing punctuation character as part of the URL
        while href.sub!(/[^#{WORD_PATTERN}\/-]$/, '')
          punctuation.push $&
          if opening = BRACKETS[punctuation.last] and href.scan(opening).size > href.scan(punctuation.last).size
            href << punctuation.pop
            break
          end
        end

        link_text = block_given?? yield(href) : href
        href = 'http://' + href unless scheme

        unless options[:sanitize] == false
          #link_text = sanitize(link_text)
          #href      = sanitize(href)
        end
        #content_tag(:a, link_text, link_attributes.merge('href' => href), !!options[:sanitize]) + punctuation.reverse.join('')
        "<a href=#{href} target='_blank'>#{link_text}</a>"
      end
    end
  end

  # Turns all email addresses into clickable links.  If a block is given,
  # each email is yielded and the result is used as the link text.
  def auto_link_email_addresses(text, html_options = {}, options = {})
    text.gsub(AUTO_EMAIL_RE) do
      text = $&

      if auto_linked?($`, $')
        text.html_safe
      else
        display_text = (block_given?) ? yield(text) : text

        unless options[:sanitize] == false
          text         = sanitize(text)
          display_text = sanitize(display_text) unless text == display_text
        end
        mail_to text, display_text, html_options
      end
    end
  end

  # Detects already linked context or position in the middle of a tag
  def auto_linked?(left, right)
    (left =~ AUTO_LINK_CRE[0] and right =~ AUTO_LINK_CRE[1]) or
      (left.rindex(AUTO_LINK_CRE[2]) and $' !~ AUTO_LINK_CRE[3])
  end

  def conditional_sanitize(target, condition, sanitize_options = {})
    #condition ? sanitize(target, sanitize_options) : target
    target
  end

  def conditional_html_safe(target, condition)
    condition ? target.html_safe : target
  end
