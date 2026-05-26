class LockRole < ApplicationRecord

  serialize :phases, JSON
  serialize :modules, JSON
  
  validates :user_id, :name, :company_id, presence: true

  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :company, class_name: 'Pms::CompanySetup'
  has_many :lock_user_permissions

  validates_uniqueness_of :name, :scope => :company_id
  # validates_with PermissionValidator

  default_scope ->{ where(role_for: 'pms') }

  after_update :update_lock_user_permission

  def pms_role
    JSON.parse(permissions_hash)["pms"]["role"]
  end

  def manageable_ids
    JSON.parse(JSON.parse(permissions_hash)["pms"]["manageable_id"])
  end

  def has_section? section_name
    hash         =  role_hash
    section_name =  section_name.to_slug_param(sep: '_')
    return true  if hash[section_name]

    false
  end
  

  def has? section_name, rule_name
    hash         =  role_hash
    section_name =  section_name.to_slug_param(sep: '_')
    rule_name    =  rule_name.to_slug_param(sep: '_')

    return true  if hash.try(:[], 'system').try(:[], 'administrator')
    return true  if hash.try(:[], 'moderator').try(:[], section_name)

    return false unless hash[section_name]
    return false unless hash[section_name].key? rule_name

    # return true if hash[section_name][:all] == true
    return true if hash[section_name][rule_name] == true || hash[section_name][rule_name] == "true"
    return false
    # hash[section_name][rule_name]
  end

  def update_lock_user_permission
    LockUserPermission.unscoped.where(lock_role_id: self.id).each do |lup|
      per_hash = self.permissions_hash == "null" ? JSON.parse("{}") : JSON.parse(self.permissions_hash)
      lup.update_columns(
        permissions_hash: lup.user.try(:user_type) == 'pms_admin' ? per_hash.merge(spree_society_admin: {index: true}).to_json : per_hash.to_json,
      )
    end
  end

  def any_role? roles_hash = {}
    roles_hash.each_pair do |section, rules|
      return false unless[ Array, String, Symbol ].include?(rules.class)
      return has_role?(section, rules) if [ String, Symbol ].include?(rules.class)
      rules.each{ |rule| return true if has_role?(section, rule) }
    end

    false
  end

  def moderator? section_name
    section_name = section_name.to_slug_param(sep: '_')
    has_role? section_name, 'any_crazy_name'
  end

  def admin?
    has_role? 'any_crazy_name', 'any_crazy_name'
	end

  def role_hash
    to_hash
  end

  def the_role= val
    self[:the_role] = _jsonable val
  end

  def _jsonable val
    val.is_a?(Hash) ? val.to_json : val.to_s
  end

  def to_hash
    begin JSON.load(permissions_hash) || {} rescue {} end
  end

  def to_json
    the_role
	end

  def create_section section_name = nil
    return false unless section_name

    role         = to_hash
    section_name = section_name.to_slug_param(sep: '_')

    return false if section_name.blank?
    return true  if role[section_name]

    role[section_name] = {}
    update_attribute(:the_role, _jsonable(role))
  end

  def create_rule section_name, rule_name
    return false if     rule_name.blank?
    return false unless create_section(section_name)

    role         = to_hash
    rule_name    = rule_name.to_slug_param(sep: '_')
    section_name = section_name.to_slug_param(sep: '_')

    return true if role[section_name][rule_name]

    role[section_name][rule_name] = false
    update_attribute(:the_role,  _jsonable(role))
  end

  # U

  # source_hash will be reset to false
  # except true items from new_role_hash
  # all keys will become 'strings'
  # look at lib/the_role/hash.rb to find definition of *underscorify_keys* method
  def update_role new_role_hash
    new_role_hash = new_role_hash.try(:to_hash) || {}

    new_role = new_role_hash.underscorify_keys
    role     = to_hash.underscorify_keys.deep_reset(false)

    role.deep_merge! new_role
    update_attribute(:the_role,  _jsonable(role))
  end

  def rule_on section_name, rule_name
    role         = to_hash
    rule_name    = rule_name.to_slug_param(sep: '_')
    section_name = section_name.to_slug_param(sep: '_')

    return false unless role[section_name]
    return false unless role[section_name].key? rule_name
    return true  if     role[section_name][rule_name]

    role[section_name][rule_name] = true
    update_attribute(:the_role,  _jsonable(role))
  end

  def rule_off section_name, rule_name
    role         = to_hash
    rule_name    = rule_name.to_slug_param(sep: '_')
    section_name = section_name.to_slug_param(sep: '_')

    return false unless role[section_name]
    return false unless role[section_name].key? rule_name
    return true  unless role[section_name][rule_name]

    role[section_name][rule_name] = false
    update_attribute(:the_role,  _jsonable(role))
  end

  # D

  def delete_section section_name = nil
    return false unless section_name

    role = to_hash
    section_name = section_name.to_slug_param(sep: '_')

    return false if section_name.blank?
    return false unless role[section_name]

    role.delete section_name
    update_attribute(:the_role,  _jsonable(role))
  end

  def delete_rule section_name, rule_name
    role         = to_hash
    rule_name    = rule_name.to_slug_param(sep: '_')
    section_name = section_name.to_slug_param(sep: '_')

    return false unless role[section_name]
    return false unless role[section_name].key? rule_name

    role[section_name].delete rule_name
    update_attribute(:the_role,  _jsonable(role))
	end



end
