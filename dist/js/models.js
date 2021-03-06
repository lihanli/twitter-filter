// Generated by CoffeeScript 1.6.3
(function() {
  window.models = {
    FilteredUser: Backbone.Model.extend({
      validate: function() {
        return models.validations.presence.call(this, 'screenName');
      }
    }),
    FilteredUsers: Backbone.Collection.extend({
      add: function(filteredUser) {
        if (models.checkDuplicates.call(this, filteredUser, 'screenName')) {
          return false;
        }
        return Backbone.Collection.prototype.add.apply(this, arguments);
      },
      findByScreenName: function(screenName) {
        return this.findWhere({
          screenName: models.FilteredUser.sanitizeScreenName(screenName)
        });
      }
    }),
    FilteredPhrase: Backbone.Model.extend({
      validate: function() {
        return models.validations.presence.call(this, 'phrase');
      }
    }),
    FilteredPhrases: Backbone.Collection.extend({
      add: function(filteredPhrase) {
        if (models.checkDuplicates.call(this, filteredPhrase, 'phrase')) {
          return false;
        }
        return Backbone.Collection.prototype.add.apply(this, arguments);
      }
    }),
    Options: Backbone.Model.extend({
      defaults: {
        hideCompletely: false,
        enable: true,
        hideMentions: false
      }
    }),
    checkDuplicates: function(model, attr) {
      return this.any(function(_model) {
        return _model.get(attr) === model.get(attr);
      });
    },
    validations: {
      presence: function(attr) {
        if (util.isBlank(this.get(attr))) {
          return "" + attr + " can't be blank";
        }
        return false;
      }
    },
    generateModelWithSanitizer: function(opt) {
      var model, sanitizeFn;
      if (opt == null) {
        opt = {};
      }
      model = new opt.Model();
      sanitizeFn = opt.sanitizeFn || opt.Model["sanitize" + (util.capitalize(opt.attr))];
      model.on("change:" + opt.attr, function(__, val, changeOpt) {
        if (changeOpt.noSanitize) {
          return;
        }
        return model.set(opt.attr, sanitizeFn(val), {
          noSanitize: true
        });
      });
      return model;
    },
    generateCollection: function(opt) {
      var Collection, cb, collection, evt, _ref;
      if (opt == null) {
        opt = {};
      }
      if (opt.events == null) {
        opt.events = {};
      }
      Collection = models[opt.collectionName];
      collection = new Collection();
      _ref = opt.events;
      for (evt in _ref) {
        cb = _ref[evt];
        collection.on(evt, cb);
      }
      collection.add(util.convertToBackboneArr(Collection.prototype.model, opt.data || []));
      collection.on('change reset add remove', function() {
        util.saveToBg(util.uncapitalize(opt.collectionName), collection);
        if (opt.anyChangeCb) {
          return opt.anyChangeCb();
        }
      });
      return collection;
    }
  };

  models.FilteredUser.sanitizeScreenName = function(screenName) {
    return $.trim(screenName).replace(/\W/g, '').toLowerCase();
  };

  models.FilteredPhrase.sanitizePhrase = function(phrase) {
    return $.trim(phrase).toLowerCase();
  };

  models.FilteredUsers.prototype.model = models.FilteredUser;

  models.FilteredPhrases.prototype.model = models.FilteredPhrase;

}).call(this);
