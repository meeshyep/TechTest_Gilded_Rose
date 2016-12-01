require './lib/gilded_rose'

describe GildedRose do

  let(:aged_brie) {double :item, name: "Aged Brie"}
  let(:dexterity_vest) {double :item, name: "Dexterity Vest"}

  subject(:gilded_rose) {described_class.new([aged_brie, dexterity_vest, aged_brie])}

  it "seperates_items" do
    expect(gilded_rose.updated_items).to eq({"Aged Brie"=> [aged_brie, aged_brie], "Dexterity Vest"=>[dexterity_vest]})
  end


end
