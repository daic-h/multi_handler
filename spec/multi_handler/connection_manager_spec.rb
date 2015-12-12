require "spec_helper"

RSpec.describe MultiHandler::ConnectionManager do
  let(:manager) { ActiveRecord::Base.connection_manager }

  describe "#connection_name_for" do
    subject { manager.connection_name_for(ActiveRecord::Base.connection_handler) }

    it "should return master" do
      is_expected.to eq :master
    end

    it "when current connection was master, should return master" do
      manager.on_db(:master) do
        expect(subject).to eq :master
      end
    end

    it "when current connection was shard_1, should return shard_1" do
      manager.on_db(:shard_1) do
        expect(subject).to eq :shard_1
      end
    end
  end

  describe "#on_db" do
    it "when using master, should use the master connection" do
      manager.on_db(:master) do
        expect(ActiveRecord::Base.connection_config[:database]).to eq "multi_handler_test"
      end
    end

    it "when using shard_1, should use the shard_1 connection" do
      manager.on_db(:shard_1) do
        expect(ActiveRecord::Base.connection_config[:database]).to eq "multi_handler_shard_1_test"
      end
    end

    it "when using shard_3(nested). should use the shard_3 connection" do
      manager.on_db(:shard_2) do
        manager.on_db(:shard_3) do
          expect(ActiveRecord::Base.connection_config[:database]).to eq "multi_handler_shard_3_test"
        end
      end
    end
  end

  describe "#on_each_db" do
    it "should" do
      database = []
      manager.on_each_db do
        database << ActiveRecord::Base.connection_config[:database]
      end

      expect(database).to eq %w(multi_handler_test multi_handler_shard_1_test multi_handler_shard_2_test multi_handler_shard_3_test
                                multi_handler_shard_4_test multi_handler_shard_5_test multi_handler_shard_6_test)
    end
  end

  describe "#establish_connection" do
    subject { manager.establish_connection(shard, spec) }

    let(:manager) do
      described_class.new(ActiveRecord::Base.default_connection_handler)
    end

    let(:shard) do
      "shard_1"
    end

    let(:spec) do
      ActiveRecord::Base.configurations["test"]["connections"][shard]
    end

    it "should " do
      expect { subject }.to change { manager.instance_variable_get(:@handlers) }.to(
        include(shard => kind_of(ActiveRecord::ConnectionAdapters::ConnectionHandler)))
    end
  end
end
