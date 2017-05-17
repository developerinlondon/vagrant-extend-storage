require "log4r"

module VagrantPlugins
  module ExtendedStorage
    module Action
      class DetachStorage

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = env[:provider]
          @logger = Log4r::Logger.new('vagrant::extended_storage::action::detach_adapter')
        end

        def call(env)
          # skip if machine is not saved and the action is resume
          return @app.call(env) if @machine.state.id != :saved && env[:machine_action] == :resume

          return @app.call(env) unless env[:machine].config.extended_storage.enabled?
          @logger.info '** Detaching Extended Storage **'

          env[:ui].info I18n.t("vagrant_extended_storage.action.detach_storage")
          location = env[:machine].config.extended_storage.location
          env[:machine].provider.driver.detach_storage(location)

          @app.call(env)

        end

      end
    end
  end
end
