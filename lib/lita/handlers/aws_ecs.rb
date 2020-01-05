# frozen_string_literal: true

require 'aws-sdk-ecs'

module Lita
  module Handlers
    class AwsEcs < Handler
      config :aws_region
      config :aws_access_key_id
      config :aws_secret_access_key

      clusters_help = { 'ecs clusters' => 'List ecs clusters' }
      route(/ecs clusters$/, help: clusters_help) do |response|
        clusters = client.list_clusters
        response.reply(render_template('clusters', clusters: clusters))
      rescue StandardError => e
        response.reply ':rage: Error has occurred'
        response.reply e.to_s
      end

      cluster_services_help = { 'ecs cluster services ${cluster_name}' => 'List ecs cluster services' }
      route(/ecs cluster services\s+([a-zA-Z0-9 -~]+)\s*$/, help: cluster_services_help) do |response|
        cluster_name = response.matches.first[0]
        services = client.list_services(cluster: cluster_name)
          &.service_arns
          &.map { |service| [service, service_tasks(cluster_name, service)] }
          &.to_h || {}

        response.reply(render_template('cluster_services', cluster_name: cluster_name, services: services))
      rescue StandardError => e
        response.reply ':rage: Error has occurred'
        response.reply e.to_s
      end

      cluster_tasks_help = { 'ecs cluster tasks ${cluster_name}' => 'List ecs cluster tasks' }
      route(/ecs cluster tasks\s+([a-zA-Z0-9 -~]+)\s*$/, help: cluster_tasks_help) do |response|
        cluster_name = response.matches.first[0]
        cluster_tasks = client.list_tasks(
          cluster: cluster_name
        )
        response.reply(render_template('cluster_tasks', cluster_tasks: cluster_tasks))
      rescue StandardError => e
        response.reply ':rage: Error has occurred'
        response.reply e.to_s
      end

      cluster_service_tasks_help =
        { 'ecs cluster service tasks ${cluster_name} ${service_name}' => 'List ecs cluster service tasks' }
      route(/ecs cluster service tasks\s+([a-zA-Z0-9 -~]+)\s+([a-zA-Z0-9 -~]+)\s*$/,
            help: cluster_service_tasks_help) do |response|
        cluster_name = response.matches.first[0]
        service_name = response.matches.first[1]
        service_tasks = service_tasks(cluster_name, service_name)
        response.reply(render_template('service_tasks', service_tasks: service_tasks))
      rescue StandardError => e
        response.reply ':rage: Error has occurred'
        response.reply e.to_s
      end

      clusters_service_update_help =
        { 'ecs cluster service update_task ${cluster_name} ${service_name} ${task_name}' => 'Update ecs service' }
      route(/ecs cluster service update_task\s+([a-zA-Z0-9 -~]+)\s+([a-zA-Z0-9 -~]+)\s+([a-zA-Z0-9 -~]+)\s*$/,
            help: clusters_service_update_help) do |response|
        cluster_name = response.matches.first[0]
        service_name = response.matches.first[1]
        task_name = response.matches.first[2]
        client.update_service(
          cluster: cluster_name,
          service: service_name,
          task_definition: task_name
        )
        response.reply("Updated #{service_name} task to #{task_name} successfully.")
      rescue StandardError => e
        response.reply ':rage: Error has occurred'
        response.reply e.to_s
      end

      private def service_tasks(cluster_name, service_name)
        describe_services = client.describe_services(
          cluster: cluster_name,
          services: [service_name]
        )

        describe_services&.services&.map(&:task_definition) || []
      end

      private def client
        Aws::ECS::Client.new(
          region: config.aws_region || ENV['AWS_REGION'],
          access_key_id: config.aws_access_key_id || ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: config.aws_secret_access_key || ENV['AWS_SECRET_ACCESS_KEY']
        )
      end

      Lita.register_handler(self)
    end
  end
end
