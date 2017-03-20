#!/bin/bash

cat > "config.js" << EOF
/* SPHERE.IO credentials */
exports.config = {
  client_id: "${SPHERE_CLIENT_ID}",
  client_secret: "${SPHERE_CLIENT_SECRET}",
  project_key: "${SPHERE_PROJECT_KEY}",
  iron: {
    mq_url: "${IRON_MQ_URL}",
    project_id: "${IRON_PROJECT_ID}",
    token: "${IRON_TOKEN}",
  },
}
EOF
