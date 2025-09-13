#!/bin/bash
# Activate virtual environment
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# Upgrade pip if needed
pip install --upgrade pip > /dev/null 2>&1

# Install requirements if they exist
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt > /dev/null 2>&1
fi

# Start dashboard
python dashboard.py
