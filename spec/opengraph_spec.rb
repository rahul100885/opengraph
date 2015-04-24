require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe OpenGraph do
  let(:rotten){ File.open(File.dirname(__FILE__) + '/examples/rottentomatoes.html').read }
  let(:partial){ File.open(File.dirname(__FILE__) + '/examples/partial.html').read }
  
  describe '.parse' do
    it 'returns false if there isnt valid Open Graph info' do
      expect(OpenGraph.parse("")).to be_falsey
      expect(OpenGraph.parse(partial)).to be_falsey
    end
    
    it 'otherwise returns an OpenGraph::Object' do
      expect(OpenGraph.parse(rotten)).to be_kind_of(OpenGraph::Object)
    end

    context 'without strict mode' do
      subject{ OpenGraph.parse(partial, false) }

      it 'returns an OpenGraph::Object if there is any twitter cards data even invalid' do    
        expect(subject).not_to be_false
        expect(subject.title).to eq 'Partialized'
      end

      it 'returns false if there isnt any Open Graph info' do
        expect(OpenGraph.parse("")).to be_falsey
      end
      
    end
  end
  
  describe '.fetch' do
    it 'fetches from the specified URL' do
      stub_request(:get, 'http://www.rottentomatoes.com/m/1217700-kick_ass/').to_return(:body => rotten)
      expect(OpenGraph.fetch('http://www.rottentomatoes.com/m/1217700-kick_ass/').title).to eq 'Kick-Ass'
      expect(WebMock).to have_requested(:get, 'http://www.rottentomatoes.com/m/1217700-kick_ass/')
    end
    
    it 'catches errors' do
      stub_request(:get, 'http://example.com').to_return(:status => 404)
      expect(OpenGraph.fetch('http://example.com')).to be_falsey
      expect(RestClient).to receive(:get).with('http://example.com').and_raise(SocketError)
      expect(OpenGraph.fetch('http://example.com')).to be_falsey
    end
  end
end

describe OpenGraph::Object do
  let(:rotten){ File.open(File.dirname(__FILE__) + '/examples/rottentomatoes.html') }
  
  context ' a Rotten Tomatoes Movie' do
    subject{ OpenGraph.parse(rotten) }
    
    it 'should have the title' do
      expect(subject.title).to eq "Kick-Ass"
    end
    
    it 'should be a product' do
      expect(subject.schema).to eq 'product'
      expect(subject).to be_product
      expect(subject).not_to be_person
    end
    
    it 'should be a movie' do
      expect(subject.type).to eq 'movie'
      expect(subject).to be_movie
      expect(subject).not_to be_tv_show
    end
    
    it 'should be valid' do
      expect(subject).to be_valid
      
      subject['type'] = nil
      expect(subject).not_to be_valid
    end
  end
end
