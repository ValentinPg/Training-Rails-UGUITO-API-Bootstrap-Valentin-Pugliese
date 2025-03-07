ActiveAdmin.register Book do
  filter :title
  filter :author
  filter :genre
  filter :utility

  permit_params :utility_id, :genre, :author, :image, :title, :publisher, :year

  index do
    selectable_column
    id_column
    column :title
    column :author
    column :genre
    actions
  end

  form do |f|
    f.inputs 'Book details', allow_destroy: true do
      f.semantic_errors(*f.object.errors.keys)
      f.input :title
      f.input :author
      f.input :genre
      f.input :publisher
      f.input :year
      f.input :image, as: :url
      f.input :utility
      f.input :user, as: :select, collection: User.pluck(:email)
      f.actions
    end
  end
end
