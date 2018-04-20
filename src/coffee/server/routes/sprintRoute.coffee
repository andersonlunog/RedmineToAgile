redmine = require('../business/redmine')()
SprintModel = require('../models/sprint')

isLoggedIn = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  res.redirect '/'
  return

module.exports = (app) ->
  app.get "/sprints", (req, res) ->
    SprintModel.find {}, (err, sprints) ->
      return res.status(400).send(err) if err
      res.send sprints

  app.get '/redmine/issuetime', (req, res) ->
    params = req.query
    redmine.getIssueTimeEntries(params.id, params.inicio, params.fim).then (issue) ->
      res.send issue
    , (err) ->
      res.status(400).send err

  app.get '/redmine/issue', (req, res) ->
    params = req.query
    redmine.getIssue(params.id).then (issue) ->
      res.send issue
    , (err) ->
      res.status(400).send err

  app.get '/redmine/issues', (req, res) ->
    ret =
      issues: []
      issuesList: req.query.issues
      inicial: req.query.inicial
      final: req.query.final

    return res.render 'redmine.ejs', ret if not ret.issuesList

    issuesArr = ret.issuesList.split /[^\d]/

    promises = []

    issuesArr.forEach (issueID, i, arr)->
      return if not issueID
      promises.push redmine.getIssueTimeEntries issueID, ret.inicial, ret.final

    Promise.all(promises).then (issues) ->
      console.log "Resolveu as promessas.."
      ret.issues = issues
      res.render 'redmine.ejs', ret

    # redmine.getIssueTimeEntries issuesList, (data, status) ->
    #   res.render 'redmine.ejs', {issues: [data.issue], issuesList: issuesList}
    # , (err) ->
    #   res.render 'redmine.ejs', message: err  
  
  app.get "/sprint/:id", (req, res) ->
    SprintModel.findById req.params.id, (err, sprint) ->
      return res.status(400).send(err) if err
      res.send sprint

  app.post "/sprint", (req, res) ->
    sprint = req.body
    newSprint = new SprintModel sprint
    newSprint.save (err)->
      if err
        console.log "Houve um erro ao salvar #{sprint.nome}"
        res.status(400).send err
      console.log "Sprint salva #{sprint.nome}"
      res.send newSprint

  app.put "/sprint/:id", (req, res) ->
    SprintModel.findById req.params.id, (err, sprint) ->
      return res.status(400).send(err) if err
      sprint.set req.body
      sprint.save (err, uSprint)->
        if err
          console.log "Houve um erro ao atualizar #{sprint.nome}"
          res.status(400).send err
        console.log "Sprint atualizada #{sprint.nome}"
        res.send uSprint

  app.get "/timeentries", (req, res) ->
    # SprintModel.find {_id: req.params.sprintID}, (err, sprints) ->
    #   return res.status(400).send(err) if err
    #   return res.send(null) unless sprints.length
    #   sprint = sprints[0]

      # promises = []
    
    opts =
      user: req.query.user
      dtInicial: req.query.inicio
      dtFinal: req.query.fim
      # callback: (timeEntriesObj, promiseResolve)->
      #   issuePromisses = []
      #   timeEntriesObj.time_entries.forEach (timeEntries) ->
      #     issuePromisses.push redmine.getIssue(timeEntries.issue.id)
      #   Promise.all(issuePromisses).then (issues)->
      #     console.log "Resolveu as promessas issue.."
      #     timeEntriesObj.time_entries.forEach (timeEntries, j) ->                
      #       timeEntriesObj.time_entries[j].issue = issues[j];
      #     promiseResolve(timeEntriesObj)

      # promises.push redmine.getTimeEntries opts

    redmine.getTimeEntries(opts).then (timeEntries) ->
      console.log "Resolveu as promessas entries.."
      res.send timeEntries

    # Promise.all(promises).then (timeEntries) ->
    #   console.log "Resolveu as promessas entries.."
    #   res.send timeEntries
      
  return