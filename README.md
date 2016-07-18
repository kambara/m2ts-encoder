# M2TS to MP4 Encoder

## Usage

Edit M2TS_DIR and MP4_DIR in encode.ts.

    ./encode.rb

## crontab

    0 2 * * * /home/kambara/m2ts-encoder/encode.rb >> /var/log/m2ts-encoder.log 2>&1
