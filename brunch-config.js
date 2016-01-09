exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: {
       'js/app.js': /^(web\/static\/(js|vendor))/,
       'js/vendor.js': /^(bower_components\/(bootstrap|jquery\/dist))/
      }
    },
    stylesheets: {
      joinTo: {
       'css/app.css': /^(web\/static\/css)/,
       'css/vendor.css': /^(bower_components)/
      }
    },
    templates: {
      joinTo: 'js/app.js'
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to '/web/static/assets'. Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Which directories to watch
    watched: ["web/static", "test/static", "bower_components/bootstrap"],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/^(web\/static\/vendor)/,
      /^(bower_components)/]
    }
  },
  npm: {
    enabled: true
  }
};
