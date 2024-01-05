require 'spec_helper'

describe OmniAuth::Strategies::SlackOpenid do
  let(:user_name) { 'brent' }
  let(:user_email) { 'bront@slack-corp.com' }
  let(:raw_info) {
    {
      "ok" => true,
      "sub" => "U0R7JM",
      "https://slack.com/user_id" => "U0R7JM",
      "https://slack.com/team_id" => "T0R7GR",
      "email" => user_email,
      "email_verified" => true,
      "date_email_verified" => 1622128723,
      "name" => user_name,
      "picture" => "https://secure.gravatar.com/....png",
      "given_name" => "Bront",
      "family_name" => "Labradoodle",
      "locale" => "en-US",
      "https://slack.com/team_name" => "kraneflannel",
      "https://slack.com/team_domain" => "kraneflannel",
      "https://slack.com/user_image_24" => "...",
      "https://slack.com/user_image_32" => "...",
      "https://slack.com/user_image_48" => "...",
      "https://slack.com/user_image_72" => "...",
      "https://slack.com/user_image_192" => "...",
      "https://slack.com/user_image_512" => "...",
      "https://slack.com/team_image_34" => "...",
      "https://slack.com/team_image_44" => "...",
      "https://slack.com/team_image_68" => "...",
      "https://slack.com/team_image_88" => "...",
      "https://slack.com/team_image_102" => "...",
      "https://slack.com/team_image_132" => "...",
      "https://slack.com/team_image_230" => "...",
      "https://slack.com/team_image_default" => true
    }
  }
  let(:dummy_rack_app) { [200, {}, ['dummy']] }
  let(:options) { {} }

  subject(:strategy) { OmniAuth::Strategies::SlackOpenid.new(dummy_rack_app, options) }

  describe 'options' do
    subject { strategy.options }

    it { expect(subject.client_options.site).to eq('https://slack.com') }
    it { expect(subject.client_options.authorize_url).to eq('/openid/connect/authorize') }
    it { expect(subject.client_options.token_url).to eq('/api/openid.connect.token') }
  end

  describe '#info' do
    before do
      allow(strategy).to receive(:raw_info) { raw_info }
    end

    subject { strategy.info }

    it { expect(subject[:name]).to eq(user_name) }
    it { expect(subject[:email]).to eq(user_email) }
  end

  describe '#uid' do
    before do
      allow(strategy).to receive(:raw_info) { raw_info }
    end

    subject { strategy.uid }

    it { expect(subject).to eq('U0R7JM-T0R7GR') }
  end

  describe '#callback_url' do
    let(:base_url) { 'https://example.com' }

    context 'no script name present' do
      it 'has the correct default callback path' do
        allow(subject).to receive(:full_host) { base_url }
        allow(subject).to receive(:script_name) { '' }
        allow(subject).to receive(:query_string) { '' }
        expect(subject.callback_url).to eq(base_url + '/auth/slack_openid/callback')
      end
    end

    context 'script name' do
      it 'should set the callback path with script_name' do
        allow(subject).to receive(:full_host) { base_url }
        allow(subject).to receive(:script_name) { '/v1' }
        allow(subject).to receive(:query_string) { '' }
        expect(subject.callback_url).to eq(base_url + '/v1/auth/slack_openid/callback')
      end
    end
  end
end
