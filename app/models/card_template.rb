# encoding: utf-8
class CardTemplate < ApplicationRecord
  attr_accessor :container

  # ENUM
  CATEGORY = {
    :Candidate => %w[uid name city phone description company title expert_level gj_rate mszq_rate],
    :ProjectTask => %w[uid seat interview_form pa start_time start_time_fwt end_time expert_level expert_uid expert_name
                       expert_mr_name expert_company expert_title expert_description expert_rate expert_unit_price expert_alias]
  }.stringify_keys
  CATEGORY_DESC = {
    :Candidate => '专家',
    :ProjectTask => '项目任务'
  }.stringify_keys

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_presence_of :name, :content
  # validates_uniqueness_of :name

  before_validation :setup, :on => :create

  # 插值标识符
  STAG = '{%'
  ETAG = '%}'

  def can_destroy?
    true
  end

  ## ====================================================
  # 输出插值结果
  def result(instance_id)
    klass = category.constantize
    @instance = klass.find(instance_id)

    @container = []                           # init container
    text_parser(content) do |field|
      if valid_field?(field)                  # only handle with valid fields
        @instance.card_template_params(field) # instance methods/instance variables of model
      else
        "{{ invalid param: #{field} }}"
      end
    end
    @container.join                           # output string
  end

  # 文本解析分割
  def text_parser(text, &block)
    m = text.match /(#{STAG}\s+\w+\s+#{ETAG})/  # {%[\s]keyword[\s]%}, \s is necessary
    if m.present?
      @container << m.pre_match
      m.to_s.match(/#{STAG}\s+(\w+)\s+#{ETAG}/)
      field = $1
      if block_given?
        @container << yield(field)
      else
        @container << m.to_s
      end
      text_parser(m.post_match, &block)
    else
      @container << text
    end
  end

  # 验证参数是否合法, 避免代码注入
  def valid_field?(field)
    CATEGORY[category].include?(field)
  end

  # 范例
  def self.example
    "{% expert_level %} \#{% uid %}\r\n【公司】{% company %}\r\n【职位】{% title %}\r\n【背景】{% description %}"
  end

  private
  def setup
    self.category ||= 'Candidate'
  end

end
