require "log4r"
require 'vagrant-extended-storage/manage_storage'

module VagrantPlugins
  module ExtendedStorage
    module Action
      class ManageAll

        include ManageStorage

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = @machine.provider_name
          @logger = Log4r::Logger.new('vagrant::extended_storage::action::manage_storage')
        end

        def call(env)
          # skip if machine is not running and the action is destroy, halt or suspend
          return @app.call(env) if @machine.state.id != :running && [:destroy, :halt, :suspend].include?(env[:machine_action])
          # skip if machine is not saved and the action is resume
          return @app.call(env) if @machine.state.id != :saved && env[:machine_action] == :resume
          # skip if machine is powered off and the action is resume
          return @app.call(env) if @machine.state.id == :poweroff && env[:machine_action] == :resume
          # skip if machine is powered off and the action is resume
          return @app.call(env) if @machine.state.id == :saved && env[:machine_action] == :resume
          
          return @app.call(env) unless env[:machine].config.extended_storage.enabled?
          return @app.call(env) unless env[:machine].config.extended_storage.manage?
          @logger.info '** Managing Extended Storage **'

          env[:ui].info I18n.t('vagrant_extended_storage.action.manage_storage')
          machine = env[:machine]
          manage_volumes(machine)

          @app.call(env)

        end

      end
    end
  end
end
