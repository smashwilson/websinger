# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120226160458) do

  create_table "enqueued_tracks", :force => true do |t|
    t.integer  "position"
    t.integer  "track_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "player_commands", :force => true do |t|
    t.string   "action"
    t.string   "parameter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tracks", :force => true do |t|
    t.string   "title"
    t.string   "artist"
    t.string   "album"
    t.integer  "track_number"
    t.integer  "disc_number"
    t.integer  "length"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "album_slug"
    t.string   "artist_slug"
  end

  add_index "tracks", ["album"], :name => "index_tracks_on_album"
  add_index "tracks", ["album_slug"], :name => "index_tracks_on_album_slug"
  add_index "tracks", ["artist"], :name => "index_tracks_on_artist"
  add_index "tracks", ["artist_slug"], :name => "index_tracks_on_artist_slug"
  add_index "tracks", ["title"], :name => "index_tracks_on_title"

end
