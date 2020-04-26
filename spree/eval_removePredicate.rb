# need to eval this under rails 

def benchmark_railsCode(n = 100)
    #variants = Spree::Variant.where(is_master: false)
    all_products = Spree::Product.all
    current_currency = 'USD'
    products = []
    for i in 0...n
        products << all_products.sample
    end
    Benchmark.bm do |x|
      x.report { for i in 0...n; products[i].variants.where(is_master: false).includes(:option_values).active(current_currency).select do |variant| 
        variant.option_values.any? 
      end; end }
      x.report { for i in 0...n; products[i].variants.where(is_master: false).includes(:option_values).active(current_currency).load; end }
    end
  end

  benchmark_railsCode(1000)