require 'sitemap_generator'

desc 'This task is called by the Heroku scheduler add-on'

task sitemap: :environment do
  listings = ListingService.listings()
  SitemapGenerator::Sitemap.default_host = 'https://housing.sfgov.org'
  SitemapGenerator::Sitemap.create do
    add '/', changefreq: 'weekly'
    add '/welcome-chinese', changefreq: 'weekly'
    add '/welcome-spanish', changefreq: 'weekly'
    add '/welcome-filipino', changefreq: 'weekly'
    add '/listings', changefreq: 'daily', priority: 0.75
    add '/eligibility-estimator', changefreq: 'monthly'
    add '/get-assistance', changefreq: 'monthly'
    add '/housing-counselors', changefreq: 'monthly'
    add '/additional-resources', changefreq: 'monthly'
    add '/create-account', changefreq: 'monthly'
    add '/sign-in', changefreq: 'monthly'
    add '/disclaimer', changefreq: 'monthly'
    add '/privacy', changefreq: 'monthly'
    listings.each do |listing|
      add "/listings/#{listing['listingID']}", changefreq: 'daily', priority: 0.75
    end
  end
end
