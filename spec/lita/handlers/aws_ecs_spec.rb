# rubocop:disable Style/FrozenStringLiteralComment
require 'spec_helper'

describe Lita::Handlers::AwsEcs, lita_handler: true do # rubocop:disable Metrics/BlockLength
  describe 'Routing' do
    it { is_expected.to route('ecs clusters') }
    it { is_expected.to route('ecs cluster services cluster_name') }
    it { is_expected.to route('ecs cluster tasks cluster_name') }
    it { is_expected.to route('ecs cluster service tasks cluster_name service_name') }
    it { is_expected.to route('ecs cluster service update_task cluster_name service_name task_name 1') }
  end

  describe 'Behavior' do # rubocop:disable Metrics/BlockLength
    let(:reply_message) {}

    subject { replies }
    shared_examples('a command that replies message') { it { is_expected.to include reply_message } }

    describe 'clusters command' do # rubocop:disable Metrics/BlockLength
      let(:ecs_response) {}

      before do
        allow_any_instance_of(Aws::ECS::Client)
          .to receive_message_chain(:list_clusters) { ecs_response }
        send_message 'ecs clusters'
      end

      context 'with empty clusters response' do
        let(:ecs_response) { [] }
        let(:reply_message) { "There are no clusters.\n" }

        it_behaves_like 'a command that replies message'
      end

      context 'with clusters response' do
        let(:ecs_response) do
          JSON.parse(
            { cluster_arns: ['/cluster_name'] }
            .to_json, object_class: OpenStruct
          )
        end
        let(:reply_message) do
          <<~MESSAGE
            --------------------------------------------------------
            name: cluster_name
            --------------------------------------------------------
          MESSAGE
        end

        it_behaves_like 'a command that replies message'
      end

      context 'when something raises error' do
        before do
          allow_any_instance_of(Aws::ECS::Client)
            .to receive_message_chain(:update_service).and_raise(StandardError)
        end

        let(:reply_message) { ':rage: Error has occurred' }
        it_behaves_like 'a command that replies message'
      end
    end

    describe 'cluster services command' do # rubocop:disable Metrics/BlockLength
      before do
        allow_any_instance_of(Aws::ECS::Client)
          .to receive_messages(list_services: services, describe_services: ecs_response)
        send_message 'ecs cluster services cluster_name'
      end

      context 'with empty cluster services response' do
        let(:services) {}
        let(:ecs_response) { [] }
        let(:reply_message) { "There are no services.\n" }

        it_behaves_like 'a command that replies message'
      end

      context 'with cluster services response' do
        let!(:services) do
          JSON.parse(
            { service_arns: ['/service_name'] }
              .to_json, object_class: OpenStruct
          )
        end
        let!(:ecs_response) do
          JSON.parse(
            { services: [{ task_definition: '/task_name' }] }
              .to_json, object_class: OpenStruct
          )
        end
        let(:reply_message) do
          <<~MESSAGE
            --------------------------------------------------------
            service_name:  service_name
            attached_task: task_name
            --------------------------------------------------------
          MESSAGE
        end

        it_behaves_like 'a command that replies message'
      end

      context 'when something raises error' do
        before do
          allow_any_instance_of(Aws::ECS::Client)
            .to receive_message_chain(:describe_services).and_raise(StandardError)
        end
        let(:services) { 'example' }
        let(:ecs_response) { 'example' }
        let(:reply_message) { ':rage: Error has occurred' }
        it_behaves_like 'a command that replies message'
      end
    end

    describe 'cluster tasks command' do # rubocop:disable Metrics/BlockLength
      before do
        allow_any_instance_of(Aws::ECS::Client)
          .to receive_message_chain(:list_tasks) { ecs_response }
        send_message 'ecs cluster tasks cluster'
      end

      context 'with empty cluster tasks response' do
        let(:ecs_response) { [] }
        let(:reply_message) { "There are no tasks.\n" }

        it_behaves_like 'a command that replies message'
      end

      context 'with cluster tasks response' do
        let(:ecs_response) do
          JSON.parse(
            { task_arns: ['/task_name'] }
            .to_json, object_class: OpenStruct
          )
        end
        let(:reply_message) do
          <<~MESSAGE
            --------------------------------------------------------
            name: task_name
            --------------------------------------------------------
          MESSAGE
        end

        it_behaves_like 'a command that replies message'
      end

      context 'when something raises error' do
        before do
          allow_any_instance_of(Aws::ECS::Client)
            .to receive_message_chain(:update_service).and_raise(StandardError)
        end

        let(:reply_message) { ':rage: Error has occurred' }
        it_behaves_like 'a command that replies message'
      end
    end

    describe 'cluster service tasks command' do # rubocop:disable Metrics/BlockLength
      before do
        allow_any_instance_of(Aws::ECS::Client)
          .to receive_message_chain(:describe_services) { ecs_response }
        send_message 'ecs cluster service tasks cluster service'
      end

      context 'with empty cluster service tasks response' do
        let(:ecs_response) {}
        let(:reply_message) { "There are no tasks.\n" }

        it_behaves_like 'a command that replies message'
      end

      context 'with cluster service tasks response' do
        let(:ecs_response) do
          JSON.parse(
            { services: [{ task_definition: '/task_name' }] }
            .to_json, object_class: OpenStruct
          )
        end
        let(:reply_message) do
          <<~MESSAGE
            --------------------------------------------------------
            name: task_name
            --------------------------------------------------------
          MESSAGE
        end

        it_behaves_like 'a command that replies message'
      end

      context 'when something raises error' do
        before do
          allow_any_instance_of(Aws::ECS::Client)
            .to receive_message_chain(:update_service).and_raise(StandardError)
        end

        let(:reply_message) { ':rage: Error has occurred' }
        it_behaves_like 'a command that replies message'
      end
    end

    describe 'clusters service update_task command' do
      before do
        allow_any_instance_of(Aws::ECS::Client)
          .to receive_message_chain(:update_service) { ecs_response }
        send_message 'ecs cluster service update_task cluster_name service_name task_name:1'
      end

      context 'with clusters service update response' do
        let(:ecs_response) do
          JSON.parse(
            { service: { service_name: 'service_name', cluster_arn: 'cluster_name', task_definition: 'task_name' } }
            .to_json, object_class: OpenStruct
          )
        end
        let(:reply_message) { 'Updated service_name task to task_name:1 successfully.' }
        it_behaves_like 'a command that replies message'
      end

      context 'when something raises error' do
        before do
          allow_any_instance_of(Aws::ECS::Client)
            .to receive_message_chain(:update_service).and_raise(StandardError)
        end

        let(:reply_message) { ':rage: Error has occurred' }
        it_behaves_like 'a command that replies message'
      end
    end
  end
end
# rubocop:enable Style/FrozenStringLiteralComment
