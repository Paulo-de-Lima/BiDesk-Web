#!/bin/bash
chmod +x /home/paulo/BiDesk-Web/bin/rails
cd /home/paulo/BiDesk-Web
bin/rails runner 'asset = Rails.application.assets.find_asset(
