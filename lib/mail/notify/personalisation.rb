# frozen_string_literal: true

module Mail
  module Notify
    class Personalisation
      def initialize(mail)
        @body = mail.body.raw_source
        @subject = mail.subject
        @personalisation = if mail[:personalisation].present?
                             mail[:personalisation].unparsed_value || {}
                           else
                             {}
                           end
      end

      def to_h
        merged_options.reject { |_k, v| v.blank? }
      end

      private

      def merged_options
        {
          body: @body,
          subject: @subject
        }.merge(@personalisation)
      end
    end
  end
end
