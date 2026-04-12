#!/bin/bash

# Script to send requests to trigger ALB 5XX alarm
# The alarm triggers when HTTPCode_Target_5XX_Count > 1 for 2 consecutive 60-second periods

ENDPOINT="${1:-http://k8s-default-mysample-15462f7eec-296687943.eu-west-1.elb.amazonaws.com/api/hello}"
REQUESTS="${2:-100}"
CONCURRENCY="${3:-10}"
DELAY="${4:-0.1}"

echo "🚀 Sending $REQUESTS requests to $ENDPOINT"
echo "   Concurrency: $CONCURRENCY"
echo "   Delay between batches: ${DELAY}s"
echo ""

send_request() {
    local i=$1
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$ENDPOINT" 2>/dev/null)
    echo "[$i] HTTP $response"
}

count=0
while [ $count -lt $REQUESTS ]; do
    # Send concurrent requests
    for j in $(seq 1 $CONCURRENCY); do
        if [ $count -lt $REQUESTS ]; then
            ((count++))
            send_request $count &
        fi
    done
    wait
    sleep $DELAY
done

echo ""
echo "✅ Completed $REQUESTS requests"
echo "💡 The alarm should trigger within ~10 seconds if 5XX errors were returned"
