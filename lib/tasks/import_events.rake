require "csv"
require "kramdown"
require "yaml"

task :import_events do
  desc "Imports event data from a CSV file produced by the old site's database."

  headers = nil
  last_event = nil
  front_matter = nil

  CSV.foreach "events.csv", liberal_parsing: true do |row|
    if headers.nil?
      headers = row
      next
    end

    event = headers.each_with_object({}) { |field, r|
      index = headers.find_index field
      value = row[index]
      value = nil if value == "NULL"
      r[field] = value
    }

    if event["start_time"].nil? || event["end_time"].nil?
      puts "Ignoring #{event["id"]} (#{event["title"]}) - no start/end time"
      next
    end

    if event["visible"] == "0"
      puts "Ignoring #{event["id"]} (#{event["title"]}) - not visible"
      next
    end

    if last_event.nil? || last_event["id"] != event["id"]
      write_event front_matter, last_event["body"] unless last_event.nil?
      last_event = event
      front_matter = build_front_matter event
      next
    end

    if last_event["id"] == event["id"]
      front_matter = build_front_matter event, front_matter
    end
  end

  write_event front_matter, last_event["body"] unless last_event.nil?
end

def build_front_matter event, front_matter = nil
  if front_matter.nil?
    title = event["title"].gsub(/\s+/, " ").strip
    date = Date.strptime event["dt"], "%Y-%m-%d"

    front_matter = {
      "title" => title,
      "date" => {
        "year" => date.year,
        "month" => date.month,
        "day" => date.day
      },
      "start" => parse_time(event["start_time"]),
      "end" => parse_time(event["end_time"]),
      "audience" => [],
      "topic" => []
      # "original_data" => JSON.generate(event)
    }
  end

  add_thing_to_list event["topic"], front_matter["topic"]
  add_thing_to_list event["audience"], front_matter["audience"]

  front_matter
end

def add_thing_to_list thing, list
  if thing.nil? || thing == ""
    return
  end
  list.push thing unless list.include? thing
end

def write_event front_matter, body
  slug = front_matter["title"].parameterize
  filename = Pathname.new "_events/#{front_matter["date"]["year"]}#{front_matter["date"]["month"]}#{front_matter["date"]["day"]}-#{slug}.md"

  body_doc = Kramdown::Document.new(body, html_to_native: true)

  FileUtils.mkdir_p filename.dirname unless Dir.exist? filename.dirname
  File.write filename, "#{YAML.dump front_matter}---
#{body_doc.to_kramdown.to_s.strip}
"
end

def prep_original_data event
  event.select do |key, value|
    key != "body" && !value.nil? && value.strip != ""
  end
end

def parse_time value
  parts = value.split ":"
  hours = parts[0].to_i
  minutes = parts[1].to_i
  ampm = "AM"

  if hours == 12
    ampm = "PM"
  elsif hours > 12
    hours -= 12
    ampm = "PM"
  end

  "#{hours}:#{minutes.to_s.rjust(2, "0")} #{ampm}"
end
