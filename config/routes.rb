Rails.application.routes.draw do
  resources :role_accesses
  resources :permit_risks
  resources :hazard_categories
  resources :permit_activity_setups
  resources :permit_types
  resources :qr_verifications do
    member do
      post :check_in
      post :check_out
      get :status
    end
    collection do
      post :verify
    end
  end
  resources :todo_lists
  get 'survey_responses/index'
  get 'survey_responses/show'
  get 'survey_questions/index'
  get 'survey_questions/show'
  get "accounting_invoices/:id/preview", to: "accounting_invoices#preview", as: :preview_invoice

  # Public survey (no auth): shareable link for anyone to take the survey
  get 'public/surveys/:id', to: 'public_surveys#show', defaults: { format: 'json' }
  post 'public/surveys/:survey_id/responses', to: 'public_survey_responses#create', defaults: { format: 'json' }

  post '/send-survey', to: 'surveys#send_survey', defaults: { format: 'json' }
  resources :surveys do
    resources :survey_questions, except: [:index]
    resources :survey_responses, only: [:new, :create, :show, :index]
  end
  resources :visitor_sub_categories
  resources :visitor_categories
  resources :tasks
  resources :fitout_documents
  resources :parking_policies
  resources :vehicle_setups
  resources :user_refferals
  resources :event_guests

  resources :visitor_group_invites, only: [:create] do
    member do
      post :send_invitations
    end
    collection do
      get 'guest_register', to: 'visitor_group_invites#guest_register'
      post 'guest_register', to: 'visitor_group_invites#guest_register_submit'
    end
  end
  resources :staffs_logs
  get "patrolling_histories/export", to: "patrolling_histories#export"
  resources :pets do
    collection do
      get :pending_approvals
    end
    member do
      post :approve
      post :reject
    end
  end
  resources :snag_answers
  resources :snag_quest_options
  resources :snag_questions
  resources :snag_checklists
  resources :mom_attendees
  resources :mom_tasks
  resources :mom_details
  get 'fit_out_setup_categories/index'

  get 'fit_out_setup_categories/show'

  get 'fit_out_setup_categories/new'

  get 'fit_out_setup_categories/edit'

  get 'fit_out_setup_categories/create'

  get 'fit_out_setup_categories/update'

  get 'fit_out_setup_categories/destroy'

  resources :fit_out_setup_categories
  resources :fitout_subcategories
  resources :fitout_statuses
  resources :fitout_request do
    member do
      post :send_document_request
    end
  end
  resources :incident_injuries
  resources :feedbacks
  resources :permit_extensions
  resources :permit_entities
  resources :compliance_tracker_tags
  resources :compliance_trackers
  resources :compliance_config_tags
  resources :compliance_configs
  get 'compliance_configs/:id/generate_certificate', to: 'compliance_configs#generate_certificate', defaults: { format: 'pdf' }
  resources :compliance_tag_tasks
  resources :compliance_tags do
    collection do
      get :tree_structure
    end
  end
  resources :deleted_users
  resources :extensions
  resources :abouts do
    collection do
      post :contact_us
    end
  end
  resources :poll_users
  resources :parking_slots
  resources :invoice_receipts do
    collection do
      post :import
      get :download_sample
      get :download_sample
      get :export
    end
  end
  resources :invoice_types
  resources :receipt_setups
  resources :invoice_setups
  resources :invoices
  resources :permit_sub_activities
  post 'payments/create_order', to: 'payments#create_order'
  post 'payments/capture_payment', to: 'payments#capture_payment'
  post '/forums/:id/toggle_visibility', to: 'forums#toggle_visibility'
  resources :visitor_device_logs, only: [:create, :index] do
    get ':employee_no', to: 'visitor_device_logs#show_by_employee', on: :collection
  end
  resources :hik_devices do
    collection do
      get 'find_by_site/:site_id', to: 'hik_devices#find_by_site'
    end
  end
  namespace :admin do
    resources :forum_reports, only: [:index] do
      member do
        post :take_action
      end
    end
  end
  resources :forums, only: [] do
    member do
      post :save_for_later
      post :share
      post :toggle_like
      delete :unsave
    end
    collection do
      get :saved_forums
      get :shared_with_me
      get :visibility_status
    end
  end
  resources :forums do
  end
  resources :amenity_booking_rules
  resources :travel_allowance_requests
  resources :address_setups
  resources :incidence_tags do
    collection do
      get :tree_structure
    end
  end

  resources :additional_passengers
  resources :share_withs
  resources :seats
  resources :payments
  resources :cam_bill_charges
  resources :cam_bills do
    collection do
      post :import
      get :export
      get :download_sample
      get :pdf
      get :invoice_pdf
      get :bill_detail_pdf
    end
  end
  resources :charges
  resources :share_withs
  resources :seats
  resources :payments
  resources :charges
  resources :table_bookings do
    collection do
      get :available_tables
    end
  end
  resources :restaurant_orders do
    member do
      post :mark_billed
      post :mark_completed
      post :generate_kot
      get :kot_list
      get :bill_pdf
      patch :mark_confirmed
    end
    collection do
      get :table_status
      get :confirm_by_token
    end
  end
  resources :restaurant_order_items
  resources :kitchen_order_tickets do
    member do
      post :accept
      post :start_preparing
      post :mark_ready
      post :mark_served
    end
  end
  resources :color_codes
  resources :status_restaurants
  resources :amenity_bookings do
    collection do
      get :export_amenity
      get :calender_booking
      get :notification_amenity
      put :mark_as_read
      get :all_records_of_amenity
    end
  end

  resources :amenity_slots do
    collection do
      get :booked_slots
      get :slots_summary
    end
  end
  resources :amenities do
    member do
      patch :add_payment_methods
    end
    collection do
      get :export
    end
  end
  resources :banners
  resources :blocked_days
  get '/slots/available', to: 'amenities#available_slots'
  post '/upload_logo', to: 'invoice_setups#upload_logo'
  get '/get_logo', to: 'invoice_setups#get_logo'
  resources :folder_documents
  resources :folders do
    collection do
      get :get_folders
      post :share_multiple_documents
      post :share_personal_documents
      get :get_personal_folders
      get :get_share_with
    end
  end
  delete '/destroy_folder/:id', to: 'folders#destroy_folder', as: 'destroy_folder'

  resources :restaurant_menus do
    collection do
      post :bulk_create
    end
  end
  resources :transportations
  resources :business_cards do
    collection do
      get :get_for_user
    end
  end
  resources :hsns
  resources :organizations

  resources :companies do
    collection do
      get :list
      get :by_organization
    end
  end

  resources :group_members
  resources :departments
  get '/get_site_owner', to: 'generic_infos#get_site_owner'
  resources :asset_measures
  resources :meter_readings
  resources :inventories do
    collection do
      post :import
      get :download_sample
    end
  end
  # resources :inventories
  resources :tmp_checklists
  get 'complaint_modes/index'
  get 'complaint_modes/create'
  get 'complaint_modes/edit'
  get '/activities/calendar_data', to: 'activities#calendar_data'
  resources :communication_groups
  resources :checklist_crons
  resources :complaint_modes
  resources :checklist_users
  resources :asset_meter_types
  resources :user_categories
  resources :seat_bookings
  resources :meeting_room_bookings
  resources :audits
  resources :audit_tasks
  resources :incidents
  resources :field_sense_leads_managements
  resources :field_sense_meeting_managements
  resources :transportation_allowance_requests
  resources :transport_requests
  resources :cab_and_bus_requests
  resources :flight_requests
  resources :gdn_inventory_details
  resources :gdn_details
  resources :permit_activities
  resources :hazard_categories
  resources :permit_risks
  resources :other_projects
  resources :permit_safety_equipments
  resources :permits
  resources :mail_room_outbounds
  resources :mail_room_inbounds
  resources :permit_activity_setups
  resources :pantries
  resources :suppliers
  resources :ingredients
  resources :purchase_orders
  resources :permit_types
  resources :polls do
    resources :poll_options, only: [:create, :destroy]
    resources :poll_votes, only: [:create]
    member do
      post :mark_as_read
      post :mark_as_archived
    end
  end





  #new
  #resources :categories,only:[:index, :create]

  #resources :menus






  resources :poll_votes
  resources :poll_options, only: [:index, :show, :edit, :update]
  resources :food_and_beverages do
    collection do
      get :export
    end
  end
  resources :other_bills
  resources :groups do
    collection do
      delete 'destroy_multiple'
    end
  end
  resources :forums do
    # Nested routes for ForumComments (comments within a forum)
    member do
      post :hide
      post :unhide
      post :report
    end
    resources :forum_comments, only: [:index, :create, :update, :destroy]
    resources :likes, only: [:create] do
      delete '/', to: 'likes#destroy', on: :collection
    end
  end
  post '/likes/create_other_project_like', to: 'likes#create_other_project_like'
  post '/likes/delete_other_project_like', to: 'likes#delete_other_project_like'
  resources :fitness_appointments
  # post 'patrolling_scans/scan', to: 'patrolling_scans#scan'
  resources :staffs do
    collection do
      get :aniket_master
      get :get_staffs_count
      get :punched_in_today
      get :punched_out_today
      get :export_staffs
      get :staff_dashboard
      get :staff_drill
      post :qr_codes_download
    end
  end
  resources :vendor_categories, only: [:index, :create, :update, :destroy, :show]
  get 'vendor_categories', to: 'vendor_categories#index'
  resources :vendor_suppliers, only: [:index, :create, :update, :destroy, :show]
  get 'vendor_suppliers', to: 'vendor_suppliers#index'
  # config/routes.rb
  resources :visitor_staff_categories, controller: 'visitor_staff_category'
  get 'visitor_staff_category', to: 'visitor_staff_category#index'
  resources :patrolling_histories
  resources :registered_vehicles do
    collection do
      get :pending_approvals
      get :get_registered_vehicles
      get :get_dashboard_count
      post :import
      get :download_sample
    end
    member do
      post :approve_request
    end
  end

  resources :registered_vehicle_visits
  resources :booking_parkings
  get '/available_parking_configurations', to: 'booking_parkings#available_parking_configurations'
  resources :gates
  resources :patrollings do
    member do
      post 'scan'
    end
  end
  resources :inventory_details
  resources :grn_details
  resources :aminities
  resources :aminity_setups
  resources :aminity_slots
  resources :aminity_bookings
  resources :parking_configurations
  resources :hotels
  resources :menus
  resources :contact_books
  resources :loi_services
  resources :service_orders
  resources :addresses
  resources :generic_infos do
    resources :generic_sub_infos
  end
  resources :loi_details do
    member do
      post :create_approval_levels
    end
  end
  resources :loi_items
  resources :standard_units
  resources :goods_in_outs do
    post :check_goods, on: :member
  end
  get '/get_host_approval', to: 'visitors#get_host_approval', as: 'get_host_approval'
  post '/visitors/verify_votp', to: 'visitors#verify_votp'
  post '/users/update_user_request', to: 'users#update_user_request'
  put '/users/update_user/:id', to: 'users#update'
  get '/visitors/get_visitor', to: 'visitors#get_visitor'
  get '/visitors/get_visitor_by_id', to: 'visitors#get_visitor_by_id'
  get '/visitors/get_visitr_list', to: 'visitors#get_visitr_list'
  get '/visitors/visitor_category', to: 'visitors#visitor_category'
  post '/visitors/:id/re_notify_assigned_to', to: 'visitors#renotify_host'

  # Visitor Alert Config routes
  get '/visitor_alert_config', to: 'visitor_alert_configs#show'
  post '/visitor_alert_config', to: 'visitor_alert_configs#update'
  put '/visitor_alert_config', to: 'visitor_alert_configs#update'

  # Billing Configuration routes
  resources :billing_configurations

  # Income Entries routes
  resources :income_entries do
    collection do
      get :reconciliation_report
    end
  end

  resources :visitors do
    resources :visitor_visits do
      collection do
        post 'check_visitor'
      end
    end
    collection do
      get :self_registartions
      post :face_check_in, to: 'visitor_visits#face_check_in'
      post :face_check_out, to: 'visitor_visits#face_check_out'
      post :scan_qr
      get 'user', to: 'visitors#user_visitors', as: :user_visitors
      post :import
      get :visitors_list
      get :visitors_dashboard
      get :visitors_drill
      get :visitor_qr_codes
      get :export_visitors
      get :download_visitors_export
      get 'fetch_potential_hosts'
      get 'approval_form'
      get 'approval_history'
    end
    member do
      get  :verify_otp
      get  :validate_otp
      get  :resend_otp
      post :validate_otp
      post :resend_otp
      post :verify_otp
      patch 'approve_visitor'
      put :approve_visitor
      delete 'delete_attachment/:attachment_id', to: 'visitors#delete_attachment', as: 'delete_attachment'
    end
  end

  resources :soft_services do
    collection do
      get :export_soft_service
      get :soft_services_qr_codes
      get 'download_all_log_excel'
      get :print_qr_codes
      get :soft_services_dashboard
      get :soft_services_drill
      get :overview_count
      post :import
      get :sample_file
    end
    member do
      get 'softservices_log_show'
      get 'download_log_excel'
      get 'activities_for_soft_service'
    end
  end
  resources :notice_users
  resources :event_users
  resources :notices do
    collection do
      get :communicaions_dashboard
    end
    member do
      post :mark_as_read
      post :mark_as_archived
      get :track_email_open    # For tracking pixel in email
      get :track_email_click   # For link click tracking
    end
  end
  post 'notices/bulk_mark_as_read', to: 'notices#bulk_mark_as_read'
  resources :events do
    member do
      post :check_in, to: "event_check_ins#check_in"
      post :check_otp, to: "event_check_ins#check_otp"
      post :mark_as_read, to: "events#mark_as_read"
      post :mark_as_archived, to: "events#mark_as_archived"
      get :track_email_open    # For tracking pixel in email
      get :track_email_click   # For link click tracking
    end
  end
  resources :asset_amcs
  resources :sub_groups
  resources :asset_group_params
  resources :asset_groups do
    collection do
      post :import
    end
  end
  resources :ticket_items
  resources :ticket_logs
  resources :tickets
  resources :items
  resources :quotations do
    member do
      patch :decide
      patch :visit
      patch :start_work
      patch :complete_work
      post :generate_certificate
      get :download_certificate
    end
  end
  resources :approvals do
    member do
      patch :decide
    end
    collection do
      get :template_levels
    end
  end
  resources :attendances do
    collection do
      get :status_count
      post :face_check_in
      post :face_check_out
      post :face_check_in_out
    end
  end
  resources :vendor_suppliers, only: [:create, :update, :destroy]
  resources :vendor_categories, only: [:create, :update, :destroy]
  resources :vendors do
    collection do
      get :all_vendors
      post :import
    end
  end
  resources :generic_sub_infos
  get '/generic_sub_infos', to: 'generic_sub_infos#index'
  get '/checklist_sub_group', to: 'generic_infos#get_sub_generic_info'
  get '/get_sub_categories', to: 'generic_sub_infos#get_sub_categories'
  post "/checklist/checklist_import" => "checklists#import"
  post "/folder_documents/create_common_document" => "folder_documents#create_common_document"
  post "/folders/create_common_folder" => "folders#create_common_folder"
  post "/add_user_face" => "aws#add_user_face"
  post "/recognize" => "aws#recognize"
  post "/add_approval_level" => "approvals#add_level", defaults: { format: :json }
  delete "/approval_levels/:id" => "approvals#destroy_level", defaults: { format: :json }
  resources :job_sheets do
    member do
      post :check_in
      post :check_out
    end
  end
  resources :capas
  resources :knowledge_articles do
    collection do
      get :published
    end
  end
  resources :escalation_histories, only: [:index, :update]
  get "/ppm" => "checklists#ppm"
  get "/checklist_associations" => "activities#checklist_associations"
  get "/setup" => "sites#setup"
  get "/user_attendances/:user_id" => "attendances#users"
  get "/attendances_report" => "attendances#attendances_report"
  post "/complete_ticket" => "ticket_items#complete_ticket"
  get "/delete_user_activity" => "activities#delete_act"
  resources :site_assets do
    collection do
      get :download_all_log_excel
      get :qr_codes
      post :import
      post :import_reading
      get :download_sample
      get :print_qr_codes
      get :export
      get :count
      get :grouped_assets_status
      get :get_asset_count
      get :site_assets_dashboard
      get :site_assets_drill
    end
    member do
      get :download_log_excel
      get 'asset_ppm_show'
    end
  end
  resources :submissions do
    collection do
      get :export_readings
    end
  end
  resources :activities do
    collection do
      delete :bulk_destroy
      put :bulk_update
      get :export
      get :count
      get :routine_task_counts
      get :export_routine
    end
  end
  resources :questions
  get '/checklists/download_template', to: 'checklists#download'
  get '/checklists/get_master_checklist', to: 'checklists#get_master_checklist', as: :get_master_checklist
  resources :checklists do
    member do
      delete 'delete_question'
    end
  end
  resources :asset_params
  resources :floors do
    collection do
      post :import
    end
  end
  resources :buildings do
    collection do
      post :import
    end
  end
  resources :user_devices
  resources :units do
    collection do
      post :import
      get :user_units
      get 'user_units/:user_id', to: 'units#user_units', as: 'user_units_by_id'
      post :create_user_site
      post :create_multiple_user_sites
      patch :update_user_site
      delete :delete_user_site
    end
  end
  resources :sites do
    collection do
      post :import
      get :features
      get :all_features
      get :company_list
      get :company_sites
    end
    member do
      patch :toggle_active
    end
  end

  post '/users/forgot' => 'users#forgot'
  post '/users/verify_otp' => 'users#verify_otp'
  get "users/user_dropdown", to: "users#user_dropdown"
  patch 'users/:id/update_status', to: 'users#update_status', as: 'update_status_user'
  put '/users/reset' => 'users#reset'
  post '/users/change_password'  => 'users#change_password'
  devise_for :users, controllers: {
    omniauth_callbacks: 'omniauth_callbacks',
    passwords: 'passwords'
  }
  resources :users do
    collection do
      get :pendig_admin_approvals
      get :index_count
      get 'pms_admins', to: 'users#pms_admins'
      get :today_tasks
      get :assigned_tasks
      get :scheduled_tasks
      post :scheduled_tasks
      get :schedule_types
      get :previous_tasks
      get :open_tasks
      get :export_users
      get :closed_tasks
      post :fm_users_import
      post :create_user
      get :lup_confirmation
      get :lup_failure
      post :import
      get :send_welcome_email
      post :send_welcome_email
      post :sync_users_batch
    end
    member do
      post :sync_to_external_api
    end
  end
  resources :cards do
    collection do
      post :fetch_and_save
      post :fetch_all_users_cards
      post :assign_tag
      post :assign_tags_batch
    end
  end
  get "/reports" => "sites#reports"
  get "/consumption" => "sites#consumption"
  get "/company_sites" => "sites#company_sites"
  get "/change_site_for_app" => "users#change_site_for_app"
  get "/change_site" => "users#change_site"
  get "/get_user_site" => "users#get_user_site"
  get "/take_reading" => "submissions#take_reading"
  get "/show_submissions" => "submissions#showit"
  get "/show_readings" => "submissions#readings"
  get "/show_multiple_readings" => "submissions#multiple_readings"
  post "/active_inactive_user" => "users#active_inactive_user"
  post "/login" => "users#login"
  post "/otp_request" => "users#otp_request"
  post '/verify_otp_by_mobile', to: 'users#verify_otp_by_mobile'

  # Bg Image
  get 'api/employee/get_bg_image' => 'users#get_bg_image'
  # Goyal Images
  get 'api/employee/get_goyal_image' => 'users#get_goyal_park'


  match '/login', to: 'users#preflight', via: :options

  # Legacy company routes - Consider using RESTful routes: resources :companies
  # post "/companies" => "sites#add_company"
  # post "/companies_by_organization" => "sites#add_company_by_organization"
  # Use: POST /companies and GET /companies/by_organization instead

  post "/users/create" => "users#create"
  get "/categories" => "users#categories"
  post "/helpdesk_operations" => "users#helpdesk_operations"
  # get "/pms/admin/get_sub_categories" => "pms/manage/helpdesk_categories#get_sub_categories"
  root to: "projects#index"
  post '/clone_escalations' => "pms/manage/helpdesk_categories#clone_escalations"
  get "/get_schedules_admin_facility_pms" => "pms/manage/facility_setups#get_schedules_admin_facility_pms", :defaults => { :format => 'json' }
  post "/pms/admin/create_helpdesk_category" => "pms/manage/helpdesk_categories#create_helpdesk_category"
  patch "/pms/admin/modify_helpdesk_category/:id" => "pms/manage/helpdesk_categories#update"
  post "/pms/admin/create_helpdesk_sub_category" => "pms/manage/helpdesk_categories#create_helpdesk_sub_category"
  post "/pms/admin/modify_helpdesk_sub_category" => "pms/manage/helpdesk_categories#modify_helpdesk_sub_category"
  post "/pms/admin/modify_helpdesk_sub_category/:id" => "pms/manage/helpdesk_categories#modify_helpdesk_sub_category"
  get "/pms/admin/edit_category_form" => "pms/manage/helpdesk_categories#edit_category_form"
  post "/pms/admin/create_complaint_statuses" => "pms/manage/helpdesk_categories#create_complaint_statuses"
  post "/pms/admin/delete_complaint_mode" => "pms/manage/helpdesk_categories#delete_complaint_mode"
  post "/pms/admin/create_complaint_modes" => "pms/manage/helpdesk_categories#create_complaint_modes"
  post "/pms/admin/modify_complaint_status/:id" => "pms/manage/helpdesk_categories#modify_complaint_status"
  post "/pms/admin/update_complaint_mode" => "pms/manage/helpdesk_categories#update_complaint_mode"
  # get "/pms/admin/get_sub_categories" => "pms/manage/helpdesk_categories#get_sub_categories"
  get "/pms/admin/complaint_issue_types" => "pms/manage/complaints#complaint_issue_types"
  post "/pms/admin/create_aging_rule" => "pms/manage/helpdesk_categories#create_aging_rule"
  post "/pms/admin/delete_aging_rule" => "pms/manage/helpdesk_categories#delete_aging_rule"
  post "/pms/admin/update_complaint_logs" => "pms/manage/complaints#update_complaint_logs"
  post "/pms/admin/create_reopen" => "pms/manage/helpdesk_categories#create_reopen"
  post "/pms/admin/create_issue_type" => "pms/manage/helpdesk_categories#create_issue_type"
  post "/pms/admin/create_escalation" => "pms/manage/helpdesk_categories#create_complaint_worker"
  post "/pms/admin/create_complaint_worker" => "pms/manage/helpdesk_categories#create_complaint_worker"
  post "/pms/admin/update_complaint_worker" => "pms/manage/helpdesk_categories#update_complaint_worker"
  post "/pms/admin/delete_complaint_worker" => "pms/manage/helpdesk_categories#delete_complaint_worker"
  get "/pms/admin/helpdesk_reports" => "pms/manage/helpdesk_categories#helpdesk_reports"
  get "/pms/admin/helpdesk_charts" => "pms/manage/helpdesk_categories#helpdesk_charts"
  post "/pms/admin/helpdesk_reports" => "pms/manage/helpdesk_categories#helpdesk_reports"
  post "pms/admin/complaint_assign" => "pms/manage/helpdesk_categories#complaint_assign"
  get "pms/admin/pms_admin_ticket_reports" => "pms/manage/complaints#pms_admin_ticket_reports"
  post "pms/admin/complaint_items" => "pms/manage/complaints#complaint_items"
  patch 'operation_days/:id', to: 'sites#operation_days', as: :operation_days
  # post "/site_assets/print_qr_codes" => "site_assets#print_qr_codes"
  get "/get_subgroups" => "checklists#get_subgroups"
  get "/export_checklist" => "checklists#export_checklist"
  get "/get_complaints" => "complaints#get_complaints"
  resources :projects do
    collection do
      get :user_project
    end
    resources :tasks

  end
  # resources :helpdesk_operations
  resources :comments
  resources :attachfiles
  resources :complaint_logs
  namespace :pms do
    resources :complaints do
      member do
        get :feeds
        get :complaint_edit_form
      end
    end
    resources :suppliers
    resources :email_rule_setups do
    end


    namespace :manage, :path => "/admin" do
      get 'get_sub_categories(/:id)', to: 'helpdesk_categories#get_sub_categories', defaults: { format: 'json' }
      delete 'delete_complaint_worker/:id', to: 'helpdesk_categories#delete_complaint_worker', defaults: { format: :json }
      resources :cost_approvals
      resources :helpdesk_categories do
        collection do
          patch 'update_complaint_statuses/:id', to: 'helpdesk_categories#update_complaint_statuses'
          get 'escalations'
          get 'complaint_statuses'
          get 'complaint_workers(/:id)', to: 'helpdesk_categories#complaint_workers'
        end
        get 'complaint_statuses(/:id)', to: 'helpdesk_categories#complaint_statuses', on: :collection
      end

      resources :complaints  do
        member do
          get :feeds
          get :complaint_edit_form
          get :regions
          get :zones
          get :sites
        end
        collection do
          get :send_vendor_mail
          get :export_cfms_report
          get :export_complaints
          get :export_cost_approval_report
          get :complaints_dashboard
          get :complaints_drill
          get :ticket_list
        end
      end
    end
  end

  # Additional Services Module Routes
  resources :unit_configurations

  resources :service_categories do
    resources :service_subcategories, shallow: true do
      member do
        get :available_slots
        get :pricing_info
        get :check_user_unit_config
      end
    end
  end

  resources :service_subcategories do
    member do
      get :available_slots
      get :pricing_info
      get :check_user_unit_config
    end
    resources :service_slots, shallow: true do
      collection do
        post :bulk_create
        get :available_slots
      end
    end
    resources :service_pricings, shallow: true
  end

  resources :service_pricings do
    collection do
      post :bulk_create
    end
  end

  resources :service_bookings do
    member do
      patch :cancel
      patch :confirm
      patch :start
      patch :complete
      post :rate
    end
    collection do
      get :available_services
      get :user_configuration_status
      post :assign_test_unit
    end
  end

  # Room Booking Module Routes
  resources :rooms do
    collection do
      get :search
      get :available_rooms
    end
    member do
      get :availability
      get :pricing
    end
    resources :room_pricing do
      collection do
        post :bulk_create
        get :calendar
      end
    end
    resources :room_availability do
      collection do
        post :block_dates
        post :unblock_dates
        post :set_availability
        get :calendar
      end
    end
  end

  resources :room_bookings do
    member do
      post :check_in
      post :check_out
      post :cancel
      post :confirm
    end
    collection do
      get :pricing_info
    end
  end

  # Accounting System Routes
  resources :account_groups do
    collection do
      post :seed_defaults
    end
  end

  resources :ledgers do
    member do
      get :balance_sheet
    end
    collection do
      post :seed_defaults
      get :by_group
      get :by_unit
      get :organization_wide
    end
  end

  resources :tax_rates do
    collection do
      post :seed_defaults
      get :active
    end
  end

  resources :journal_entries do
    member do
      post :post
      post :cancel
    end
  end

  resources :accounting_invoices do
    member do
      post :send_invoice
      post :add_payment
      get :download_pdf
    end
    collection do
      get :overdue
      get :by_unit
      get :find_by_number
    end
  end

  resources :accounting_payments do
    collection do
      get :by_invoice
    end
  end


  # namespace :api do
  #   namespace :v1 do
  #     resources :grouped_dashboard, only: [] do
  #       collection do
  #         get :index
  #         get :site_dashboard
  #         get :drilldown
  #       end
  #     end
  #   end
  # end

  namespace :api do
    namespace :v1 do
      # ── Microsoft OAuth (replaces JumpCloud) ─────────────────────
      namespace :auth do
        get  'microsoft/init',     to: 'microsoft#init'
        get  'microsoft/callback', to: 'microsoft#callback'
        post 'microsoft/exchange', to: 'microsoft#exchange'

        # Keep SAML routes dormant (don't remove, just unused now)
        get  'saml/init',     to: 'saml#init'
        post 'saml/callback', to: 'saml#callback'
        post 'saml/exchange', to: 'saml#exchange'
        get  'saml/metadata', to: 'saml#metadata'
      end

      # ── Microsoft Graph Data APIs ─────────────────────────────────
      namespace :microsoft do
        get :profile
        get :calendar
        get :holidays
        get :emails
        get :mailbox_settings
      end

      # ── Portal Dashboard ─────────────────────────────────────────
      resources :portals, only: [:index] do
        member do
          get :sso_url
        end
      end


      get  "grouped_dashboard",                    to: "grouped_dashboard#index"
      get  "grouped_dashboard/site_performance",   to: "grouped_dashboard#site_performance"
      get  "grouped_dashboard/site_drill",         to: "grouped_dashboard#site_drill"
      get  "grouped_dashboard/asset_portfolio",    to: "grouped_dashboard#asset_portfolio"
      get  "grouped_dashboard/asset_drill",        to: "grouped_dashboard#asset_drill"
      get  "grouped_dashboard/asset_activities",   to: "grouped_dashboard#asset_activities"
      get  "grouped_dashboard/workforce_drill",    to: "grouped_dashboard#workforce_drill"
      get  "grouped_dashboard/service_desk",       to: "grouped_dashboard#service_desk"
      get  "grouped_dashboard/ppm_operations",     to: "grouped_dashboard#ppm_operations"
      get  "grouped_dashboard/ppm_drill",          to: "grouped_dashboard#ppm_drill"
      get  "grouped_dashboard/workforce",          to: "grouped_dashboard#workforce"
      get  "grouped_dashboard/compliance",         to: "grouped_dashboard#compliance"
      get  "grouped_dashboard/visitors_detail",    to: "grouped_dashboard#visitors_detail"
      get  "grouped_dashboard/visitors_drill",      to: "grouped_dashboard#visitors_drill"
      get  "grouped_dashboard/org_associates",     to: "grouped_dashboard#org_associates"

      # Notification Bell API
      # resources :notifications, only: [:index, :show, :update, :destroy] do
      #   collection do
      #     get    :mark_all_as_read
      #     patch  :mark_all_as_read
      #     get    :unread_count
      #   end
      #   member do
      #     get   :mark_as_read
      #     patch :mark_as_read
      #   end
      # end

      # Razorpay Payments
      post 'payments/create_order', to: 'payments#create_order', defaults: { format: :json }
      post 'payments/verify',       to: 'payments#verify',       defaults: { format: :json }
      post 'payments/webhook',      to: 'payments#webhook',      defaults: { format: :json }

      # Amenity Slot Configuration API
      resources :amenity_slot_configs, only: [:show, :update] do
        member do
          post :generate_slots
        end
        collection do
          get :valid_durations
        end
      end
    end
  end

  get 'accounting_reports/dashboard', to: 'accounting_reports#dashboard'
  get 'accounting_reports/dashboard_summary', to: 'accounting_reports#dashboard_summary'
  get 'accounting_reports/analytics', to: 'accounting_reports#analytics'
  get 'accounting_reports/trial_balance', to: 'accounting_reports#trial_balance'
  get 'accounting_reports/balance_sheet', to: 'accounting_reports#balance_sheet'
  get 'accounting_reports/profit_and_loss', to: 'accounting_reports#profit_and_loss'
  get 'accounting_reports/ledger_statement', to: 'accounting_reports#ledger_statement'
  get 'accounting_reports/unit_statement', to: 'accounting_reports#unit_statement'
  get 'accounting_reports/unit_statement_detailed', to: 'accounting_reports#unit_statement_detailed'
  get 'accounting_reports/receivables_summary', to: 'accounting_reports#receivables_summary'

  # MIS Exports
  get 'accounting_reports/expenses_mis', to: 'accounting_reports#expenses_mis', defaults: { format: 'xlsx' }
  get 'accounting_reports/income_mis', to: 'accounting_reports#income_mis', defaults: { format: 'xlsx' }
  get 'accounting_reports/individual_mis', to: 'accounting_reports#individual_mis', defaults: { format: 'xlsx' }

  # MIS Templates (dummy rows)
  get 'accounting_reports/expenses_mis_template', to: 'accounting_reports#expenses_mis_template', defaults: { format: 'xlsx' }
  get 'accounting_reports/income_mis_template', to: 'accounting_reports#income_mis_template', defaults: { format: 'xlsx' }

  # MIS Imports
  post 'accounting_reports/expenses_mis/import', to: 'accounting_reports#import_expenses_mis', defaults: { format: 'json' }
  post 'accounting_reports/income_mis/import', to: 'accounting_reports#import_income_mis', defaults: { format: 'json' }
  post 'accounting_reports/individual_mis/import', to: 'accounting_reports#import_individual_mis', defaults: { format: 'json' }

  # Reports
  get '/unit_statement_pdf', to: 'accounting_reports#unit_statement_pdf'
  get '/cam_statement_pdf', to: 'accounting_reports#cam_statement_pdf'
  get '/cam_statement_preview', to: 'accounting_reports#cam_statement_pdf'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :accounting do
      post 'advance-payments/record', to: 'advance_payments#record'
      get  'advance-payments/status', to: 'advance_payments#status'

      post 'tenant-fees/invoice', to: 'tenant_fees#invoice'
      get  'tenant-fees/config',  to: 'tenant_fees#config'

      post 'cam/generate', to: 'cam#generate'
      get  'cam/summary',  to: 'cam#summary'
    end
    # CAM Routes (Api module controllers)
    # Settings
    get 'cam/settings', to: 'cam_settings#show'
    post 'cam/settings', to: 'cam_settings#create'

    # Unit Configs
    get 'cam/unit_configs', to: 'cam_unit_configs#index'
    post 'cam/unit_configs', to: 'cam_unit_configs#create'
    patch 'cam/unit_configs/:id', to: 'cam_unit_configs#update'
    put 'cam/unit_configs/:id', to: 'cam_unit_configs#update'

    # Monthly Expenses
    get 'cam/monthly_expenses', to: 'cam_monthly_expenses#index'
    post 'cam/monthly_expenses', to: 'cam_monthly_expenses#create'
    patch 'cam/monthly_expenses/:id', to: 'cam_monthly_expenses#update'
    put 'cam/monthly_expenses/:id', to: 'cam_monthly_expenses#update'
    delete 'cam/monthly_expenses/:id', to: 'cam_monthly_expenses#destroy'
    get 'cam/monthly_expenses/total', to: 'cam_monthly_expenses#calculate_total'

    # Bills
    get 'cam/bills', to: 'cam_bills#index'
    post 'cam/bills/preview', to: 'cam_bills#preview'
    post 'cam/bills/generate', to: 'cam_bills#generate'

    # Advance Maintenance
    get 'cam/advance_maintenances', to: 'cam_advance_maintenances#index'
    post 'cam/advance_maintenances/generate', to: 'cam_advance_maintenances#generate'

    # Tenant Charges
    get 'cam/tenant_charges', to: 'cam_tenant_charges#index'
    post 'cam/tenant_charges', to: 'cam_tenant_charges#create'

    # Summary
    get 'cam/income_expense_summary', to: 'cam_income_expense_summary#show'

    # Income & Expense Report Calculations
    post 'cam/calculate_expense_allocation', to: 'cam_reports#calculate_expense_allocation'
    post 'cam/calculate_income_allocation', to: 'cam_reports#calculate_income_allocation'
    post 'cam/calculate_income_vs_expense', to: 'cam_reports#calculate_income_vs_expense'
    get 'cam/income_by_category', to: 'cam_reports#income_by_category'
    get 'cam/expense_by_category', to: 'cam_reports#expense_by_category'
    get 'cam/daily_income_report', to: 'cam_reports#daily_income_report'
    get 'cam/daily_expense_report', to: 'cam_reports#daily_expense_report'
    get 'cam/unit_wise_income_summary', to: 'cam_reports#unit_wise_income_summary'
    get 'cam/unit_wise_expense_summary', to: 'cam_reports#unit_wise_expense_summary'
    get 'cam/unit_cam_statement', to: 'cam_reports#unit_cam_statement'
    get 'cam/monthly_income', to: 'cam_reports#monthly_income'
    get 'cam/monthly_income/total', to: 'cam_reports#monthly_income_total'
    get 'cam/detailed_income_summary', to: 'cam_reports#detailed_income_summary'

    # Calculations
    post 'accounting/calculate-interest', to: 'calculations#calculate_interest'
    post 'accounting/calculate-income-total', to: 'calculations#calculate_income_total'
  end
end
