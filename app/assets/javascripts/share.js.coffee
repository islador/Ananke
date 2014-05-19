# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	#Show Index
	$("[id^='share_']").click ->
		target = $("#" + this.id).attr("data-target-path")
		window.location.href = target
