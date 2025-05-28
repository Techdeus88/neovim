--Start-of-file--
local Master = {}
-- Type definitions (in comments)
------------------------------------------------
-- fts: Array<string>
-- langs: Array<string>
-- lang_to_ft: Table<string, Array<string>>
-- ft_to_lang_map: Table<string, Array<string>>
-- by_lang: Table<string, {
--   desc: string,
--   year: number,
--   fts: Array<string>,
--   exts?: Array<string>,
--   top_hacks?: Array<string>
-- }>

-- Array of file types
-- List of Filetypes and Languages
Master.fts = {}
Master.langs = {}
-- Mapping of filetype to languages
Master.ft_to_lang_map = {}
-- Mapping of langugaes to filetype
Master.lang_to_ft_map = {
  ["angular"] = {
    "typescript",
    "html",
    "typescriptreact",
    "typescript.tsx",
    "htmlangular",
  },
  ["astro"] = {
    "astro",
  },
  ["cmake"] = {
    "cmake",
    "make",
  },
  ["cpp"] = {
    "c",
    "cpp",
    "objc",
    "objcpp",
  },
  ["css"] = {
    "css",
    "scss",
    "less",
  },
  ["d"] = {
    "d",
  },
  ["emmet"] = {
    "html",
    "css",
    "less",
    "postcss",
    "sass",
    "scss",
    "sugarss",
    "typescriptreact",
    "javascriptreact",
    "astro",
  },
  ['eslint'] = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
    'svelte',
  },
  ["go"] = {
    "go",
    "gomod",
  },
  ["helm"] = {
    "helm",
  },
  ["html"] = {
    "html",
  },
  ["json"] = {
    "json",
    "jsonc",
  },
  ['jsts'] = {
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
    'typescript.tsx',
    "javascript.jsx"
  },
  ["kotlin"] = {
    "kotlin",
  },
  ["latex"] = {
    "bib",
    "tex",
  },
  ["lua"] = {
    "lua",
  },
  ["markdown"] = {
    "markdown",
    "markdown.mdx",
  },
  ["nginx"] = {
    "nginx",
  },
  ["ocaml"] = {
    "ocaml",
    "menhir",
    "ocamlinterface",
    "ocamllex",
    "reason",
    "dune",
  },
  ["perl"] = {
    "perl",
  },
  ["php"] = {
    "php",
  },
  ["python"] = {
    "python",
  },
  ["r"] = {
    "r",
    "rmd",
    "quarto",
  },
  ["rust"] = {
    "rust",
  },
  ["scala"] = {
    "scala",
    "sbt",
  },
  ["shell"] = {
    "sh",
    "bash",
    "zsh",
    "csh",
    "ksh",
  },
  ["sql"] = {
    "sql",
    "mysql",
  },
  ["stylelint"] = {
    "css",
    "less",
    "postcss",
    "sass",
    "scss",
    "sugarss",
  },
  ["tailwind"] = {
    -- html
    "aspnetcorerazor",
    "astro",
    "astro-markdown",
    "blade",
    "clojure",
    "django-html",
    "htmldjango",
    "edge",
    "eelixir",     -- vim ft
    "elixir",
    "ejs",
    "erb",
    "eruby",     -- vim ft
    "gohtml",
    "gohtmltmpl",
    "haml",
    "handlebars",
    "hbs",
    "html",
    "htmlangular",
    "html-eex",
    "heex",
    "jade",
    "leaf",
    "liquid",
    "markdown",
    "mdx",
    "mustache",
    "njk",
    "nunjucks",
    "php",
    "razor",
    "slim",
    "twig",
    -- css
    "css",
    "less",
    "postcss",
    "sass",
    "scss",
    "stylus",
    "sugarss",
    -- js
    "javascript",
    "javascriptreact",
    "reason",
    "rescript",
    "typescript",
    "typescriptreact",
    -- mixed
    "vue",
    "svelte",
    "templ",
  },
  ["toml"] = {
    "toml",
  },
  ["vim"] = {
    "vim",
  },
  ['vtsls'] = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
  },
  ["vue"] = {
    "vue",
  },
  ["xml"] = {
    "xml",
    "xsd",
    "xsl",
    "xslt",
    "svg",
  },
  ["yaml"] = {
    "yaml",
  },
  ["zig"] = {
    "zig",
    "zir",
  },
}

