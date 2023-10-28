class Act < ApplicationRecord
  belongs_to :user
  belongs_to :actable, polymorphic: true
  belongs_to :pack, -> { where(acts: { actable_type: 'Pack' }) }, foreign_key: 'actable_id', required: false

  MARKS = %w(confident hesitant uncertain)
  enum mark: MARKS.map { |x| [x, x] }.to_h

  def parent
    @parent ||=
      begin
        refl =
          actable.class.reflect_on_all_associations(:belongs_to).find { |refl|
            refl.klass.reflect_on_association :acts
          }
        if refl
          parent_actable = actable.association(refl.name).load_target
          parent_actable.acts.first || parent_actable.acts.build(user: user)
        end
      end
  end

  def ensure_parent!
    if parent
      parent.created_at = [parent.created_at, created_at].compact.min
      parent.updated_at = [parent.updated_at, updated_at].compact.max
      parent.save!
      parent.ensure_parent!
    end
  end
end
