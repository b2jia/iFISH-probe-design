#!/usr/bin/python3
# -*- coding: utf-8 -*-

# ------------------------------------------------------------------------------
# 
# Author: Gabriele Girelli
# Email: gigi.ga90@gmail.com
# Version: 0.0.1
# Description: Probe-design queriesQueue
# 
# ------------------------------------------------------------------------------



# DEPENDENCIES =================================================================

import logging
import queue as q
import subprocess as sp

# CLASSES ======================================================================

class Queue(q.Queue):
	'''Database query Queue.

	Args:
		MAX_CURR (int): maximum number of simultaneously released tasks.
		doing (list): list of currently released tasks (i.e., running).
		done (list): list of completed taks.
	'''

	MAX_CURR = 1
	doing = []
	done = []

	def __init__(self, MAX_CURR = None, **kwargs):
		'''Instance method.

		Args:
			n_doing (int): max number of simultaneously running tasks.
		'''
		if not type(None) == type(MAX_CURR):
			self.MAX_CURR = MAX_CURR
		super(Queue, self).__init__()
		return

	def get(self, **kwargs):
		'''Extend original get method by setting up doing.
		Also forces only one element to be running at a time.
		'''

		# Stop if already running
		if not self.MAX_CURR >= len(self.doing):
			return

		# Call original method
		released = super(Queue, self).get(**kwargs)

		# Append released element to released list
		self.doing.append(released)

		# Output released element
		return(released)

	def task_done(self, done, **kwargs):
		'''Extend original task_done method by adding doing and done features.'''

		# If unknown task, kill execution
		if not done in self.doing:
			return

		# Set the task as completed
		self.done.append(self.doing.pop(self.doing.index(done)))

		# Call original method
		super(Queue, self).task_done(**kwargs)

		# Stop
		return

# END ==========================================================================

################################################################################
