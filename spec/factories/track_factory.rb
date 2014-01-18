FactoryGirl.define do
  factory :track do
    sequence(:title) { |n| "title-#{n}" }
    sequence(:artist) { |n| "artist-#{n}" }
    sequence(:album) { |n| "album-#{n}" }
    sequence(:track_number) { |n| n }
    disc_number 1
    length 90
    sequence(:path) { |n| "/var/my/mp3/track#{n}.mp3" }
  end
end