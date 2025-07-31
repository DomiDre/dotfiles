function rmdirempty --description 'Remove all empty directories recursively in the current directory without removing the current directory itself'
    find . -mindepth 1 -type d -empty -exec rmdir {} +
end
