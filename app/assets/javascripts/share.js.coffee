# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	#Show Index
	$("[id^='share_']").click ->
		target = $("#" + this.id).attr("data-target-path")
		window.location.href = target

	#Show New
	$("#name_name").focusout ->
		name = $("#name_name").val()
		$.ajax({
			url: "/name_available", type: "GET",
			data: {share_name: name},
			success: (data) ->
				if data == true
					$("#name_name_invalid").hide()
					$("#name_name_valid").show()
					$("#register_new_group").removeClass('btn-danger')
					$("#register_new_group").addClass('btn-success')
				else
					$("#name_name_valid").hide()
					$("#name_name_invalid").show()
					$("#register_new_group").removeClass('btn-success')
					$("#register_new_group").addClass('btn-danger')
			})
		
