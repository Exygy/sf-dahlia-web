namespace :listing_images do
  desc 'Process Listing Images'
  task process_images: :environment do
    listings = Force::ListingService.new.listings
    listings.each do |listing|
      ListingImageService.new(listing).process_image
    end
  end
end
