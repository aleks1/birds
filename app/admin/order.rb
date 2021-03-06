ActiveAdmin.register Categories::Order do
  permit_params :name_ru, :name_en, :name_lat, :name_uz, :description, :image, :position

  menu priority: 1

  filter :name_ru
  filter :name_lat
  filter :name_en

  index do
    column :id
    column :position
    column :name_ru
    column :name_lat
    column :name_en
    actions
  end

  show do |order|
    attributes_table do
      row :id
      row :position
      row :name_ru
      row :name_lat
      row :name_en
      row :name_uz
      row :description
      row :children do # TODO: check it
        order.families.each do |family|
          link_to family.parent.full_name, admin_categories_family_path(family.id)
        end
      end
      row :image do
        div do
          image_tag(order.image.url)
        end
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :position
      f.input :name_ru
      f.input :name_lat
      f.input :name_en
      f.input :name_uz
      f.input :description
    end
    f.inputs do
      f.input :image, :hint => f.template.image_tag(f.object.image.url)
    end

    f.actions
  end
end
