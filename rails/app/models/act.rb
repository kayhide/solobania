class Act < ApplicationRecord
  belongs_to :user
  belongs_to :actable, polymorphic: true

  MARKS = %w(confident hesitant uncertain)
  enum mark: MARKS.map { |x| [x, x] }.to_h

  def parent
    @parent ||=
      begin
        refl =
          actable.class.reflect_on_all_associations(:belongs_to).find {|refl|
            refl.klass.reflect_on_association :acts
          }
        if refl
          parent_actable = actable.association(refl.name).load_target
          parent_actable.acts.first || parent_actable.acts.build(user: user)
        end
      end
    end
  end
end
