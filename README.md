# haste-nvim
Small lua (🚀) plugin for uploading the contents of the current buffer to any* haste service.

## Configuration
You need to call `require("haste").setup()` somewhere in your config.

As of now there are only two config options, `url` and `setclip`.
```
require("haste").setup({
    url = "https://paste.ppeb.me",   -- Must include http:// or https:// and no trailing slash
    setclip = false,                 -- If set to true, the system clipboard will be set to the url when run
})
```

### Notes
* Requires curl on the path
* The haste instance should have an endpoint at `/documents`. A default haste server will have that so it shouldn't be an issue.
