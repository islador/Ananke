# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	#Whitelist Log
	$('#whitelist_log_table').dataTable
		aaSorting: [[ 6, "desc" ]]

	#Whitelist.haml _new_whitelist_api_pull integration & mechanics
	$("#begin_new_api_pull").click ->
		#Extract necessary data from the page.
		target = $("#begin_new_api_pull").attr("data-target-path")
		#target_id = $("#begin_new_api_pull").attr("data-pull-api-id")

		#target_table = apt
		#target_table_id = "#api_pulls_table"

		authenticity_token = $('meta[name=csrf-token]').attr("content")

		if target is "Delete"
			$('#new_query_table').empty()
			swap_button("#begin_new_api_pull", "Begin New API Pull", "/whitelist/retrieve_pullable_apis" )
		else
		#If the user clicks 'Ok' then send an AJAX call deleting the user
			$.ajax({
				#A post with a method data attribute is used to preserve cross browser compability.
				url: target, type: "GET",
				data: { authenticity_token: authenticity_token},
				#On success, return code 200, trigger the remove_from_table function
				success: swap_button("#begin_new_api_pull", "Close API Pull Table", "Delete" )
			})


	#Whitelist.haml Pull API Tables
	window.apt = $('#api_pulls_table').dataTable()

	$("[id^='cancel_pull_api_']").click ->
		#Extract necessary data from the page.
		target = $("#" + this.id).attr("data-target-path")
		target_id = $("#" + this.id).attr("data-pull-api-id")
		target_table = apt
		target_table_id = "#api_pulls_table"
		authenticity_token = $('meta[name=csrf-token]').attr("content")

		#Trigger confirm dialog before making AJAX call
		if confirm("Canceling this API's pull will immediately remove it from this table and delete any whitelist entities it is soley responsible. Do you want to do this?") is true
			#If the user clicks 'Ok' then send an AJAX call deleting the user
			$.ajax({
				#A post with a method data attribute is used to preserve cross browser compability.
				url: target, type: "PUT",
				data: { authenticity_token: authenticity_token},
				#On success, return code 200, trigger the remove_from_table function
				success: remove_from_table(this.id, target_id, target_table, target_table_id)
			})

	#Whitelist.haml Whitelist Table
	window.wlt = $('#whitelist_table').dataTable()

	#Function to detect clicks on the in table whitelist entity "Delete" button.
	$("[id^='destroy_entity_']").click ->
		#Extract necessary data from the page.
		target = $("#" + this.id).attr("data-target-path")
		target_id = $("#" + this.id).attr("data-entity-id")
		target_table = wlt
		target_table_id = "#whitelist_table"
		authenticity_token = $('meta[name=csrf-token]').attr("content")

		#Trigger confirm dialog before making AJAX call
		if confirm('Deleting this entity will deauthorize all members of the group from your services. Are you sure you wish to delete this entity?') is true
			#If the user clicks 'Ok' then send an AJAX call deleting the user
			$.ajax({
				#A post with a method data attribute is used to preserve cross browser compability.
				url: target, type: "POST",
				data: {"_method":"delete", authenticity_token: authenticity_token},
				#On success, return code 200, trigger the remove_from_table function
				success: remove_from_table(this.id, target_id, target_table, target_table_id)
			})

	#Function to detect clicks on the in table whitelist entity "Delete" button.
	$("#submit_new_entity").click ->
		#Extract necessary data for AJAX from the page.
		target = $("#" + this.id).attr("data-target-path")
		authenticity_token = $('meta[name=csrf-token]').attr("content")
		entity_type = $('input[name=entity_type]:checked', '#whitelist_manual_addition').val()

		#Extract additional data for table update
		entity_label = $("label[for='"+$('input[name=entity_type]:checked', '#whitelist_manual_addition').attr("id")+"']").text()
		entity_name = $("#entity_name").val()
		#If the user clicks 'Ok' then send an AJAX call deleting the user
		$.ajax({
			#A post with a method data attribute is used to preserve cross browser compability.
			url: target, type: "POST",
			data: {authenticity_token: authenticity_token, entity_type: entity_type, entity_name: entity_name},
			#On success, return code 200, trigger the entity_name field
			success: clear_text_field("#entity_name")
		})
		#Add the new data to the table temporarily. The next page refresh will pull in the actual data.
		wlt.fnAddData [entity_name, entity_label, "You", "Manual", "", "Freshly Added"]

	#Function to remove an entire row from the volunteer index table.
	remove_from_table = (id, target_id, target_table, target_table_id) ->
		#Extract necessary variables from the page.
		#entity_id = $("#" + id).attr("data-entity-id")
		nRow =  $(target_table_id + ' tbody tr[id='+target_id+']')[0];
		#Remove the row with id = entity.id
		target_table.fnDeleteRow( nRow )
		#wlt.fnDeleteRow( nRow )
		#wlt.fnClearTable()
		#$("#" + entity_id).remove()

	#Function to set any text field's value to zero
	clear_text_field = (id) ->
		#alert id
		$(id).val("")

	#changes a button's text and target
	swap_button = (target_id, new_text, new_target_path) ->
		$(target_id).attr("data-target-path", new_target_path)
		$(target_id).text(new_text)
