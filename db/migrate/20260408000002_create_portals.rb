class CreatePortals < ActiveRecord::Migration[5.2]
  def change
    create_table :portals do |t|
      t.string  :name,             null: false   # "Microsoft Teams"
      t.string  :slug,             null: false   # "teams"
      t.string  :icon_url                        # logo URL for frontend
      t.string  :saml_idp_sso_url               # portal's SSO endpoint
      t.string  :saml_idp_entity_id             # portal's entity ID
      t.text    :saml_idp_cert                  # portal's signing certificate
      t.boolean :active,           default: true
      t.timestamps
    end
    add_index :portals, :slug, unique: true
  end
end
