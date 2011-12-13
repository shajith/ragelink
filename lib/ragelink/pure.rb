require 'ragelink/pure/generated/url'

module Ragelink::Pure
  def autolink_ragel_urls(str, &blk)
    Ragelink::Machine.run_machine(str, :urls, &blk)
  end

  def autolink_ragel_emails(str, &blk)
    Ragelink::Machine.run_machine(str, :emails, &blk)
  end
end
