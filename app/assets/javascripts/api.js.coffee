# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	#API Show
	$("[id^='show_destroy_api_']").click ->
		#Extract necessary data from the page.
		target = $("#" + this.id).attr("data-target-path")
		authenticity_token = $('meta[name=csrf-token]').attr("content")

		#Trigger confirm dialog before making AJAX call
		if confirm('Deleting this API will remove all characters associated with it from Ananke, and thus all access and privileges derived from them. Are you sure you wish to do this?') is true
			#If the user clicks 'Ok' then send an AJAX call deleting the user
			$.ajax({
				#A post with a method data attribute is used to preserve cross browser compability.
				url: target, type: "POST",
				data: {"_method":"delete", authenticity_token: authenticity_token}
			})

	#Shared/_character_list
	$("[id^='set_main_']").click ->
		#Extract necessary data from the page.
		target = $("#" + this.id).attr("data-target-path")
		character_id = $("#" + this.id).attr("data-character-id")
		authenticity_token = $('meta[name=csrf-token]').attr("content")

		#Trigger confirm dialog before making AJAX call
		if confirm('Deleting this API will remove all characters associated with it from Ananke, and thus all access and privileges derived from them. Are you sure you wish to do this?') is true
			#If the user clicks 'Ok' then send an AJAX call deleting the user
			$.ajax({
				url: target, type: "PUT",
				data: {character_id: character_id, authenticity_token: authenticity_token},
				success: remove_main_button(character_id)
			})

	#Function to remove an entire row from the volunteer index table.
	remove_main_button = (character_id) ->
		$("#column_set_main_" + character_id).empty().append("Main Character")

	#API Index
	window.alt = $('#api_list_table').dataTable()

	$("[id^='destroy_api_']").click ->
		#Extract necessary data from the page.
		target = $("#" + this.id).attr("data-target-path")
		authenticity_token = $('meta[name=csrf-token]').attr("content")

		#Trigger confirm dialog before making AJAX call
		if confirm('Deleting this API will remove all characters associated with it from Ananke, and thus all access and privileges derived from them. Are you sure you wish to do this?') is true
			#If the user clicks 'Ok' then send an AJAX call deleting the user
			$.ajax({
				#A post with a method data attribute is used to preserve cross browser compability.
				url: target, type: "POST",
				data: {"_method":"delete", authenticity_token: authenticity_token},
				#On success, return code 200, trigger the remove_from_table function
				success: remove_from_table(this.id)
			})

	#Function to remove an entire row from the volunteer index table.
	remove_from_table = (id) ->
		#Extract necessary variables from the page.
		api_id = $("#" + id).attr("data-api-id")
		nRow =  $('#api_list_table tbody tr[id='+api_id+']')[0];
		#Remove the row with id = entity.id
		alt.fnDeleteRow( nRow )
		#wlt.fnClearTable()
		#$("#" + entity_id).remove()

	#API Enrollment
	$('#character_list_table').dataTable()
	
	#Function to detect clicks on the in table whitelist entity "Delete" button.
	$("#enroll_new_api").click ->
		#Extract necessary data for AJAX from the page.
		target = $("#" + this.id).attr("data-target-path")
		keyID = $("#key_id").val()
		vCode = $("#v_code").val()
		main_checked = $("#main_api").prop('checked')
		authenticity_token = $('meta[name=csrf-token]').attr("content")

		$.ajax({
			#A post with a method data attribute is used to preserve cross browser compability.
			url: target, type: "POST",
			data: {authenticity_token: authenticity_token, key_id: keyID, v_code: vCode},
			#On success, return code 200, clear the text fields, then lock the screen for the async call to complete and call the server for the characters partial if it was a main API.
			success: (data) ->
				clear_text_field("#key_id")
				clear_text_field("#v_code")
				if main_checked == true
					uncheck_checkbox("#main_api")
					lock_screen()
					setTimeout () ->
					    unlock_screen()
					, 5000
					setTimeout () ->
					    retrieve_characters(data)
					, 6000
		})


#Function to set any text field's value to zero
	clear_text_field = (id) ->
		#alert id
		$(id).val("")

	uncheck_checkbox = (id) ->
		$(id).prop('checked', false)

	lock_screen=()->
		$('#myModal').modal('show')
		#console.log new Date()
		
		#setTimeout retrieve_characters, 5250
		
	unlock_screen = ()->
		$('#myModal').modal('hide')
		#console.log new Date()
		#setTimeout retrieve_characters(), 5200
		#console.log new Date()
		

	retrieve_characters =(data) ->
		api_id = data
		#Extract necessary data for AJAX from the page.
		target = $("#enroll_new_api").attr("data-target-path") + "/" + api_id + "/character_list"
		authenticity_token = $('meta[name=csrf-token]').attr("content")

		$.ajax({
			#Hit /users/user_id/api/api_id/character_list.
			url: target, type: "GET",
			data: {authenticity_token: authenticity_token},
			#On success, return code 200, trigger the entity_name field
		})
