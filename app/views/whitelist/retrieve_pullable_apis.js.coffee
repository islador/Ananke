jQuery ->
	$('#new_query_table').empty().append("<%= escape_javascript(render(:partial => '/shared/new_whitelist_api_pull', locals: {valid_corp_apis: @valid_corp_apis}))%>");
	# Code for the partial is placed here, as per a hint at the below stackoverflow post.
	# http://stackoverflow.com/a/16355680
	window.bnpt = $('#valid_api_table').dataTable()

	$("[id^='query_api_']").click ->
			#Extract necessary data from the page.
			target = $("#"+this.id).attr("data-target-path")
			main_entity_name = $("#"+this.id).attr("data-main-entity-name")
			raw_id = $("#"+this.id).attr("data-raw-id")
			share_user_id = $("#"+this.id).attr("data-share-user-id")

			standing = $("#select_"+ raw_id).val();
			key_id = $("#key_id_"+ raw_id).text();

			target_id = $("#" + this.id).attr("data-query-api-id")
			target_table = bnpt
			target_table_id = "#valid_api_table"

			authenticity_token = $('meta[name=csrf-token]').attr("content")

			$.ajax({
				url: "/share_users/" + share_user_id + "/api/" + raw_id + "/update_api_whitelist_standing", type: "PUT",
				data: { authenticity_token: authenticity_token, standing: standing},
				success: (data, textStatus) ->
					console.log textStatus
					if textStatus is "success"
						$.ajax({
							#A post with a method data attribute is used to preserve cross browser compability.
							url: target, type: "PUT",
							data: { authenticity_token: authenticity_token},
							success: remove_from_table(this.id, target_id, target_table, target_table_id),
							success: apt.fnAddData ["You", main_entity_name, standing, key_id, "Freshly Added"]
						})
			})

	#Funciton duplication confuses me a bit. I'm not entirely sure about the repercussions.
	#Function to remove an entire row from a table
	remove_from_table = (id, target_id, target_table, target_table_id) ->
		#Extract necessary variables from the page.
		#entity_id = $("#" + id).attr("data-entity-id")
		nRow =  $(target_table_id + ' tbody tr[id='+target_id+']')[0];
		#Remove the row with id = entity.id
		target_table.fnDeleteRow( nRow )