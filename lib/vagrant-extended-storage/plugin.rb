require 'vagrant'

module VagrantPlugins
  module ExtendedStorage
    class Plugin < Vagrant.plugin('2')

      include Vagrant::Action::Builtin

      require_relative "action"
      require_relative "providers/virtualbox/driver/base"
      require_relative "providers/virtualbox/driver/meta"

      name "extended_storage"
      description <<-DESC
      This plugin provides config to extend the root storage
      DESC

      config "extended_storage" do
        require_relative "config"
        Config
      end

      ## NB Currently only works with Virtualbox provider, due to hooks being used
      action_hook(:extended_storage, :machine_action_up) do |hook|
        hook.after VagrantPlugins::ProviderVirtualBox::Action::SaneDefaults,
                  VagrantPlugins::ExtendedStorage::Action.create_adapter
        hook.before VagrantPlugins::ProviderVirtualBox::Action::Boot,
                  VagrantPlugins::ExtendedStorage::Action.create_storage
        hook.before VagrantPlugins::ProviderVirtualBox::Action::Boot,
                  VagrantPlugins::ExtendedStorage::Action.attach_storage
        hook.after VagrantPlugins::ProviderVirtualBox::Action::CheckGuestAdditions,
                  VagrantPlugins::ExtendedStorage::Action.manage_storage
        hook.after VagrantPlugins::ExtendedStorage::Action.attach_storage,
                  VagrantPlugins::ExtendedStorage::Action.manage_storage
      end

      action_hook(:extended_storage, :machine_action_destroy) do |hook|
        hook.after VagrantPlugins::ProviderVirtualBox::Action::action_halt,
                  VagrantPlugins::ExtendedStorage::Action.detach_storage
        hook.before VagrantPlugins::ProviderVirtualBox::Action::Destroy,
                  VagrantPlugins::ExtendedStorage::Action.detach_storage
      end

      action_hook(:extended_storage, :machine_action_halt) do |hook|
        hook.after VagrantPlugins::ProviderVirtualBox::Action::GracefulHalt,
                  VagrantPlugins::ExtendedStorage::Action.detach_storage
        hook.after VagrantPlugins::ProviderVirtualBox::Action::ForcedHalt,
                  VagrantPlugins::ExtendedStorage::Action.detach_storage
      end

      action_hook(:extended_storage, :machine_action_reload) do |hook|
        hook.after VagrantPlugins::ProviderVirtualBox::Action::GracefulHalt,
                  VagrantPlugins::ExtendedStorage::Action.detach_storage
        hook.after VagrantPlugins::ProviderVirtualBox::Action::ForcedHalt,
                  VagrantPlugins::ExtendedStorage::Action.detach_storage
        hook.before VagrantPlugins::ProviderVirtualBox::Action::Boot,
                  VagrantPlugins::ExtendedStorage::Action.attach_storage
      end

    end
  end
end
