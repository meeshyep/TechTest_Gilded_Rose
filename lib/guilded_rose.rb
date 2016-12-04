require_relative 'item'

class GildedRose
  RATES = {"Aged Brie" => :aged_brie_rate,
    "Sulfuras, Hand of Ragnaros" => :sulfuras_rate,
    "Backstage passes to a TAFKAL80ETC concert" => :backstage_rate}

    def initialize(items)
      @items = items
    end

    def update_quality
      updated_items = seperate_items.each do |key, value|
        value.each do |item|
          rate = get_rate(item)
          update_item(item, rate)
        end
      end
      @items = updated_items.values.flatten
    end

    private

    def seperate_items
      @items.group_by(&:name)
    end

    def update_item(item, rate)
      item.sell_in -= rate[:sell_in]
      item.quality -= rate[:quality]
    end

    def aged_brie_rate(item)
      return { sell_in: 1, quality: 0 } if item.quality >= 50
      return { sell_in: 1, quality: -2 } if check_conjured(item)
      { sell_in: 1, quality: -1 }
    end

    def sulfuras_rate(item)
      { sell_in: 0, quality: 0 }
    end

    def backstage_rate(item)
      return { sell_in: 0, quality: item.quality } if check_backstage_expired(item)
      return { sell_in: 1, quality: check_backstage_rate(3, item.quality) } if check_backstage_prior(item)
      return { sell_in: 1, quality: check_backstage_rate(-(1 + 10/item.sell_in) * 2, item.quality )} if check_conjured(item)
      { sell_in: 1, quality:  check_backstage_rate(-(1 + 10/item.sell_in), item.quality) }
    end

    def other_rate(item)
      return { sell_in: 1, quality: 0 } if check_quality(item)
      return { sell_in: 0, quality: 2 } if check_sell_by(item)
      return { sell_in: 1, quality: 2 } if check_conjured(item)
      { sell_in: 1, quality: 1 }
    end

    def check_conjured(item)
      item.name =~ /\AConjured /
    end

    def check_backstage_expired(item)
      item.sell_in == 0 && item.quality > 0
    end

    def check_backstage_prior(item)
      item.sell_in == 1
    end

    def check_sell_by(item)
      item.sell_in <= 0
    end

    def check_quality(item)
      item.quality <= 0 || item.quality >= 50
    end

    def check_backstage_rate(rate, quality)
      (50 - quality) > rate.abs ? rate : (rate.abs - 50 - quality)
    end

    def get_method_rate(item)
      name = item.name.gsub(/\AConjured /,"")
      RATES.include?(name) ? RATES[name] : :other_rate
    end

    def get_rate(item)
      method = get_method_rate(item)
      self.send(method, item)
    end
    
end
