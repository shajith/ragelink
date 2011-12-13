#To generate code: ragel -o lib/zendesk_text/ragel/generated/url.rb -R -F1 lib/zendesk_text/ragel/url.rl
class Ragelink::Machine
    %%{
      machine autolink;
      alphtype int;

      include WChar "../../ragel/unicode.rl";

      include "../../ragel/url_productions.rl";

      main := |*
        start_email => {
          in_email = true
          #puts "Start email"
          output << data[ts..te-1]
        };

        end_email => {
          in_email = false
          output << data[ts..te-1]
        };

        start_anchor => {
                        in_anchor = true
                        output << data[ts..te-1]
                        };

        end_anchor => {
                      in_anchor = false
                      output << data[ts..te-1]
                      };

        start_img => {
                        in_img = true
                        output << data[ts..te-1]
                        };

        end_img => {
                      in_img = false
                      output << data[ts..te-1]
                      };

        start_object => {
                        in_object = true
                        output << data[ts..te-1]
                        };

        end_object => {
                      in_object = false
                      output << data[ts..te-1]
                      };


        url => {
                if (mode == :urls) && !(in_email || in_anchor || in_img || in_object)
                  url = data[ts..te-1]

                  link = if block_given?
                           yield(url)
                         else
                           link_text = url
                           url = "http://" + url unless url.index('http') == 0
                           make_url(url, link_text)
                         end
                  output << link
                else
                  output << data[ts..te-1]
                end
               };

        email => {
              if (mode == :emails) && !in_anchor
                email = data[ts..te-1]
                mailto = if block_given?
                           yield(email)
                         else
                           make_url("mailto:#{email}", email)
                         end
                output << mailto
              else
                output << data[ts..te-1]
              end

        };

        any => { output << data[ts..te-1] };
      *|;
    }%%

    %% write data;

    def self.run_machine(data, mode)
      output = ""
      eof = data.length
      cur = 0
      ts = 0

      %% write init;
      %% write exec;

      output
    end

    def self.make_url(url, link_text)
      "<a href=\"#{url}\">#{link_text}</a>"
    end

end
