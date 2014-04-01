# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	window.wlt = $('#whitelist_table').dataTable()

	$('#whitelist_log_table').dataTable
		aaSorting: [[ 6, "desc" ]]

	#Function to detect clicks on the in table whitelist entity "Delete" button.
	$("[id^='destroy_entity_']").click ->
		#Extract necessary data from the page.
		target = $("#" + this.id).attr("data-target-path")
		authenticity_token = $('meta[name=csrf-token]').attr("content")

		#Trigger confirm dialog before making AJAX call
		if confirm('Deleting this entity will deauthorize all members of the group from your services. Are you sure you wish to delete this entity?') is true
			#If the user clicks 'Ok' then send an AJAX call deleting the user
			$.ajax({
				#A post with a method data attribute is used to preserve cross browser compability.
				url: target, type: "POST",
				data: {"_method":"delete", authenticity_token: authenticity_token},
				#On success, return code 200, trigger the remove_from_table function
				success: remove_from_table(this.id)
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
	remove_from_table = (id) ->
		#Extract necessary variables from the page.
		entity_id = $("#" + id).attr("data-entity-id")
		nRow =  $('#whitelist_table tbody tr[id='+entity_id+']')[0];
		#Remove the row with id = entity.id
		wlt.fnDeleteRow( nRow )
		#wlt.fnClearTable()
		#$("#" + entity_id).remove()

	#Function to set any text field's value to zero
	clear_text_field = (id) ->
		#alert id
		$(id).val("")
