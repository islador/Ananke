jQuery ->
	$('#characters_partial').empty().append("<%= escape_javascript(render(:partial => '/shared/character_list', locals: {api: @api, cl: @cl}))%>");
	
	#Shared/_character_list
	$("[id^='set_main_']").click ->
		#Extract necessary data from the page.
		target = $("#" + this.id).attr("data-target-path")
		character_id = $("#" + this.id).attr("data-character-id")
		authenticity_token = $('meta[name=csrf-token]').attr("content")
		share_user_id = $("#"+this.id).attr("data-share-user-id")

		#Trigger confirm dialog before making AJAX call
		if confirm('Setting this character as your main will rebase all roles, permissions, and names off of it.') is true
			#If the user clicks 'Ok' then send an AJAX call deleting the user
			$.ajax({
				url: target, type: "PUT",
				data: {character_id: character_id, authenticity_token: authenticity_token},
				success: (data) ->
					if data[0] is true
						redirect_to_api_list(share_user_id)
					else
						remove_main_button(character_id)
						display_alert(data)
			})

	remove_main_button = (character_id) ->
		$("#column_set_main_" + character_id).empty().append("Main Character")

	redirect_to_api_list = (share_user_id) ->
		$(location).attr('href',"/share_users/#{share_user_id}/api")

	display_alert=(alert)->
		$(".inner-center").prepend("<div class='alert js-alert'>#{alert[0]}</div>")