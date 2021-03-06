require "log4r"

module VagrantPlugins
  module ExtendedStorage
    module Action
      class CreateAdapter

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = env[:provider]
          @logger = Log4r::Logger.new('vagrant::extended_storage::action::create_adapter')
        end

        def call(env)
          # skip if machine is not running and the action is destroy, halt or suspend
          return @app.call(env) if @machine.state.id != :running && [:destroy, :halt, :suspend].include?(env[:machine_action])
          # skip if machine is not saved and the action is resume
          return @app.call(env) if @machine.state.id != :saved && env[:machine_action] == :resume
          # skip if machine is powered off and the action is resume or up
          return @app.call(env) if @machine.state.id == :poweroff && [:resume, :up].include?(env[:machine_action])
          # skip if machine is saved
          return @app.call(env) if @machine.state.id == :saved

          return @app.call(env) unless env[:machine].config.extended_storage.enabled?
          @logger.info '** Creating Extended Storage Adapter **'

          env[:ui].info I18n.t("vagrant_extended_storage.action.create_adapter")
          env[:machine].provider.driver.create_adapter

          @app.call(env)

       end

      end
    end
  end
end
