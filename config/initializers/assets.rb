# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w(
  bootstrap45.min.css font-awesome.min.css covid_styles.min.css
  bootstrap.css bootstrap.min_v2.css daterangepicker.css
  calender.css datepicker3.css toastr.min.css animate.css
  meanmenu.min.css metisMenu.min.css metisMenu-vertical-hover.css
  bootstrap-table.css style_new_pms.css responsive.css
  chosen.css tabs.css mainone.css jquery.cardtabs.css
  semantic.min.css multiple-select.css pignose.calendar.min.css
  blueimp-gallery.min.css dashboard.css
  jquery.min.js bootstrap-table.js metisMenu.min.js
  jquery-ui.min.js moment.min.js daterangepicker.js calender.js
  semantic.js color-picker.js bootstrap-datepicker.js toastr.min.js
  switchery.js cookie.js bootstrap-tagsinput.js cbpFWTabs.js
  jquery.cardtabs.js multiple-select.js pignose.calendar.full.min.js
  jquery.blueimp-gallery.min.js
)
