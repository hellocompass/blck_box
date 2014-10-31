class SaveGroup

  def self.save(group, params)
    new(group).save params
  end

  def initialize(group)
    @group = group
  end

  def save(params)
    associate_users params.delete(:user_ids)
    update_attributes params

    @group.save
  end

  private

  def associate_users(user_ids)
    ids = user_ids.uniq
    @group.users = User.where(id: ids)
  end

  def update_attributes(params)
    accessibles = params.select { |k,v| Group.attribute_names.include? k.to_s }

    accessibles.each_pair do |k,v|
      @group.send("#{k}=", v)
    end
  end
end
