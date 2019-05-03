# frozen_string_literal: true

module Mail
  module Notify
    module MailersController
      def self.included(klass)
        klass.class_eval do
          remove_method :find_part
        end
      end

      private

      def find_part(format)
        return @email.preview.html if notify?

        super
      end

      def notify?
        @email.delivery_method.class == Mail::Notify::DeliveryMethod
      end
    end
  end
end
