#!/bin/bash

# A robust development script for managing the Astro/Decap CMS workflow.
#
# COMMANDS:
#   start   - Starts the local development server after syncing with remote.
#   sync    - Pulls the latest changes from the remote repository.
#   save    - Commits and pushes all local changes with a required message.
#   status  - Shows the current status of the repository.
#   help    - Displays this help message.

# --- Configuration ---
REMOTE_NAME="origin"
BRANCH_NAME="main"

# --- Colors for output ---
COLOR_GREEN="\033[0;32m"
COLOR_RED="\033[0;31m"
COLOR_BLUE="\033[0;34m"
COLOR_NC="\033[0m"

print_info() {
  echo -e "${COLOR_BLUE}$1${COLOR_NC}"
}

print_success() {
  echo -e "${COLOR_GREEN}$1${COLOR_NC}"
}

print_error() {
  echo -e "${COLOR_RED}$1${COLOR_NC}"
}

# --- Main script logic ---
COMMAND="$1"
COMMIT_MESSAGE="$2"

# Ensure a command is provided
if [ -z "$COMMAND" ]; then
  print_error "No command provided."
  COMMAND="help" # Default to help if no command is given
fi

case "$COMMAND" in
  start)
    print_info "Starting development environment..."
    # First, sync with remote to get latest content from CMS
    ./dev.sh sync

    # Check if sync was successful before starting server
    if [ $? -eq 0 ]; then
      print_info "Starting local Astro dev server..."
      npm run dev
    else
      print_error "Sync failed. Please resolve issues before starting the dev server."
      exit 1
    fi
    ;;

  sync)
    print_info "Syncing with remote repository ($REMOTE_NAME/$BRANCH_NAME)..."
    # Pull the latest changes
    if git pull "$REMOTE_NAME" "$BRANCH_NAME"; then
      print_success "Sync complete. Your local repository is up to date."
    else
      print_error "Failed to sync with remote. There might be merge conflicts."
      echo "Please resolve any conflicts manually and then run './dev.sh save \"Resolved merge conflicts\"'"
      exit 1
    fi
    ;;

  save)
    # Check if a commit message was provided
    if [ -z "$COMMIT_MESSAGE" ]; then
      print_error "A commit message is required."
      echo "Usage: ./dev.sh save \"Your descriptive commit message\""
      exit 1
    fi

    print_info "Saving your work..."

    # Step 1: Add all changes
    print_info "Adding all changes to the staging area (git add .)"
    git add .

    # Step 2: Commit with the provided message
    print_info "Committing changes with message: '$COMMIT_MESSAGE'"
    # Check if there's anything to commit first
    if git diff --staged --quiet; then
      print_info "No changes to commit. Working tree clean."
      exit 0
    fi

    if ! git commit -m "$COMMIT_MESSAGE"; then
      print_error "Commit failed."
      exit 1
    fi

    # Step 3: Push to the remote repository
    print_info "Pushing changes to GitHub (git push)..."
    if git push "$REMOTE_NAME" "$BRANCH_NAME"; then
      print_success "Your changes have been successfully saved to GitHub."
    else
      print_error "Failed to push changes. Try running './dev.sh sync' first to resolve remote changes."
      exit 1
    fi
    ;;

  status)
    print_info "Displaying repository status (git status)..."
    git status
    ;;

  help|*)
    echo "Portfolio Development Workflow Script"
    echo "-------------------------------------"
    echo "Usage: ./dev.sh [command]"
    echo ""
    echo "Commands:"
    echo -e "  ${COLOR_GREEN}start${COLOR_NC}         - Syncs with remote and then starts the local dev server."
    echo -e "  ${COLOR_GREEN}sync${COLOR_NC}          - Pulls the latest content and code from GitHub."
    echo -e "  ${COLOR_GREEN}save \"message\"${COLOR_NC}  - Commits and pushes all your local code changes."
    echo -e "  ${COLOR_GREEN}status${COLOR_NC}        - Shows the current Git status."
    echo -e "  ${COLOR_GREEN}help${COLOR_NC}          - Shows this help message."
    echo ""
    echo "Example:"
    echo "  ./dev.sh save \"feat: update homepage styles\""
    ;;
esac
