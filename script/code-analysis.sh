cd ..
echo "# Package implementation:"
find ./lib -name "*.dart" -type f|xargs wc -l | grep total

echo "# Package tests:"
find ./test -name "*.dart" -type f|xargs wc -l | grep total

echo "# Package example:"
find ./example -name "*.dart" -type f|xargs wc -l | grep total