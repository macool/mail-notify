# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rails::MailersController, type: :controller do
  render_views

  let(:notify) { double(:notify) }
  let(:preview) { double(Notifications::Client::TemplatePreview) }

  it 'gets the HTML preview' do
    expect(Notifications::Client).to receive(:new).with('some-api-key') { notify }
    expect(notify).to receive(:generate_template_preview).with(
      'template-id',
      personalisation: {
        body: "bar\r\n\\\r\n* This\r\n* Is\r\n* A\r\n* List",
        subject: 'Hello there!'
      }
    ) { preview }
    expect(preview).to receive(:html) { '<p>Some HTML</p>' }

    get :preview, params: { path: 'welcome/my_mail', part: 'text/plain' }

    expect(response.body).to eq('<p>Some HTML</p>')
  end
end
