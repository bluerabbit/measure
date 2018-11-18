RSpec.describe Measure do
  it 'has a version number' do
    expect(Measure::VERSION).not_to be nil
  end

  describe '#audit' do
    before do
      @measure = Measure.new(Redis::List.new('namespace'))
    end

    after do
      @measure.reset
    end

    it do
      @measure.audit('action1') { sleep 1 }
      @measure.audit('action1') { sleep 2 }

      rows = @measure.results
      expect(rows.size).to eq(1)

      row = rows.first
      expect(row[:action_name]).to eq('action1')
      expect(row[:count]).to eq(2)
      expect(row[:sum].to_i).to eq(3)
      expect(row[:min].to_i).to eq(1)
      expect(row[:max].to_i).to eq(2)
      expect(row[:avg].round(2)).to eq(1.5)
    end

    it do
      @measure.audit('action1') { sleep 1 }
      @measure.audit('action2') { sleep 1 }
      @measure.audit('action2') { sleep 1 }

      rows = @measure.results(sort_key: :sum)
      expect(rows.size).to eq(2)

      expect(rows[0][:action_name]).to eq('action2')
      expect(rows[0][:sum].to_i).to eq(2)

      expect(rows[1][:action_name]).to eq('action1')
      expect(rows[1][:sum].to_i).to eq(1)
    end
  end
end
