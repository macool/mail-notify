# frozen_string_literal: true

module Mail
  module Notify
    module MailersController
      def self.included(klass)
        klass.class_eval do
          remove_method :find_part, :preview
        end
      end

      def preview
        if params[:path] == @preview.preview_name
          @page_title = "Mailer Previews for #{@preview.preview_name}"
          render action: "mailer"
        else
          @email_action = File.basename(params[:path])

          if @preview.email_exists?(@email_action)
            @email = @preview.call(@email_action, params)

            if params[:part]
              @part_type = Mime::Type.lookup(params[:part])

              if part = find_part(@part_type)
                response.content_type = content_type
                render plain: part.respond_to?(:decoded) ? part.decoded : part
              else
                raise AbstractController::ActionNotFound, "Email part '#{part_type}' not found in #{@preview.name}##{@email_action}"
              end
            else
              @part = find_preferred_part(request.format, Mime[:html], Mime[:text])
              render action: "email", layout: false, formats: [:html]
            end
          else
            raise AbstractController::ActionNotFound, "Email '#{@email_action}' not found in #{@preview.name}"
          end
        end
      end

      private

      def find_part(format)
        if notify?
          @email.preview.html.html_safe
        elsif part = @email.find_first_mime_type(format)
          part
        elsif @email.mime_type == format
          @email
        end
      end

      def notify?
        @email.delivery_method.class == Mail::Notify::DeliveryMethod
      end

      def content_type
        notify? ? Mime::Type.lookup('text/html') : @part_type
      end
    end
  end
end
