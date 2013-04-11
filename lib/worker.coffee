_       = require 'underscore'
async   = require 'async'

class Worker
	constructor: (opts) ->
		opts = _.defaults opts,
			duration_ms: 1000
			max_jobs_per_duration: 1
			defer_for_ms: 1000
			debug: false
			concurrency: 1

		started = []

		@queue = async.queue (job, done) ->
			check = ->
				console.log 'check()', job if opts.debug
				now = new Date()

				count = 0
				console.log 'started', started if opts.debug

				for time in started
					offset = now - time

					console.log offset if opts.debug

					if offset < opts.duration_ms
						count += 1
						break if count >= opts.max_jobs_per_duration

				if count >= opts.max_jobs_per_duration
					console.log 'too many jobs started' if opts.debug
					return setTimeout (->
						check()
					), opts.defer_for_ms
				else
					console.log 'started task', job if opts.debug
					started.unshift now
					opts.task job, done

			check()
		, opts.concurrency

module.exports = Worker