local cache_dir = Global.cache_path .. "/filetype_maps"
local cache_fts_file = cache_dir .. "/fts.json"
local cache_langs_file = cache_dir .. "/langs.json"
local cache_ft_lang_map_file = cache_dir .. "/ft_to_lang.json"
local cache_lang_ft_map_file = cache_dir .. "/lang_to_ft.json"
local cache_langs_info_file = cache_dir .. "/langs_info.json"

local FT_MAP_VERSION = 1.02   -- Added/Removed types
local LANG_MAP_VERSION = 1.02 -- Added/Removed types

-- Helper function to remove duplicates from a list
local function remove_duplicates(list)
  local seen = {}
  local result = {}

  for _, item in ipairs(list) do
    if not seen[item] then
      seen[item] = true
      table.insert(result, item)
    end
  end

  return result
end

local build_filetype_map = function()
  -- Check for cached map first
  if vim.fn.filereadable(cache_ft_lang_map_file) == 1 then
    local file = io.open(cache_ft_lang_map_file, "r")
    if file then
      local content = file:read("*all")
      file:close()
      if content and content ~= "" then
        local ok, data = pcall(vim.fn.json_decode, content)
        if ok and data and data.version == FT_MAP_VERSION then
          Master.ft_to_lang_map = data.map
          -- Early return only if BOTH caches are loaded!
          local fts_loaded = false
          -- Try to load the fts cache inline
        end
      end
    end
  end

  if vim.fn.filereadable(cache_fts_file) == 1 then
    local fts_file = io.open(cache_fts_file, "r")
    if fts_file then
      local fts_content = fts_file:read("*all")
      fts_file:close()

      if fts_content and fts_content ~= "" then
        local fts_ok, fts_data = pcall(vim.fn.json_decode, fts_content)
        if fts_ok and fts_data and fts_data.version == FT_MAP_VERSION then
          Master.fts = fts_data.fts
          -- Debug.notify("Loaded both FT map and FTS from cache")
          return -- Now safe to return since both caches loaded
        end
      end
    end
  end

  if vim.fn.filereadable(cache_langs_file) == 1 then
    local langs_file = io.open(cache_langs_file, "r")
    if langs_file then
      local langs_content = langs_file:read("*all")
      langs_file:close()

      if langs_content and langs_content ~= "" then
        local langs_ok, langs_data = pcall(vim.fn.json_decode, langs_content)
        if langs_ok and langs_data and langs_data.version == LANG_MAP_VERSION then
          Master.langs = langs_data.langs
          -- Debug.notify("Loaded both LANGS map and LANGS from cache")
          return
        end
      end
    end
  end

  if vim.fn.filereadable(cache_langs_info_file) == 1 then
    local langs_info_file = io.open(cache_langs_info_file, "r")
    if langs_info_file then
      local langs_content = langs_info_file:read("*all")
      langs_info_file:close()

      if langs_content and langs_content ~= "" then
        local langs_ok, langs_data = pcall(vim.fn.json_decode, langs_content)
        if langs_ok and langs_data and langs_data.version == LANG_MAP_VERSION then
          Master.langs = langs_data.langs
          -- Debug.notify("Loaded both LANGS map and LANGS from cache")
          return
        end
      end
    end
  end

  -- Rebuild and cache with version
  local cached_ft_to_lang_map_data = {
    version = FT_MAP_VERSION,
    map = {},
  }
  local cached_fts_data = {
    version = FT_MAP_VERSION,
    fts = {},
  }
  local cached_langs_data = {
    version = LANG_MAP_VERSION,
    langs = {},
  }
  local cached_langs_to_ft_map_data = {
    version = LANG_MAP_VERSION,
    map = {},
  }

  local cached_langs_master_info_data = {
    version = LANG_MAP_VERSION,
    info = {}
  }

  -- Rebuild the map if no cache exists or cache loading failed
  -- Debug.notify("Building new FT map and filetypes list")
  for language, v in pairs(Master.lang_to_ft_map) do
    table.insert(cached_langs_data.langs, language)
    for _, filetype in ipairs(v) do
      cached_ft_to_lang_map_data.map[filetype] = cached_ft_to_lang_map_data.map[filetype] or {}
      table.insert(cached_ft_to_lang_map_data.map[filetype], language)
      table.insert(cached_fts_data.fts, filetype)
    end
  end


  -- Remove duplicates from each language's filetypes
  for filetype, languages in pairs(cached_ft_to_lang_map_data.map) do
    cached_ft_to_lang_map_data.map[filetype] = remove_duplicates(languages)
    -- Then sort alphabetically
    table.sort(cached_ft_to_lang_map_data.map[filetype])
  end
  cached_langs_to_ft_map_data.map = vim.deepcopy(Master.lang_to_ft_map)
  cached_langs_master_info_data = vim.deepcopy(Master.by_lang)

  -- Store in the actual data structures
  Master.ft_to_lang_map = cached_ft_to_lang_map_data.map

  -- Remove duplicates from the global filetypes list
  cached_fts_data.fts = remove_duplicates(cached_fts_data.fts)
  table.sort(cached_fts_data.fts)
  Master.fts = cached_fts_data.fts

  -- Remove duplicates from the global languages list
  cached_langs_data.langs = remove_duplicates(cached_langs_data.langs)
  table.sort(cached_langs_data.langs)
  Master.langs = cached_langs_data.langs

  -- Save to cache for future use
  if vim.fn.isdirectory(cache_dir) == 0 then
    vim.fn.mkdir(cache_dir, "p")
  end

  local file = io.open(cache_ft_lang_map_file, "w")
  if file then
    -- Optional: sort map keys for more predictable serialization
    local sorted_map = {}
    local sorted_keys = {}

    -- Extract keys to sort them
    for k in pairs(cached_ft_to_lang_map_data.map) do
      table.insert(sorted_keys, k)
    end
    table.sort(sorted_keys)

    -- Build a sorted version of the map for serialization
    for _, k in ipairs(sorted_keys) do
      sorted_map[k] = cached_ft_to_lang_map_data.map[k]
    end

    -- Store the original map but with sorted keys
    cached_ft_to_lang_map_data.map = sorted_map

    file:write(vim.fn.json_encode(cached_ft_to_lang_map_data))
    file:close()
    -- Debug.notify("FT map cached for future sessions")
  end

  local fts_file = io.open(cache_fts_file, "w")
  if fts_file then
    fts_file:write(vim.fn.json_encode(cached_fts_data))
    fts_file:close()
    -- Debug.notify("FTs cached for future sessions")
  end

  local langs_file = io.open(cache_langs_file, "w")
  if langs_file then
    langs_file:write(vim.fn.json_encode(cached_langs_data))
    langs_file:close()
    -- Debug.notify("LANGs cached for future sessions")
  end

  local langs_map_file = io.open(cache_lang_ft_map_file, "w")
  if langs_map_file then
    langs_map_file:write(vim.fn.json_encode(cached_langs_to_ft_map_data))
    langs_map_file:close()
    -- Debug.notify("LANG map cached for future sessions")
  end
