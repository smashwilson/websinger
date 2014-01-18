FactoryGirl.define do
  factory :enqueued_track do
    sequence(:position) { |n| n.to_s }
    track
  end
end