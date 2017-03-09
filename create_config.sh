#!/bin/bash

cat > "config.js" << EOF
/* SPHERE.IO credentials */
exports.config = {
  client_id: "${SPHERE_CLIENT_ID}",
  client_secret: "${SPHERE_CLIENT_SECRET}",
  project_key: "${SPHERE_PROJECT_KEY}"
}
EOF

cat > "test-config.js" << EOF
/* IRON.IO MQ credentials */
exports.config = {
  iron_mq_url: "${IRON_MQ_URL}",
  iron_project_id: "${IRON_PROJECT_ID}",
  iron_token: "${IRON_TOKEN}"
}
EOF