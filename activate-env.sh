#!/bin/bash
# Quick activation script for Python virtual environment

if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

echo "🐍 Python virtual environment activated!"
echo "💡 To deactivate, run: deactivate"
