FactoryGirl.define do
  factory :uploaded_file do
    session_uid '123123-xyzyz'
    listing_id '123'
    document_type 'gas bill'
    file '<binarydata>'
    name 'foo'
    content_type 'png'
  end
end
