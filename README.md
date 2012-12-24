# Dircaster

Generate RSS 2.0 Podcast feed out of directory full of MP3 files.

## Usage

    dircaster ~/Music/Audio http://foo.example.com/Audio > ~/Music/Audio/podcast.xml

This script generates Podcast feed out of MP3 files in a directory. Audio metadata are automatically extracted from MP3's ID3 tags and embedded in the generated RSS feed. MP3 files should be accessible via the URL base you supply as a 2nd argument. Tip: Dropbox's Public folder makes it easy.

## Author

Tatsuhiko Miyagawa

