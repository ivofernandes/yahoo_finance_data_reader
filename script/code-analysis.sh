cd ..
echo "# All modules:"
find . -name "*.dart" -type f|xargs wc -l | grep total
