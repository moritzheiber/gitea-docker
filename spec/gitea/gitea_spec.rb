require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'gitea Docker container' do
  set :os, family: :alpine
  set :backend, :docker
  set :docker_container, 'gitea'

  before(:all) do
    @c = Docker::Compose.new
    @c.up('gitea', detached: true)
  end

  after(:all) do
    @c.kill
    @c.rm(force: true)
  end

  %w[
    curl
    bash
    openssh
    tzdata
    git
    sqlite
  ].each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe user('gitea') do
    it { should exist }
    it { should have_login_shell '/bin/bash' }
  end

  describe process('gitea') do
    it { should be_running }
    its(:user) { should eq 'gitea' }
    its(:args) { should match(/web/) }
  end

  describe process('consul-template') do
    it { should be_running }
    its(:user) { should eq 'gitea' }
  end

  describe 'the web interface' do
    it 'should be running on port 8080' do
      wait_for(port(8080)).to be_listening.with('tcp')
    end
  end
end