end

build_filetype_map()

-- Detailed information for each language
Master.by_lang = {
  ['_emmet'] = {
    desc = 'A plugin for many popular text editors which greatly improves HTML & CSS workflow',
    year = 2008,
    fts = {
      'html',
      'css',
      'typescriptreact',
      'javascriptreact',
      'astro',
      'vue',
      'svelte',
    },
    exts = { '.html', '.css', '.jsx', '.tsx', '.astro', '.vue', '.svelte' },
    products_built = { "Visual Studio Code", "Atom", "Sublime Text", "CodePen", "Brackets" }
  },
  ['_stylelint'] = {
    desc = 'A mighty, modern linter that helps you avoid errors and enforce conventions in your styles',
    year = 2015,
    fts = { 'css', 'less', 'postcss', 'sass', 'scss', 'sugarss' },
    exts = { '.css', '.less', '.pcss', '.sass', '.scss', '.sss' },
    products_built = { "GitHub", "WordPress", "Shopify Polaris", "Primer CSS", "Bootstrap" }
  },
  ['_eslint'] = {
    desc = 'A static code analysis tool for identifying problematic patterns found in JavaScript code',
    year = 2013,
    fts = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
      'vue',
      'svelte',
    },
    exts = { '.js', '.jsx', '.ts', '.tsx', '.vue', '.svelte' },
    products_built = { "Airbnb JavaScript Style Guide", "Google JavaScript Style Guide", "Standard JS", "React", "Vue" }
  },
  ['css'] = {
    desc = 'Cascading Style Sheets is a style sheet language used for describing the presentation of a document',
    year = 1996,
    fts = {
      'html',
      'javascriptreact',
      'typescriptreact',
      'css',
      'sass',
      'less',
      'vue',
      'svelte',
    },
    exts = { '.css', '.scss', '.sass', '.less' },
    products_built = { "Every website", "Bootstrap", "Material Design", "Tailwind CSS", "Bulma" }
  },
  ['Angular'] = {
    desc = 'A TypeScript-based open-source web application framework led by the Angular Team at Google',
    year = 2016,
    fts = { 'typescript', 'html', 'typescriptreact', 'typescript.tsx' },
    exts = { '.ts', '.html', '.tsx' },
    products_built = { "Google Cloud Console", "Forbes", "Xbox", "BMW", "PayPal" }
  },
  ['Astro'] = {
    desc = 'An all-in-one web framework for building fast, content-focused websites',
    year = 2021,
    fts = { 'astro' },
    exts = { '.astro' },
    products_built = { "Astro Documentation", "Vercel Documentation", "The Firebase Blog", "Polypane", "Corset" }
  },
  ['Ember'] = {
    desc = 'An open-source JavaScript web framework, utilizing a component-service pattern',
    year = 2011,
    fts = { 'handlebars', 'typescript', 'javascript', 'hbs' },
    exts = { '.js', '.ts', '.hbs' },
    products_built = { "Apple Music", "LinkedIn", "Netflix", "Square Dashboard", "Discourse" }
  },
  ['React'] = {
    desc = 'A JavaScript library for building user interfaces',
    year = 2013,
    fts = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'jsx',
      'tsx',
    },
    exts = { '.js', '.jsx', '.ts', '.tsx' },
    products_built = { "Facebook", "Instagram", "WhatsApp Web", "Netflix", "Airbnb" }
  },
  ['Vue'] = {
    desc = 'A progressive framework for building user interfaces',
    year = 2014,
    fts = { 'vue', 'javascript', 'typescript' },
    exts = { '.vue', '.js', '.ts' },
    products_built = { "Alibaba", "GitLab", "Grammarly", "Adobe Portfolio", "Behance" }
  },
  ['Svelte'] = {
    desc = 'A radical new approach to building user interfaces',
    year = 2016,
    fts = { 'svelte', 'javascript', 'typescript' },
    exts = { '.svelte', '.js', '.ts' },
    products_built = { "1Password", "The New York Times", "Spotify Soundtrap", "Chess.com", "Philips Hue" }
  },
  ['Next.js'] = {
    desc = 'A React framework for production-grade applications',
    year = 2016,
    fts = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'jsx',
      'tsx',
    },
    exts = { '.js', '.jsx', '.ts', '.tsx' },
    products_built = { "Twitch", "TikTok", "Hulu", "AT&T", "Target" }
  },
  ['Nuxt.js'] = {
    desc = 'A free and open source web application framework based on Vue.js',
    year = 2016,
    fts = { 'vue', 'javascript', 'typescript' },
    exts = { '.vue', '.js', '.ts' },
    products_built = { "Ubisoft", "BMW", "NASA", "Nintendo", "MyRepublic" }
  },
  ['Gatsby'] = {
    desc = 'A free and open source framework based on React for building websites and apps',
    year = 2015,
    fts = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'jsx',
      'tsx',
    },
    exts = { '.js', '.jsx', '.ts', '.tsx' },
    products_built = { "Figma", "Nike", "Airbnb Engineering", "DoorDash", "Impossible Foods" }
  },
  ['Tailwind CSS'] = {
    desc = 'A utility-first CSS framework for rapidly building custom user interfaces',
    year = 2017,
    fts = {
      'html',
      'javascriptreact',
      'typescriptreact',
      'vue',
      'svelte',
      'astro',
    },
    exts = { '.html', '.jsx', '.tsx', '.vue', '.svelte', '.astro' },
    products_built = { "Shopify Polaris", "GitHub Next", "Netflix Jobs", "Ring", "TED" }
  },
  ['JavaScript'] = {
    desc = 'A high-level, interpreted programming language',
    year = 1995,
    fts = { 'javascript', 'javascriptreact', 'js', 'jsx' },
    exts = { '.js', '.jsx', '.mjs', '.cjs' },
    top_hacks = { 'Node.js', 'React', 'Vue.js', 'Angular', 'Express.js' },
    products_built = { "Google Maps", "Facebook", "YouTube", "Gmail", "Spotify" }
  },
  ['TypeScript'] = {
    desc = 'A typed superset of JavaScript that compiles to plain JavaScript',
    year = 2012,
    fts = { 'typescript', 'typescriptreact', 'ts', 'tsx' },
    exts = { '.ts', '.tsx' },
    top_hacks = { 'Angular', 'VS Code', 'Deno', 'NestJS', 'TypeORM' },
    products_built = { "Microsoft Office 365", "Visual Studio Code", "Slack", "Asana", "Figma" }
  },
  ['Python'] = {
    desc = 'An interpreted, high-level and general-purpose programming language',
    year = 1991,
    fts = { 'python' },
    exts = { '.py', '.pyi', '.pyc', '.pyd', '.pyw', '.pyz' },
    top_hacks = { 'Django', 'Flask', 'Pandas', 'TensorFlow', 'Dropbox' },
    products_built = { "Instagram", "Spotify", "Dropbox", "Netflix", "Reddit" }
  },
  ['Rust'] = {
    desc = 'A systems programming language that runs blazingly fast, prevents segfaults, and guarantees thread safety',
    year = 2010,
    fts = { 'rust' },
    exts = { '.rs', '.rlib' },
    top_hacks = { 'Servo', 'Redox', 'Firecracker', 'Alacritty', 'Deno' },
    products_built = { "Discord", "Cloudflare", "1Password", "Figma", "Firefox" }
  },
  ['Go'] = {
    desc = 'A statically typed, compiled programming language designed at Google',
    year = 2009,
    fts = { 'go', 'gomod' },
    exts = { '.go', '.mod' },
    top_hacks = { 'Docker', 'Kubernetes', 'Prometheus', 'Terraform', 'Hugo' },
    products_built = { "Uber", "Twitch", "SoundCloud", "Dropbox", "Docker" }
  },
  ['HTML'] = {
    desc = 'The standard markup language for documents designed to be displayed in a web browser',
    year = 1993,
    fts = { 'html' },
    exts = { '.html', '.htm', '.xhtml' },
    products_built = { "Every website", "Wikipedia", "YouTube", "Amazon", "Twitter" }
  },
  ['CSS'] = {
    desc = 'A style sheet language used for describing the presentation of a document written in HTML or XML',
    year = 1996,
    fts = { 'css', 'scss', 'less' },
    exts = { '.css', '.scss', '.less' },
    products_built = { "Every styled website", "Bootstrap", "Material Design", "Tailwind CSS", "Foundation" }
  },
  ['Java'] = {
    desc =
    'A general-purpose programming language that is class-based, object-oriented, and designed to have as few implementation dependencies as possible',
    year = 1995,
    fts = { 'java' },
    exts = { '.java', '.class', '.jar' },
    top_hacks = {
      'Android',
      'Minecraft',
      'Eclipse IDE',
      'Elasticsearch',
      'Apache Hadoop',
    },
    products_built = { "Android", "Netflix", "Uber", "Airbnb", "Minecraft" }
  },
  ['C++'] = {
    desc = 'A general-purpose programming language created as an extension of the C programming language',
    year = 1979,
    fts = { 'cpp', 'c', 'objc', 'objcpp' },
    exts = { '.cpp', '.cxx', '.cc', '.c', '.hpp', '.hxx', '.h', '.m', '.mm' },
    top_hacks = {
      'Google Chrome',
      'Microsoft Windows',
      'Adobe Photoshop',
      'MySQL',
      'MongoDB',
    },
    products_built = { "Windows", "Chrome", "Firefox", "Adobe Photoshop", "Unreal Engine" }
  },
  ['Ruby'] = {
    desc = 'A dynamic, open source programming language with a focus on simplicity and productivity',
    year = 1995,
    fts = { 'ruby' },
    exts = { '.rb', '.rbw', '.gemspec', '.rake' },
    top_hacks = {
      'Ruby on Rails',
      'Metasploit',
      'Homebrew',
      'Vagrant',
      'Discourse',
    },
    products_built = { "GitHub", "Airbnb", "Shopify", "Twitch", "Kickstarter" }
  },
  ['PHP'] = {
    desc = 'A popular general-purpose scripting language that is especially suited to web development',
    year = 1995,
    fts = { 'php' },
    exts = { '.php', '.phtml', '.php3', '.php4', '.php5', '.phps' },
    top_hacks = {
      'WordPress',
      'Facebook',
      'Laravel',
      'Symfony',
      'MediaWiki',
    },
    products_built = { "Facebook", "WordPress", "Wikipedia", "Slack", "Etsy" }
  },
  ['C#'] = {
    desc =
    'A multi-paradigm programming language encompassing strong typing, imperative, declarative, functional, generic, object-oriented, and component-oriented programming disciplines',
    year = 2000,
    fts = { 'cs' },
    exts = { '.cs' },
    products_built = { "Unity", "Microsoft Office", "Visual Studio", "Stack Overflow", "Windows Apps" }
  },
  ['Shell'] = {
    desc =
    'A command-line interpreter or shell that provides a command line user interface for Unix-like operating systems',
    year = 1971,
    fts = { 'sh', 'bash', 'zsh', 'csh', 'ksh' },
    exts = { '.sh', '.bash', '.zsh', '.csh', '.ksh' },
    products_built = { "macOS System Tools", "Linux Distros", "AWS CLI", "Docker Scripts", "Git Hooks" }
  },
  ['Lua'] = {
    desc =
    'A lightweight, high-level, multi-paradigm programming language designed primarily for embedded use in applications',
    year = 1993,
    fts = { 'lua' },
    exts = { '.lua' },
    products_built = { "Roblox", "World of Warcraft Addons", "Neovim", "Redis", "Adobe Lightroom" }
  },
  ['Markdown'] = {
    desc = 'A lightweight markup language with plain-text-formatting syntax',
    year = 2004,
    fts = { 'markdown' },
    exts = { '.md', '.markdown', '.mdown', '.mkdn' },
    products_built = { "GitHub Documentation", "Reddit", "Stack Overflow", "Notion", "Discord" }
  },
  ['JSON'] = {
    desc =
    'A lightweight data-interchange format that is easy for humans to read and write and easy for machines to parse and generate',
    year = 2001,
    fts = { 'json' },
    exts = { '.json' },
    products_built = { "APIs everywhere", "Node.js packages", "VS Code settings", "Web config files", "Database storage" }
  },
  ['YAML'] = {
    desc = 'A human-readable data-serialization language commonly used for configuration files',
    year = 2001,
    fts = { 'yaml' },
    exts = { '.yaml', '.yml' },
    products_built = { "Kubernetes", "GitHub Actions", "CircleCI", "GitLab CI", "Docker Compose" }
  },
  ['XML'] = {
    desc =
    'A markup language that defines a set of rules for encoding documents in a format that is both human-readable and machine-readable',
    year = 1996,
    fts = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
    exts = { '.xml', '.xsd', '.xsl', '.xslt', '.svg' },
    products_built = { "Android Layouts", "Microsoft Office", "RSS", "SOAP APIs", "SVG Graphics" }
  },
  ['SQL'] = {
    desc =
    'A domain-specific language used in programming and designed for managing data held in a relational database management system',
    year = 1974,
    fts = { 'sql', 'mysql' },
    exts = { '.sql' },
    products_built = { "Oracle", "MySQL", "PostgreSQL", "Microsoft SQL Server", "SQLite" }
  },
  ['Docker'] = {
    desc =
    'A set of platform as a service products that use OS-level virtualization to deliver software in packages called containers',
    year = 2013,
    fts = { 'dockerfile' },
    exts = { 'Dockerfile' },
    products_built = { "Docker Desktop", "Docker Hub", "Docker Compose", "Docker Swarm", "Docker Enterprise" }
  },
  ['Vim'] = {
    desc = 'A highly configurable text editor built to make creating and changing any kind of text very efficient',
    year = 1991,
    fts = { 'vim' },
    exts = { '.vim', '.vimrc' },
    products_built = { "Vim", "Neovim", "SpaceVim", "VimR", "Vimium" }
  },
  ['TOML'] = {
    desc = 'A file format for configuration files',
    year = 2013,
    fts = { 'toml' },
    exts = { '.toml' },
    products_built = { "Cargo (Rust)", "PyProject", "Netlify", "Vercel", "Git config" }
  },
  ['Zig'] = {
    desc = 'A general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software',
    year = 2016,
    fts = { 'zig', 'zir' },
    exts = { '.zig', '.zir' },
    products_built = { "Bun", "TigerBeetle", "Mach Engine", "zls", "Andrew Kelley OSS" }
  },
}

-- Neovim excluded filetypes
Master.excluded_fts = {
  'aerial',
  'Avante',
  'AvanteInput',
  'dashboard',
  'fzf',
  'help',
  'lazy',
  'lspinfo',
  'mason',
  'minifiles',
  'neo%-tree',
  'Neogit',
  'NvimTree',
  'Outline',
  'prompt',
  'qf',
  'quickfix',
  'Snacks',
  'snacks',
  'snacks_dashboard',
  'techdeus',
  'telescope',
  'Trouble',
}

-- Neovim excluded buffer types
Master.excluded_bts = {
  'terminal',
  'prompt',
  'nofile',
  'help',
  'quickfix',
  'snacks_dashboard',
}

return Master

--End-of-file--
