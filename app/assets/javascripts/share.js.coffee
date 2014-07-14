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

	$("#register_new_group").click ->
		if $("#register_new_group").hasClass("btn-success")
			name = $("#name_name").val()
			authenticity_token = $('meta[name=csrf-token]').attr("content")
			#console.log(name)
			$.ajax({
				url: "/share/", type: "POST",
				data: {share_name: name, plan: 2},
				success: (data) ->
					if data[0] != false
						$(location).attr('href',"/join?join_id=#{data[0]}")
					#if data == false
						#add the alert class to the error_message div
						#add the text indicating the user's desired group name is available but s/he must login/register to create it the error_message div
				})
		
