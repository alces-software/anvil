class OptionalLimitPaginator < JSONAPI::Paginator

  def initialize(params)
    @params = params
  end

  def apply(relation, order_options)
    return relation unless @params['limit'].to_i rescue false
    relation.limit(@params['limit'].to_i)
  end

end
