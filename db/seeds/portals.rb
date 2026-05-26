# Seed default portals
# Run with: rails runner db/seeds/portals.rb
#
# saml_idp_sso_url / saml_idp_entity_id / saml_idp_cert are filled in
# when you register your app as an SP with each portal's SSO provider.
# Leave blank for now — they're only needed for portal → auto-login flow.

portals = [
  { name: 'Microsoft Teams',  slug: 'teams',    icon_url: 'https://upload.wikimedia.org/wikipedia/commons/c/c9/Microsoft_Office_Teams_%282018%E2%80%93present%29.svg' },
  { name: 'Microsoft Outlook', slug: 'outlook',  icon_url: 'https://upload.wikimedia.org/wikipedia/commons/d/df/Microsoft_Office_Outlook_%282018%E2%80%93present%29.svg' },
  { name: 'Salesforce',        slug: 'salesforce', icon_url: 'https://upload.wikimedia.org/wikipedia/commons/f/f9/Salesforce.com_logo.svg' },
  { name: 'OATS',              slug: 'oats',     icon_url: nil },
  { name: 'KnowBe4',           slug: 'knowbe4',  icon_url: nil },
  { name: 'ESG',               slug: 'esg',      icon_url: nil },
]

portals.each do |attrs|
  Portal.find_or_create_by(slug: attrs[:slug]) do |p|
    p.name     = attrs[:name]
    p.icon_url = attrs[:icon_url]
    p.active   = true
  end
  puts "Portal: #{attrs[:name]} ✓"
end

puts "\nDone. Assign portals to users with:"
puts "  user = User.find_by(email: 'employee@example.com')"
puts "  portal = Portal.find_by(slug: 'teams')"
puts "  UserPortalAccess.create!(user: user, portal: portal)"
